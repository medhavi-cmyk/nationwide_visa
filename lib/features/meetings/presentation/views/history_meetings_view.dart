import 'package:flutter/material.dart';
import '../widgets/meeting_card.dart';

class HistoryMeetingsView extends StatelessWidget {
  const HistoryMeetingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        MeetingCard(
          date: "11",
          month: "Mar 2024",
          title: "Video Counselling Session",
          time: "01:00 PM",
          status: "Missed",
          statusColor: Colors.red,
        ),
        MeetingCard(
          date: "05",
          month: "Mar 2024",
          title: "Initial Consultation",
          time: "10:30 AM",
          status: "Completed",
          statusColor: Colors.green,
        ),
        MeetingCard(
          date: "28",
          month: "Feb 2024",
          title: "Document Review",
          time: "04:15 PM",
          status: "Completed",
          statusColor: Colors.green,
        ),
      ],
    );
  }
}
