import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // YOUR ACTUAL API KEY (From your screenshot)
// Make sure there are no spaces at the start or end!
static const String _apiKey = "AIzaSyDsgpaDZCUEdeGQ8X2snq576-7oKevgPAk";

  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    // Use the latest flash model. 
    // IMPORTANT: Make sure you upgraded the package in Step 1!
    _model = GenerativeModel(
      model: 'gemini-1.5-flash', 
      apiKey: _apiKey,
    );
    _chat = _model.startChat();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // 1. Add User Message to Screen
    setState(() {
      _messages.add({"role": "user", "text": text});
      _isLoading = true;
    });
    _controller.clear();

    try {
      // 2. Send to Google Gemini
      final response = await _chat.sendMessage(Content.text(text));

      // 3. Add AI Response to Screen
      setState(() {
        _messages.add({
          "role": "bot",
          "text": response.text ?? "I am not sure how to answer that."
        });
      });
    } catch (e) {
      // 4. Handle Errors (shows the REAL error now)
      setState(() {
        _messages.add({
          "role": "bot",
          "text": "Error: $e" 
        });
      });
      debugPrint("GEMINI ERROR: $e"); // Prints to your VS Code terminal
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forest Friend AI"),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // CHAT MESSAGES AREA
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      "Ask me about Forest Rights!\nTry: 'What is FRA?'",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg["role"] == "user";
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xFF1B5E20) : Colors.grey[200],
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(15),
                              topRight: const Radius.circular(15),
                              bottomLeft: isUser ? const Radius.circular(15) : Radius.circular(0),
                              bottomRight: isUser ? Radius.circular(0) : const Radius.circular(15),
                            ),
                          ),
                          child: Text(
                            msg["text"]!,
                            style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // LOADING INDICATOR
          if (_isLoading) 
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(color: Color(0xFF1B5E20)),
            ),

          // INPUT FIELD AREA
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Type your question...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
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
          ),
        ],
      ),
    );
  }
}