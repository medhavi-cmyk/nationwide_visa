import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import 'package:intl/intl.dart';

class BookingBottomSheet extends StatefulWidget {
  const BookingBottomSheet({super.key});

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  int _currentStep = 0; // 0: Date, 1: Time, 2: Topic, 3: Confirmation
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  DateTime _displayedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  final List<String> _selectedTopics = [];
  final TextEditingController _noteController = TextEditingController();

  final List<String> _topics = [
    "Canada PR", "Australia PR", "Germany PR", 
    "Study Visa", "Work Visa", "Visitor Visa",
    "Investor Visa", "Dependent Visa", "Spouse Visa",
    "IELTS Coaching", "Resume Building", "Others"
  ];

  final List<String> _timeSlots = [
    "09:30 AM", "09:45 AM", "10:00 AM",
    "10:15 AM", "10:30 AM", "10:45 AM",
    "11:00 AM", "11:15 AM", "11:30 AM",
    "11:45 AM", "12:00 PM", "12:30 PM",
    "12:45 PM", "01:00 PM", "01:15 PM",
    "01:30 PM", "01:45 PM", "02:00 PM",
    "02:15 PM", "02:30 PM", "02:45 PM",
    "03:00 PM", "03:15 PM", "03:30 PM",
    "03:45 PM", "04:00 PM", "04:15 PM"
  ];

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
        return _buildDateStep();
      case 1:
        return _buildTimeStep();
      case 2:
        return _buildTopicStep();
      case 3:
        return _buildConfirmationStep();
      default:
        return _buildDateStep();
    }
  }

  Widget _buildConfirmationStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        key: const ValueKey(3),
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
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 32),
          // Success Meeting Card Tile
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                // Date Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: AppColors.textGrey),
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
          // Done Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE91E63), AppColors.primaryRed],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryRed.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                "Done",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        key: const ValueKey(0),
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          const Text(
            "Select Date",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 24),
          _buildCalendarGrid(),
          const SizedBox(height: 32),
          _buildActions(
            onCancel: () => Navigator.pop(context),
            onContinue: () => setState(() => _currentStep = 1),
            continueLabel: "Continue",
          ),
        ],
      ),
    );
  }

  Widget _buildTimeStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        key: const ValueKey(1),
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
          // Date Row (as seen in Image 1)
          _buildInfoRow(
            icon: Icons.calendar_month,
            label: "Date",
            value: DateFormat('dd MMM yyyy').format(_selectedDate),
            onTap: () => setState(() => _currentStep = 0),
          ),
          const SizedBox(height: 16),
          // Time Header
          _buildInfoRow(
            icon: Icons.access_time,
            label: "Time [IST]",
            value: "",
          ),
          const SizedBox(height: 16),
          // Time Grid
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
                    color: isSelected ? AppColors.primaryRed.withValues(alpha: 0.1) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected ? Border.all(color: AppColors.primaryRed) : null,
                  ),
                  child: Text(
                    slot,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primaryRed : AppColors.textBlack,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          _buildActions(
            onCancel: () => setState(() => _currentStep = 0),
            onContinue: () {
              if (_selectedTime != null) {
                setState(() => _currentStep = 2);
              }
            },
            continueLabel: "Continue",
          ),
        ],
      ),
    );
  }

  Widget _buildTopicStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        key: const ValueKey(2),
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          const Text(
            "What would you like to discuss with Niha?",
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
            onCancel: () => setState(() => _currentStep = 1),
            onContinue: () => setState(() => _currentStep = 3),
            continueLabel: "Book session",
            showIcon: true,
          ),
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

  Widget _buildInfoRow({required IconData icon, required String label, required String value, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryRed,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.edit, size: 14, color: AppColors.primaryRed),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    // Re-using the calendar logic from previous step
    final int days = DateTime(_displayedDate.year, _displayedDate.month + 1, 0).day;
    final int firstWeekday = DateTime(_displayedDate.year, _displayedDate.month, 1).weekday % 7;
    final DateTime now = DateTime.now();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => setState(() => _displayedDate = DateTime(_displayedDate.year, _displayedDate.month - 1)),
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              DateFormat('MMMM yyyy').format(_displayedDate),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(
              onPressed: () => setState(() => _displayedDate = DateTime(_displayedDate.year, _displayedDate.month + 1)),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
              .map((d) => SizedBox(width: 36, child: Text(d, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12))))
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days + firstWeekday,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
          itemBuilder: (context, index) {
            if (index < firstWeekday) return const SizedBox();
            final int day = index - firstWeekday + 1;
            final date = DateTime(_displayedDate.year, _displayedDate.month, day);
            final bool isSelected = date.year == _selectedDate.year && date.month == _selectedDate.month && date.day == _selectedDate.day;
            final bool isPast = date.isBefore(DateTime(now.year, now.month, now.day));

            return GestureDetector(
              onTap: isPast ? null : () => setState(() {
                _selectedDate = date;
                _currentStep = 1; // Auto-transition as requested
              }),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryRed.withValues(alpha: 0.1) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    color: isSelected ? AppColors.primaryRed : (isPast ? Colors.grey[300] : AppColors.textBlack),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActions({required VoidCallback onCancel, required VoidCallback onContinue, required String continueLabel, bool showIcon = false}) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF3F4F6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: const Text("Cancel", style: TextStyle(color: AppColors.textBlack, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE91E63), AppColors.primaryRed],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(color: AppColors.primaryRed.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showIcon) ...[const Icon(Icons.calendar_today_outlined, size: 18), const SizedBox(width: 8)],
                  Text(continueLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
