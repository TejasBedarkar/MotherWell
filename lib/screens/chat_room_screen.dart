import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:fitness_dashboard_ui/theme/maternity_theme.dart';
import 'package:intl/intl.dart';

class ChatRoomScreen extends StatefulWidget {
  final String conversationId;
  final String receiverId;
  final String receiverName;
  final bool isDoctor;

  const ChatRoomScreen({
    Key? key,
    required this.conversationId,
    required this.receiverId,
    required this.receiverName,
    required this.isDoctor,
  }) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late IO.Socket socket;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;
  String userId = ''; // Will be set based on isDoctor

  @override
  void initState() {
    super.initState();
    userId = widget.isDoctor ? 'doctor_123' : 'patient_123'; // Replace with actual IDs
    initSocket();
  }

  void initSocket() {
    socket = IO.io(
      'http://192.168.186.121:5000', // Update this to your server IP
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .setTimeout(5000)
        .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print('Chat room socket connected!');
      // Register the user to ensure they're in the right room
      socket.emitWithAck('register', {
        'user_id': userId,
        'is_doctor': widget.isDoctor
      }, ack: (data) {
        print('Registration response in chat: $data');
        loadMessages();
      });
    });

    socket.onDisconnect((_) => print('Chat room socket disconnected'));
    socket.onConnectError((err) => print('Connection error: $err'));
    socket.onError((err) => print('Error: $err'));

    // This is crucial - listen for new incoming messages
    socket.on('new_message', (data) {
      print('Received new message: $data');
      // Make sure we update the UI when a new message arrives
      setState(() {
        messages.add(Map<String, dynamic>.from(data));
      });
      _scrollToBottom();
    });
  }

  void loadMessages() {
    setState(() => isLoading = true);
    
    socket.emitWithAck('get_messages', {
      'conversation_id': widget.conversationId,
      'user_id': userId,
    }, ack: (data) {
      print('Messages response: $data');
      if (data['messages'] != null) {
        setState(() {
          messages = List<Map<String, dynamic>>.from(data['messages']);
          isLoading = false;
        });
        _scrollToBottom();
      } else {
        setState(() => isLoading = false);
      }
    });
  }

  void sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    final message = {
      'sender_id': userId,
      'receiver_id': widget.receiverId,
      'message': messageText,
      'conversation_id': widget.conversationId,
    };

    print('Sending message: $message');
    
    socket.emitWithAck('send_message', message, ack: (data) {
      print('Send message response: $data');
      if (data['success']) {
        setState(() {
          messages.add(Map<String, dynamic>.from(data['message']));
        });
        _messageController.clear();
        _scrollToBottom();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: ${data['error']}')),
        );
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return DateFormat('MMM d, h:mm a').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        backgroundColor: MaternityTheme.primaryPink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(),
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet. Start chatting with ${widget.receiverName}!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isSentByMe = message['sender_id'] == userId;

                      return Align(
                        alignment: isSentByMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSentByMe
                                ? MaternityTheme.primaryPink
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['message'] ?? 'No message content',
                                style: TextStyle(
                                  color: isSentByMe ? Colors.white : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message['timestamp'] != null 
                                    ? _formatTimestamp(message['timestamp']) 
                                    : '',
                                style: TextStyle(
                                  color: isSentByMe
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: MaternityTheme.primaryPink,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}