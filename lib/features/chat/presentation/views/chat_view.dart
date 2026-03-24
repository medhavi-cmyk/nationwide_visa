import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zego_zim/zego_zim.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/services/zego_chat_service.dart';
import '../widgets/attachment_bottom_sheet.dart';
import '../../../../core/widgets/platform/platform_scaffold.dart';
import '../../../../core/widgets/platform/platform_text_field.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

enum ChatMessageType { text, image, file }

class _ChatMessage {
  final int? messageID;
  final String text;
  final String time;
  final bool isMe;
  final ChatMessageType type;
  final String? filePath;
  ZIMMessageReceiptStatus receiptStatus;

  _ChatMessage({
    this.messageID,
    required this.text,
    required this.time,
    required this.isMe,
    this.type = ChatMessageType.text,
    this.filePath,
    this.receiptStatus = ZIMMessageReceiptStatus.none,
  });
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ZegoChatService _chatService = ZegoChatService();
  String _targetUserID = "test_counselor"; // Default target
  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _receiptSubscription;
  Timer? _typingTimer;
  bool _isTyping = false;

  final List<_ChatMessage> _messages = [
    _ChatMessage(text: "Hi", time: "11:15 AM", isMe: true),
  ];

  @override
  void initState() {
    super.initState();
    // Listen for incoming messages
    _messageSubscription = _chatService.receiveMessageStream.listen((ZIMMessage message) {
      if (kDebugMode) print("ChatView received message: ${message.runtimeType}");
      final now = DateTime.now();
      final timeString =
          "${now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

      if (message is ZIMTextMessage) {
        if (kDebugMode) print("Text: ${message.message}");
        setState(() {
          _messages.add(_ChatMessage(text: message.message, time: timeString, isMe: false));
        });
        _scrollToBottom();
      } else if (message is ZIMImageMessage) {
        if (kDebugMode) print("Image: ${message.fileLocalPath}");
        setState(() {
          _messages.add(_ChatMessage(
            text: "Image",
            time: timeString,
            isMe: false,
            type: ChatMessageType.image,
            filePath: message.fileDownloadUrl.isNotEmpty ? message.fileDownloadUrl : message.fileLocalPath,
          ));
        });
        _scrollToBottom();
      } else if (message is ZIMFileMessage) {
        if (kDebugMode) print("File: ${message.fileName}");
        setState(() {
          _messages.add(_ChatMessage(
            text: message.fileName,
            time: timeString,
            isMe: false,
            type: ChatMessageType.file,
            filePath: message.fileDownloadUrl.isNotEmpty ? message.fileDownloadUrl : message.fileLocalPath,
          ));
        });
        _scrollToBottom();
      }

      // Send read receipt if we are on this screen and the message is from our target
      if (message.senderUserID == _targetUserID) {
        _chatService.sendReadReceipt(_targetUserID);
      }
    });

    _typingSubscription = _chatService.typingStream.listen((typingMap) {
      if (typingMap.containsKey(_targetUserID)) {
        setState(() {
          _isTyping = typingMap[_targetUserID]!;
        });
        if (_isTyping) _scrollToBottom();
      }
    });

    _receiptSubscription = _chatService.receiptStream.listen((infos) {
      bool needsUpdate = false;
      for (var info in infos) {
        for (var msg in _messages) {
          if (msg.messageID == info.messageID) {
            msg.receiptStatus = info.status;
            needsUpdate = true;
          }
        }
      }
      if (needsUpdate) setState(() {});
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _commentController.dispose();
    _scrollController.dispose();
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _receiptSubscription?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_commentController.text.trim().isNotEmpty) {
      final text = _commentController.text.trim();
      _sendWithService(text, ChatMessageType.text);
      _commentController.clear();
    }
  }

  void _sendWithService(String content, ChatMessageType type, {String? path}) async {
    final now = DateTime.now();
    final timeString =
        "${now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

    if (kDebugMode) print("Sending $type to $_targetUserID...");
    
    // Optimistically add message
    final chatMsg = _ChatMessage(
      text: content,
      time: timeString,
      isMe: true,
      type: type,
      filePath: path,
      receiptStatus: ZIMMessageReceiptStatus.processing, // One tick or Double grey initially
    );
    
    setState(() {
      _messages.add(chatMsg);
    });
    _scrollToBottom();

    ZIMMessage? sentMsg;
    if (type == ChatMessageType.text) {
      sentMsg = await _chatService.sendMessage(_targetUserID, content);
    } else if (type == ChatMessageType.image && path != null) {
      sentMsg = await _chatService.sendImageMessage(_targetUserID, path);
    } else if (type == ChatMessageType.file && path != null) {
      sentMsg = await _chatService.sendFileMessage(_targetUserID, path);
    }

    if (sentMsg != null) {
      setState(() {
        final index = _messages.indexOf(chatMsg);
        if (index != -1) {
          _messages[index] = _ChatMessage(
            messageID: sentMsg!.messageID,
            text: chatMsg.text,
            time: chatMsg.time,
            isMe: chatMsg.isMe,
            type: chatMsg.type,
            filePath: chatMsg.filePath,
            receiptStatus: sentMsg.receiptStatus,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: Colors.white,
      titleWidget: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: _chatService.currentUserID == "test_counselor"
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
                    color: Colors.green,
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
                _chatService.currentUserID == "test_counselor"
                    ? "Counselor (Test)"
                    : "User (Test)",
                style: const TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _chatService.currentUserID == "test_counselor"
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
      leading: GestureDetector(
        onTap: () => context.go('/home'),
        child: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textBlack,
            size: 20,
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.settings, color: AppColors.primaryRed),
          onSelected: (value) async {
            if (value == 'counselor') {
              await _chatService.login("test_counselor", "Test Counselor");
              setState(() {
                _targetUserID = "test_user";
                _messages.clear();
              });
            } else {
              await _chatService.login("test_user", "Test User");
              setState(() {
                _targetUserID = "test_counselor";
                _messages.clear();
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
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
                          padding: message.type == ChatMessageType.text
                              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                              : EdgeInsets.zero,
                          decoration: BoxDecoration(
                            color: message.isMe
                                ? const Color(0xFFE1DFF6)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: const Radius.circular(12),
                              bottomRight: message.isMe ? const Radius.circular(0) : const Radius.circular(12),
                            ),
                          ),
                          child: _buildMessageContent(message),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              message.time,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textBlack,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (message.isMe) ...[
                              const SizedBox(width: 4),
                              Icon(
                                message.receiptStatus == ZIMMessageReceiptStatus.none 
                                    ? Icons.check 
                                    : Icons.done_all, 
                                size: 16,
                                color: message.receiptStatus == ZIMMessageReceiptStatus.done
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                            ]
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Typing Indicator
          if (_isTyping)
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20, bottom: 8),
              child: const Text(
                "Typing...",
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
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
                  child: PlatformTextField(
                    controller: _commentController,
                    hintText: "Write a message",
                    onChanged: (text) {
                      _typingTimer?.cancel();
                      _chatService.sendTypingStatus(_targetUserID, true);
                      _typingTimer = Timer(const Duration(seconds: 3), () {
                        _chatService.sendTypingStatus(_targetUserID, false);
                      });
                      setState(() {});
                    },
                    onFieldSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    if (_commentController.text.isNotEmpty) {
                      _sendMessage();
                    } else {
                      showModalBottomSheet<Map<String, dynamic>>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const AttachmentBottomSheet(),
                      ).then((result) {
                        if (result != null) {
                          final type = result['type'] == 'image' ? ChatMessageType.image : ChatMessageType.file;
                          final path = result['path'];
                          _sendWithService(type == ChatMessageType.image ? "Image" : "File", type, path: path);
                        }
                      });
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
  Widget _buildMessageContent(_ChatMessage message) {
    if (message.type == ChatMessageType.image && message.filePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: kIsWeb || message.filePath!.startsWith('http')
            ? Image.network(
                message.filePath!,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFilePlaceholder(message.text),
              )
            : Image.file(
                File(message.filePath!),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFilePlaceholder(message.text),
              ),
      );
    } else if (message.type == ChatMessageType.file) {
      return _buildFilePlaceholder(message.text);
    } else {
      return Text(
        message.text,
        style: const TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 16,
        ),
      );
    }
  }

  Widget _buildFilePlaceholder(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: 200,
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, color: AppColors.primaryRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
