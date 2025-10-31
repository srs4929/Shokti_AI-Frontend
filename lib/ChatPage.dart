import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shokti/CustomAppbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatPage extends StatefulWidget {
  /// If [useScaffold] is false the widget returns only the chat body
  /// (no Scaffold / AppBar). This allows embedding the chat inside
  /// another Scaffold (for example the Landingpage) without producing
  /// a duplicate app bar.
  final bool useScaffold;

  const ChatPage({super.key, this.useScaffold = true});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    // Default AI greeting
    _messages.add({
      'role': 'ai',
      'message': 'Hi, I am Shokti AI. How can I help you?',
    });
  }

  Future<void> _sendMessage() async {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'message': text});
    });

    _controller.clear();

    // Get current user id from Supabase
    String userId;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        userId = user.id;
      } else {
        setState(() {
          _messages.add({
            'role': 'ai',
            'message': 'You must be logged in to chat.',
          });
        });
        return;
      }
    } catch (e) {
      setState(() {
        _messages.add({'role': 'ai', 'message': 'Error fetching user info.'});
      });
      return;
    }

    // Call  FastAPI backend
    try {
      final response = await http.post(
        Uri.parse(
          'http://192.168.0.104:8000/chat',
        ), // Replace with your server IP
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': text,
          'user_id': userId, // dynamically send user id
        }),
      );

      String reply = 'Server error. Please try again.';
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        reply = data['reply'] ?? reply;
      }

      setState(() {
        _messages.add({'role': 'ai', 'message': reply});
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'ai', 'message': 'Error connecting to server.'});
      });
    }

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(Map<String, String> msg) {
    bool isAI = msg['role'] == 'ai';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isAI
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (isAI)
            CircleAvatar(
              backgroundColor: const Color.fromARGB(255, 20, 75, 22),
              child: const Icon(Icons.smart_toy, color: Colors.white),
            ),
          if (isAI) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: isAI
                    ? Colors.grey[300]
                    : const Color.fromARGB(255, 0, 73, 2),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isAI
                      ? const Radius.circular(0)
                      : const Radius.circular(16),
                  bottomRight: isAI
                      ? const Radius.circular(16)
                      : const Radius.circular(0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg['message']!,
                style: TextStyle(
                  color: isAI ? Colors.black87 : Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (!isAI) const SizedBox(width: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The chat body (without app chrome) so it can be embedded.
    Widget chatBody = Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return _buildMessage(_messages[index]);
            },
          ),
        ),
        const Divider(height: 1),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.green),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );

    if (widget.useScaffold) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: const CustomAppBar(title: "Shokti AI"),
        body: chatBody,
      );
    }

    // When embedded (useScaffold == false) return only the content.
    return chatBody;
  }
}
