import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:zego_zim/zego_zim.dart';

class ZegoChatService extends ChangeNotifier {
  // Single instance
  static final ZegoChatService _instance = ZegoChatService._internal();
  // Factory Constructor
  factory ZegoChatService() => _instance;
  // Private Constructor
  ZegoChatService._internal();

  final int appID = 456153833; // From UpcomingMeetingsView
  final String appSign =
      'f7f65b6470a65a66515a52fda1f726f849f2140076a3743a62553222e32347ce';

  bool _isInitialized = false;
  String? _currentUserID;

  // Stream controller for incoming messages
  final _messageController = StreamController<ZIMMessage>.broadcast();
  Stream<ZIMMessage> get receiveMessageStream => _messageController.stream;

  // Stream controller for typing indicators (userID -> isTyping)
  final _typingController = StreamController<Map<String, bool>>.broadcast();
  Stream<Map<String, bool>> get typingStream => _typingController.stream;

  // Stream controller for message receipts
  final _receiptController = StreamController<List<ZIMMessageReceiptInfo>>.broadcast();
  Stream<List<ZIMMessageReceiptInfo>> get receiptStream => _receiptController.stream;

  Future<void> init() async {
    if (_isInitialized) return;

    if (kIsWeb) {
      // Small delay for web to ensure JS script is loaded
      await Future.delayed(const Duration(milliseconds: 500));
    }

    try {
      ZIM.create(
        ZIMAppConfig()
          ..appID = appID
          ..appSign = appSign,
      );
    } catch (e) {
      if (kDebugMode) print("ZIM Create Error: $e");
      return;
    }

    // Set up listeners
    ZIMEventHandler.onReceivePeerMessage = (zim, messageList, fromUserID) {
      for (var message in messageList) {
        if (message is ZIMCommandMessage) {
          try {
            final commandStr = utf8.decode(message.message);
            final cmd = jsonDecode(commandStr);
            if (cmd != null && cmd['isTyping'] != null) {
              _typingController.add({fromUserID: cmd['isTyping'] as bool});
            }
          } catch (_) {
            // Ignore JSON or decoding errors
          }
        } else {
          _messageController.add(message);
        }
      }
    };

    ZIMEventHandler.onMessageReceiptChanged = (zim, infos) {
      _receiptController.add(infos);
    };

    _isInitialized = true;
    if (kDebugMode) print("ZIM SDK Initialized");
  }

  Future<void> login(String userID, String userName) async {
    try {
      // If already logged in, logout first
      if (_currentUserID != null) {
        await logout();
      }

      _currentUserID = userID;

      // ZIM 2.x login syntax
      ZIMLoginConfig loginConfig = ZIMLoginConfig();
      loginConfig.userName = userName;

      await ZIM.getInstance()!.login(userID, loginConfig);
      if (kDebugMode) print("ZIM Login Success: $userID");
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("ZIM Login Error: $e");
    }
  }

  Future<void> logout() async {
    try {
      if (_currentUserID != null) {
        await ZIM.getInstance()!.logout();
        _currentUserID = null;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print("ZIM Logout Error: $e");
    }
  }

  String? get currentUserID => _currentUserID;

  Future<ZIMMessage?> sendMessage(String toUserID, String text) async {
    try {
      ZIMTextMessage textMessage = ZIMTextMessage(message: text);
      ZIMMessageSendConfig sendConfig = ZIMMessageSendConfig()..hasReceipt = true;

      final result = await ZIM.getInstance()!.sendMessage(
        textMessage,
        toUserID,
        ZIMConversationType.peer,
        sendConfig,
      );
      return result.message;
    } catch (e) {
      if (kDebugMode) print("ZIM Send Error: $e");
      return null;
    }
  }

  Future<ZIMMessage?> sendImageMessage(String toUserID, String imagePath) async {
    try {
      ZIMImageMessage imageMessage = ZIMImageMessage(imagePath);
      ZIMMessageSendConfig sendConfig = ZIMMessageSendConfig()..hasReceipt = true;

      final result = await ZIM.getInstance()!.sendMediaMessage(
        imageMessage,
        toUserID,
        ZIMConversationType.peer,
        sendConfig,
        ZIMMediaMessageSendNotification(
          onMediaUploadingProgress: (message, currentSize, totalSize) {},
        ),
      );
      return result.message;
    } catch (e) {
      if (kDebugMode) print("ZIM Send Image Error: $e");
      return null;
    }
  }

  Future<ZIMMessage?> sendFileMessage(String toUserID, String filePath) async {
    try {
      ZIMFileMessage fileMessage = ZIMFileMessage(filePath);
      ZIMMessageSendConfig sendConfig = ZIMMessageSendConfig()..hasReceipt = true;

      final result = await ZIM.getInstance()!.sendMediaMessage(
        fileMessage,
        toUserID,
        ZIMConversationType.peer,
        sendConfig,
        ZIMMediaMessageSendNotification(
          onMediaUploadingProgress: (message, currentSize, totalSize) {},
        ),
      );
      return result.message;
    } catch (e) {
      if (kDebugMode) print("ZIM Send File Error: $e");
      return null;
    }
  }

  Future<void> sendTypingStatus(String toUserID, bool isTyping) async {
    try {
      final commandStr = jsonEncode({"isTyping": isTyping});
      ZIMCommandMessage commandMessage = ZIMCommandMessage(message: Uint8List.fromList(utf8.encode(commandStr)));
      ZIMMessageSendConfig sendConfig = ZIMMessageSendConfig();
      await ZIM.getInstance()!.sendMessage(
        commandMessage,
        toUserID,
        ZIMConversationType.peer,
        sendConfig,
      );
    } catch (e) {
      if (kDebugMode) print("ZIM Typing Error: $e");
    }
  }

  Future<void> sendReadReceipt(String conversationID) async {
    try {
      await ZIM.getInstance()!.sendConversationMessageReceiptRead(
        conversationID,
        ZIMConversationType.peer,
      );
    } catch (e) {
      if (kDebugMode) print("ZIM Read Receipt Error: $e");
    }
  }
}
