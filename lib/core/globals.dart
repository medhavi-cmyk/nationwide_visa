import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class RouterNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

final RouterNotifier routerNotifier = RouterNotifier();
