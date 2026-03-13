import 'package:flutter/material.dart';
import 'package:zego_zim/zego_zim.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/services/zego_chat_service.dart';
import '../widgets/attachment_bottom_sheet.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatMessage {
  final String text;
  final String time;
  final bool isMe;

  _ChatMessage({required this.text, required this.time, required this.isMe});
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _commentController = TextEditingController();
  final ZegoChatService _chatService = ZegoChatService();
  String _targetUserID = "counselor_1"; // Default target

  final List<_ChatMessage> _messages = [
    _ChatMessage(text: "Hi", time: "11:15 AM", isMe: true),
    _ChatMessage(
      text: "I joined meeting but no one\nshow ip",
      time: "11:16 AM",
      isMe: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Listen for incoming messages
    _chatService.receiveMessageStream.listen((ZIMMessage message) {
      if (message is ZIMTextMessage) {
        final now = DateTime.now();
        final timeString =
            "${now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

        setState(() {
          _messages.add(
            _ChatMessage(
              text: message.message,
              time: timeString,
              isMe: false, // Message from the other person
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_commentController.text.trim().isNotEmpty) {
      final text = _commentController.text.trim();
      final now = DateTime.now();
      final timeString =
          "${now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

      // Send via ZIM
      _chatService.sendMessage(_targetUserID, text);

      setState(() {
        _messages.add(_ChatMessage(text: text, time: timeString, isMe: true));
        _commentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 40,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textBlack,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: _chatService.currentUserID == "counselor_1"
                      ? const NetworkImage(
                          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150&auto=format&fit=crop',
                        )
                      : const NetworkImage(
                          'https://plus.unsplash.com/premium_photo-1671656349322-41de944d259b?q=80&w=687&auto=format&fit=crop',
                        ),
                  backgroundColor: Colors.purple.withValues(alpha: 0.1),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _chatService.currentUserID == "counselor_1"
                      ? "Counselor"
                      : "User",
                  style: TextStyle(
                    color: AppColors.textBlack,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _chatService.currentUserID == "counselor_1"
                      ? "Counselor"
                      : "User",
                  style: TextStyle(
                    color: AppColors.textGrey.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: AppColors.primaryRed),
            onSelected: (value) async {
              if (value == 'counselor') {
                await _chatService.login("counselor_1", "Counselor Niha");
                setState(() {
                  _targetUserID =
                      "user_default"; // In a real app, this would be the user you are chatting with
                });
              } else {
                final String userId =
                    'user_${DateTime.now().millisecondsSinceEpoch}';
                await _chatService.login(userId, "Demo User");
                setState(() {
                  _targetUserID = "counselor_1";
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'user', child: Text('Login as User')),
              const PopupMenuItem(
                value: 'counselor',
                child: Text('Login as Counselor'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                const SizedBox(height: 20), // Reduced height as content grows
                // Meeting Card
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              '12',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryRed,
                              ),
                            ),
                            Text(
                              'Mar 2026',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Instant counselling meeting',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBlack,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: AppColors.textGrey,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '11:15 AM',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Dynamic Messages
                for (var message in _messages) ...[
                  Align(
                    alignment: message.isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: message.isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: message.isMe
                                ? const Color(0xFFE1DFF6)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: const Radius.circular(12),
                              bottomRight: message.isMe
                                  ? const Radius.circular(0)
                                  : const Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            message.text,
                            style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message.time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textBlack,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Input Area
          Container(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 30,
              top: 10,
            ),
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFF1F2937),
                      ), // Dark border from screenshot
                    ),
                    child: TextField(
                      controller: _commentController,
                      onChanged: (text) {
                        setState(() {});
                      },
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: "Write a message",
                        hintStyle: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    if (_commentController.text.isNotEmpty) {
                      _sendMessage();
                    } else {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const AttachmentBottomSheet(),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1F2937), // Dark circle from screenshot
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _commentController.text.isNotEmpty
                          ? Icons.send
                          : Icons.add,
                      color: Colors.white,
                      size: 28,
                    ),
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
