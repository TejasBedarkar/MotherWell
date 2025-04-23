import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:fitness_dashboard_ui/theme/maternity_theme.dart';

class Chatbot extends StatelessWidget {
  const Chatbot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MotherWell Bot',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [
    {
      'sender': 'Bot',
      'message': 'Hello! I\'m MotherWell Bot. How can I help with your pregnancy questions today?'
    }
  ];
  late IO.Socket socket;
  bool isConnected = false;
  bool isTyping = false;
  bool showError = false;
  
  // Animation controller for fade-in effect
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    
    // Initialize animations
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.forward();
  }

  void _initializeSocket() {
    // Initialize WebSocket connection
    socket = IO.io('http://127.0.0.1:5000/', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 5000,
      'reconnectionAttempts': 10,
    });

    socket.connect();

    socket.on('connect', (_) {
      setState(() {
        isConnected = true;
        showError = false;
      });
    });

    socket.on('disconnect', (_) {
      setState(() {
        isConnected = false;
        showError = true;
      });
    });

    socket.on('reconnect', (_) {
      setState(() {
        isConnected = true;
        showError = false;
      });
    });

    socket.on('message', (msg) {
      setState(() {
        isTyping = false;
        messages.add({'sender': 'Bot', 'message': msg.toString()});
      });
    });

    socket.on('typing', (_) {
      setState(() {
        isTyping = true;
      });
    });
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    setState(() {
      messages.add({'sender': 'You', 'message': message});
      isTyping = true;
    });

    socket.emit('message', message);
    _controller.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void dispose() {
    socket.disconnect();
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaternityTheme.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: MaternityTheme.white,
            boxShadow: [
              BoxShadow(
                color: MaternityTheme.primaryPink.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: MaternityTheme.primaryPink),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    'MotherWell Pregnancy Assistant',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: MaternityTheme.primaryPink,
                      letterSpacing: 0.5,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: MaternityTheme.lightPink,
                    radius: 18,
                    child: Icon(
                      Icons.chat_bubble_outline,
                      color: MaternityTheme.primaryPink,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              MaternityTheme.lightPink.withOpacity(0.1),
              MaternityTheme.white,
              MaternityTheme.white,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                if (showError)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf9f2f2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: MaternityTheme.primaryPink.withOpacity(0.3),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: MaternityTheme.primaryPink.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: const Color(0xFFd9534f),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Connection lost. Trying to reconnect...',
                            style: TextStyle(color: Color(0xFFd9534f)),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: MaternityTheme.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: MaternityTheme.primaryPink.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: messages.length + (isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < messages.length) {
                          final message = messages[index];
                          final isUser = message['sender'] == 'You';
                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.8,
                              ),
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? MaternityTheme.lightPink
                                    : const Color(0xFFf8f9fa),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: isUser
                                      ? const Radius.circular(18)
                                      : const Radius.circular(5),
                                  bottomRight: isUser
                                      ? const Radius.circular(5)
                                      : const Radius.circular(18),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: MaternityTheme.primaryPink.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                message['message']!,
                                style: TextStyle(
                                  color: isUser 
                                      ? MaternityTheme.primaryPink
                                      : MaternityTheme.textDark,
                                  fontWeight: isUser ? FontWeight.w500 : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.8),
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFf8f9fa),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                  bottomRight: Radius.circular(18),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: MaternityTheme.primaryPink.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        MaternityTheme.primaryPink,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Bot is typing...',
                                    style: TextStyle(
                                      color: MaternityTheme.textLight,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: MaternityTheme.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: MaternityTheme.primaryPink.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: MaternityTheme.lightPink.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Type your question...',
                            hintStyle: TextStyle(
                              color: MaternityTheme.textLight,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          style: TextStyle(
                            color: MaternityTheme.textDark,
                            fontSize: 14,
                          ),
                          onSubmitted: _sendMessage,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              MaternityTheme.primaryPink,
                              MaternityTheme.primaryPink.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: MaternityTheme.primaryPink.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, color: Colors.white),
                          onPressed: () => _sendMessage(_controller.text),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}