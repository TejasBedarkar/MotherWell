import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:fitness_dashboard_ui/theme/maternity_theme.dart';
import 'package:fitness_dashboard_ui/screens/chat_room_screen.dart';

class DoctorMessagesScreen extends StatefulWidget {
  const DoctorMessagesScreen({super.key});

  @override
  State<DoctorMessagesScreen> createState() => _DoctorMessagesScreenState();
}

class _DoctorMessagesScreenState extends State<DoctorMessagesScreen> {
  late IO.Socket socket;
  final TextEditingController _patientIdController = TextEditingController();
  List<Map<String, dynamic>> connections = [];
  bool isLoading = false;
  String doctorId = 'doctor_123'; // Replace with actual doctor ID

  @override
  void initState() {
    super.initState();
    initSocket();
  }

  void initSocket() {
    socket = IO.io(
      'http://192.168.186.121:5000',
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .setTimeout(5000)
        .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print('Doctor socket connected!');
      registerDoctor();
    });

    socket.onDisconnect((_) => print('Doctor socket disconnected'));
    socket.onConnectError((err) => print('Connection error: $err'));
    socket.onError((err) => print('Error: $err'));

    socket.on('connection_established', (_) {
      print('New connection established with patient');
      loadConnections();
    });

    socket.on('get_connections_response', (data) {
      print('Received connections: $data');
      setState(() {
        connections = List<Map<String, dynamic>>.from(data['connections']);
        isLoading = false;
      });
    });
  }

  void registerDoctor() {
    socket.emitWithAck('register', {
      'user_id': doctorId,
      'is_doctor': true
    }, ack: (data) {
      print('Registration response: $data');
      loadConnections();
    });
  }

  void loadConnections() {
    setState(() => isLoading = true);
    socket.emitWithAck('get_connections', {
      'user_id': doctorId,
      'is_doctor': true
    }, ack: (data) {
      print('Connections response: $data');
      if (data['connections'] != null) {
        setState(() {
          connections = List<Map<String, dynamic>>.from(data['connections']);
          isLoading = false;
        });
      }
    });
  }

  void connectWithPatient() {
    final patientId = _patientIdController.text.trim();
    if (patientId.isEmpty) return;

    print('Attempting to connect with patient: $patientId');
    
    socket.emitWithAck('connect_users', {
      'doctor_id': doctorId,
      'patient_id': patientId
    }, ack: (data) {
      print('Connection response: $data');
      if (data['error'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${data['error']}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully connected!')),
        );
        _patientIdController.clear();
        loadConnections();
      }
    });
  }

  void debugState() {
    socket.emitWithAck('debug_state', {}, ack: (data) {
      print('DEBUG STATE:');
      print('Active users: ${data['active_users']}');
      print('Connections: ${data['connections']}');
    });
  }

  @override
  void dispose() {
    socket.disconnect();
    _patientIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Messages'),
        backgroundColor: MaternityTheme.primaryPink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadConnections,
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: debugState,
            child: const Icon(Icons.bug_report),
            mini: true,
            heroTag: null,
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Connect with Patient'),
                content: TextField(
                  controller: _patientIdController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Patient ID',
                    hintText: 'e.g., patient_123',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      connectWithPatient();
                    },
                    child: const Text('Connect'),
                  ),
                ],
              ),
            ),
            child: const Icon(Icons.add),
            heroTag: null,
          ),
        ],
      ),
      body: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(),
          Expanded(
            child: connections.isEmpty
                ? const Center(
                    child: Text(
                      'No patients connected yet',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: connections.length,
                    itemBuilder: (context, index) {
                      final conn = connections[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: MaternityTheme.lightPink,
                          child: Icon(
                            Icons.person,
                            color: conn['status'] ? Colors.green : Colors.grey,
                          ),
                        ),
                        title: Text(conn['user_id']),
                        subtitle: Text(
                          conn['status'] ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: conn['status'] ? Colors.green : Colors.grey,
                          ),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatRoomScreen(
                              conversationId: '${doctorId}_${conn['user_id']}',
                              receiverId: conn['user_id'],
                              receiverName: 'Patient ${conn['user_id']}',
                              isDoctor: true,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}