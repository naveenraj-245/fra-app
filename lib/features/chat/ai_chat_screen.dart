import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  // 🔑 REPLACE WITH YOUR REAL KEY
  static const String _apiKey = 'AIzaSyC-m0-hPRJHBbGOuupJkP4vqcgofA1twpE'; 

  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  final List<ChatMessageData> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initGemini();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _initGemini() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
      // 🧠 SYSTEM PROMPT: TEACHING GEMINI HOW TO BEHAVE
      systemInstruction: Content.system(
        "You are 'VanAdhikar AI', a helpful assistant for tribal people in India. "
        "Your goal is to explain the Forest Rights Act (FRA) 2006 in very simple, short sentences. "
        "Answer questions about land claims, documents needed (Voter ID, Ration Card), and rights. "
        "If asked about status, say 'Please check the Track Status tab'. "
        "Always be polite and encouraging."
      ),
    );
    _chatSession = _model.startChat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Sahayak (Helper)"),
        backgroundColor: const Color(0xFF1B5E20), // Forest Green
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => setState(() => _messages.clear()),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(width: 12),
                  Text('VanAdhikar AI is typing...'),
                ],
              ),
            ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageData message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF1B5E20) : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Ask about your rights...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF1B5E20),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // 1. Add User Message to UI
    setState(() {
      _messages.insert(0, ChatMessageData(text: text, isUser: true));
      _isTyping = true;
    });
    _textController.clear();

    try {
      // 2. Send to Gemini
      final response = await _chatSession.sendMessage(
        Content.text(text),
      );

      final responseText = response.text;
      if (responseText == null) return;

      // 3. Add AI Response to UI
      if (mounted) {
        setState(() {
          _messages.insert(0, ChatMessageData(text: responseText, isUser: false));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTyping = false);
      }
    }
  }
}

class ChatMessageData {
  final String text;
  final bool isUser;

  ChatMessageData({required this.text, required this.isUser});
}