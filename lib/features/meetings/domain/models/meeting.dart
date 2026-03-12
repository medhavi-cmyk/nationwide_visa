import 'package:intl/intl.dart';

class Meeting {
  final DateTime date;
  final String time; // format: "01:00 PM"
  final List<String> topics;
  final String notes;

  Meeting({
    required this.date,
    required this.time,
    this.topics = const [],
    this.notes = '',
  });

  DateTime get fullDateTime {
    final format = DateFormat("hh:mm a");
    final timeDate = format.parse(time);
    return DateTime(
      date.year,
      date.month,
      date.day,
      timeDate.hour,
      timeDate.minute,
    );
  }

  bool get isJoinable {
    final now = DateTime.now();
    final start = fullDateTime;
    // Joinable from 10 mins before to 60 mins after (example)
    return now.isAfter(start.subtract(const Duration(minutes: 10))) &&
           now.isBefore(start.add(const Duration(hours: 1)));
  }
}
