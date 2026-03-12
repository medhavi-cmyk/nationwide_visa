import 'package:flutter/material.dart';
import '../../domain/models/meeting.dart';

class MeetingsViewModel extends ChangeNotifier {
  Meeting? _bookedMeeting;
  Meeting? get bookedMeeting => _bookedMeeting;

  void bookMeeting(Meeting meeting) {
    _bookedMeeting = meeting;
    notifyListeners();
  }

  void rescheduleMeeting(Meeting meeting) {
    _bookedMeeting = meeting;
    notifyListeners();
  }
}
