import 'package:flutter/material.dart';
import 'package:nwdapp/features/meetings/domain/models/meeting.dart';
import 'package:provider/provider.dart';
import 'package:nwdapp/features/meetings/presentation/view_models/meetings_view_model.dart';
import '../../../../core/app_colors.dart';
import 'package:intl/intl.dart';

class BookingBottomSheet extends StatefulWidget {
  const BookingBottomSheet({super.key});

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  int _currentStep = 0; // 0: Summary/Selection, 1: Topic, 2: Confirmation
  int _selectionMode = 0; // 0: Summary, 1: Calendar, 2: Time Grid

  DateTime _selectedDate = DateTime.now();
  DateTime _displayedDate = DateTime.now();
  String? _selectedTime;

  final List<String> _selectedTopics = [];
  final TextEditingController _noteController = TextEditingController();

  final List<String> _topics = [
    "Canada PR",
    "Australia PR",
    "Germany PR",
    "Study Visa",
    "Work Visa",
    "Visitor Visa",
    "Investor Visa",
    "Dependent Visa",
    "Spouse Visa",
    "IELTS Coaching",
    "Resume Building",
    "Others",
  ];

  late List<String> _timeSlots;

  @override
  void initState() {
    super.initState();
    _generateTimeSlots();
    // Initialize with first available slot if today
    if (_timeSlots.isNotEmpty) {
      _selectedTime = _timeSlots.first;
    }
  }

  void _generateTimeSlots() {
    final List<String> slots = [];
    final now = DateTime.now();

    DateTime startTime;
    if (_selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day) {
      // Start from "now" rounded up to next 15 mins
      int minutes = now.minute;
      int roundedMinutes = ((minutes / 15).ceil() * 15);
      startTime = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        roundedMinutes,
      );

      // If rounded up to 60, move to next hour
      if (roundedMinutes == 60) {
        startTime = DateTime(now.year, now.month, now.day, now.hour + 1, 0);
      }
    } else {
      // Start from 9:30 AM for future dates
      startTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        9,
        30,
      );
    }

    // Generate slots for next 8 hours or until end of day (e.g., 9 PM)
    final endTime = DateTime(
      startTime.year,
      startTime.month,
      startTime.day,
      21,
      0,
    );

    DateTime current = startTime;
    while (current.isBefore(endTime)) {
      slots.add(DateFormat('hh:mm a').format(current));
      current = current.add(const Duration(minutes: 15));
    }

    setState(() {
      _timeSlots = slots;
      // Reset selected time if it's no longer in the list
      if (_selectedTime != null && !slots.contains(_selectedTime)) {
        _selectedTime = slots.isNotEmpty ? slots.first : null;
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildCurrentStep(),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildSelectionStep();
      case 1:
        return _buildTopicStep();
      case 2:
        return _buildConfirmationStep();
      default:
        return _buildSelectionStep();
    }
  }

  Widget _buildSelectionStep() {
    if (_selectionMode == 1) return _buildCalendarView();
    if (_selectionMode == 2) return _buildTimeGridView();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        key: const ValueKey("summary"),
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          const Text(
            "Book a session",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            icon: Icons.calendar_month,
            label: "Date",
            value: DateFormat('dd MMM yyyy').format(_selectedDate),
            onTap: () => setState(() => _selectionMode = 1),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.access_time,
            label: "Time [IST]",
            value: _selectedTime ?? "Select Time",
            onTap: () => setState(() => _selectionMode = 2),
          ),
          const SizedBox(height: 32),
          _buildActions(
            onCancel: () => Navigator.pop(context),
            onContinue: () {
              if (_selectedTime != null) {
                setState(() => _currentStep = 1);
              }
            },
            continueLabel: "Continue",
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        key: const ValueKey("calendar"),
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _selectionMode = 0),
                icon: const Icon(Icons.arrow_back_ios, size: 20),
              ),
              const Text(
                "Select Date",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          _buildCalendarGrid(),
          const SizedBox(height: 24),
          _buildActions(
            onCancel: () => setState(() => _selectionMode = 0),
            onContinue: () => setState(() => _selectionMode = 0),
            continueLabel: "Confirm Date",
          ),
        ],
      ),
    );
  }

  Widget _buildTimeGridView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        key: const ValueKey("time_grid"),
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _selectionMode = 0),
                icon: const Icon(Icons.arrow_back_ios, size: 20),
              ),
              const Text(
                "Select Time",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _timeSlots.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              final slot = _timeSlots[index];
              final isSelected = _selectedTime == slot;
              return GestureDetector(
                onTap: () => setState(() => _selectedTime = slot),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryRed.withValues(alpha: 0.1)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(color: AppColors.primaryRed)
                        : null,
                  ),
                  child: Text(
                    slot,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? AppColors.primaryRed
                          : AppColors.textBlack,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          _buildActions(
            onCancel: () => setState(() => _selectionMode = 0),
            onContinue: () => setState(() => _selectionMode = 0),
            continueLabel: "Confirm Time",
          ),
        ],
      ),
    );
  }

  Widget _buildTopicStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        key: const ValueKey("topic"),
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          const Text(
            "What would you like to discuss with counseller?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _topics.map((topic) {
              final isSelected = _selectedTopics.contains(topic);
              return FilterChip(
                label: Text(topic),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTopics.add(topic);
                    } else {
                      _selectedTopics.remove(topic);
                    }
                  });
                },
                selectedColor: AppColors.primaryRed.withValues(alpha: 0.1),
                checkmarkColor: AppColors.primaryRed,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primaryRed : AppColors.textGrey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: const Color(0xFFF3F4F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide.none,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Anything else you'd like to share or ask?",
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildActions(
            onCancel: () => setState(() => _currentStep = 0),
            onContinue: () {
              // Save to ViewModel
              final viewModel = Provider.of<MeetingsViewModel>(
                context,
                listen: false,
              );
              final meeting = Meeting(
                date: _selectedDate,
                time: _selectedTime ?? "",
                topics: List.from(_selectedTopics),
                notes: _noteController.text,
              );
              viewModel.bookMeeting(meeting);

              setState(() => _currentStep = 2);
            },
            continueLabel: "Book session",
            showIcon: true,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        key: const ValueKey("confirmation"),
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          const Text(
            "Session Confirmed",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "You can join the session at the allotted time.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.textGrey),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('dd').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryRed,
                        ),
                      ),
                      Text(
                        DateFormat('MMM yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Video counselling session",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _selectedTime ?? "",
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textGrey,
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
          const SizedBox(height: 40),
          _buildLargeButton("Done", () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textGrey, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF673AB7),
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final int days = DateTime(
      _displayedDate.year,
      _displayedDate.month + 1,
      0,
    ).day;
    final int firstWeekday =
        DateTime(_displayedDate.year, _displayedDate.month, 1).weekday % 7;
    final DateTime now = DateTime.now();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => setState(
                () => _displayedDate = DateTime(
                  _displayedDate.year,
                  _displayedDate.month - 1,
                ),
              ),
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              DateFormat('MMMM yyyy').format(_displayedDate),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(
              onPressed: () => setState(
                () => _displayedDate = DateTime(
                  _displayedDate.year,
                  _displayedDate.month + 1,
                ),
              ),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
              .map(
                (d) => SizedBox(
                  width: 36,
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days + firstWeekday,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemBuilder: (context, index) {
            if (index < firstWeekday) return const SizedBox();
            final int day = index - firstWeekday + 1;
            final date = DateTime(
              _displayedDate.year,
              _displayedDate.month,
              day,
            );
            final bool isSelected =
                date.year == _selectedDate.year &&
                date.month == _selectedDate.month &&
                date.day == _selectedDate.day;
            final bool isPast = date.isBefore(
              DateTime(now.year, now.month, now.day),
            );

            return GestureDetector(
              onTap: isPast
                  ? null
                  : () {
                      setState(() {
                        _selectedDate = date;
                        _generateTimeSlots();
                        _selectionMode = 0;
                      });
                    },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryRed.withValues(alpha: 0.1)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primaryRed
                        : (isPast ? Colors.grey[300] : AppColors.textBlack),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActions({
    required VoidCallback onCancel,
    required VoidCallback onContinue,
    required String continueLabel,
    bool showIcon = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF3F4F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _buildLargeButton(
            continueLabel,
            onContinue,
            showIcon: showIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildLargeButton(
    String label,
    VoidCallback onPressed, {
    bool showIcon = false,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE91E63),
            Color(0xFF9C27B0),
          ], // Refined to match image gradient more closely
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon) ...[
              const Icon(Icons.calendar_today_outlined, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
