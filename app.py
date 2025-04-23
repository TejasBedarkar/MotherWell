from flask import Flask, render_template, request, jsonify
from flask_socketio import SocketIO, send
from langchain_community.embeddings import SentenceTransformerEmbeddings
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_astradb import AstraDBVectorStore
from langchain_groq import ChatGroq
from langchain.chains import create_retrieval_chain, create_history_aware_retriever
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.runnables.history import RunnableWithMessageHistory
from langchain_core.chat_history import BaseChatMessageHistory
from langchain_community.chat_message_histories import ChatMessageHistory
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder

# Initialize Flask App and SocketIO
app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*")

# API Keys & Configurations
GROQ_API="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"
ASTRA_DB_API_ENDPOINT="https://391053c3-80de-4556-804f-ac36bd33880e-us-east-2.apps.astra.datastax.com"
ASTRA_DB_APPLICATION_TOKEN="AstraCS:EcTQwkfFJNxNgePhOuKnpmhH:73a9bb7baa08cba901227e7ed675912710c6309e713d23b8e438df54c16557bf"
ASTRA_DB_KEYSPACE="default_keyspace"
HUGFA_TOKEN="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"
# Load Embeddings
embeddings = SentenceTransformerEmbeddings(model_name="all-MiniLM-L6-v2")

# Initialize AstraDB Vector Store
vec_store = AstraDBVectorStore(
    embedding=embeddings,
    collection_name="MotherWell_BOT",
    api_endpoint=ASTRA_DB_API_ENDPOINT,
    token=ASTRA_DB_APPLICATION_TOKEN,
    namespace=ASTRA_DB_KEYSPACE
)

# Load AI Model (Groq - LLaMA)
model = ChatGroq(groq_api_key=GROQ_API, model_name="llama-3.1-8b-instant", temperature=0.5)

# Handle Chat History
store = {}

def get_session_history(session_id: str) -> BaseChatMessageHistory:
    if session_id not in store:
        store[session_id] = ChatMessageHistory()
    return store[session_id]

# Prompt Template for Responses
MOTHERWELL_BOT_TEMPLATE = """
    Your bot, MotherWell Bot, is an expert in pregnancy-related queries, providing guidance on prenatal care,
    common pregnancy concerns, and home remedies for symptom relief.
    Your answers should be relevant to pregnancy, focusing on home remedies and well-being,
    while refraining from medical diagnoses or treatments that require a healthcare provider.
    Keep responses concise, evidence-based, and user-friendly.

    CONTEXT:
    {context}

    QUESTION: {input}

    YOUR ANSWER:
"""

qa_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", MOTHERWELL_BOT_TEMPLATE),
        MessagesPlaceholder(variable_name="chat_history"),
        ("human", "{input}")
    ]
)

# History-Aware Retrieval
retriever_prompt = (
    "Given a chat history and the latest user question, reframe the question as a complete, standalone pregnancy-related query."
)

retriever = vec_store.as_retriever(search_kwargs={"k": 3})
contextualize_q_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", retriever_prompt),
        MessagesPlaceholder(variable_name="chat_history"),
        ("human", "{input}"),
    ]
)

history_aware_retriever = create_history_aware_retriever(model, retriever, contextualize_q_prompt)
question_answer_chain = create_stuff_documents_chain(model, qa_prompt)
chain = create_retrieval_chain(history_aware_retriever, question_answer_chain)

chain_with_memory = RunnableWithMessageHistory(
    chain,
    get_session_history,
    input_messages_key="input",
    history_messages_key="chat_history",
    output_messages_key="answer",
)


@app.route("/")
def home():
    print(f"Looking for template at: {app.template_folder}/chat.html")
    return render_template("chat.html")

@app.route("/ask", methods=["POST"])
def ask():
    data = request.get_json()
    user_input = data.get("question", "")
    session_id = data.get("session_id", "default")

    response = chain_with_memory.invoke(
        {"input": user_input},
        config={"configurable": {"session_id": session_id}}
    )["answer"]

    return jsonify({"response": response})

@socketio.on("message")
def handle_message(msg):
    print(f"User: {msg}")

    response = chain_with_memory.invoke(
        {"input": msg},
        config={"configurable": {"session_id": 'chat_session'}}
    )["answer"]

    send(response)  

if __name__ == "__main__":
    socketio.run(app,debug=True)