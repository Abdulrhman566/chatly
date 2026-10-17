import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:session_29_9/service/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String reciverId;
  final String reciverEmail;

  const ChatScreen({
    super.key,
    required this.reciverId,
    required this.reciverEmail,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messagecont = TextEditingController();
  final ChatService chatService = ChatService();

  final myId = FirebaseAuth.instance.currentUser!.uid;

  // Send Message
  Future<void> sendMessage() async {
    String message = messagecont.text.trim();

    if (message.isNotEmpty) {
      messagecont.clear();

      try {
        await chatService.sendMessage(message, widget.reciverId);
      } catch (e) {
        if (!mounted) return;

        messagecont.text = message;

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  void dispose() {
    messagecont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reciverEmail),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          // Messages
          Expanded(
            child: StreamBuilder(
              stream: chatService.getMessage(widget.reciverId),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final messages = snapshot.data?.docs ?? [];

                if (messages.isEmpty) {
                  return const Center(child: Text("No messages found"));
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,

                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;

                    final bool isMe = data["sender"] == myId;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,

                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),

                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),

                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),

                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey.shade300,

                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: Text(
                          data["messages"] ?? "",
                          style: TextStyle(
                            fontSize: 16,
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 5,
                ),
              ],
            ),

            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messagecont,

                      textInputAction: TextInputAction.send,

                      onSubmitted: (_) => sendMessage(),

                      decoration: InputDecoration(
                        hintText: "Type a message...",

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),

                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blue,

                    child: IconButton(
                      onPressed: sendMessage,

                      icon: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
