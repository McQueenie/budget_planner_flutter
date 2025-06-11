import 'package:flutter/material.dart';

class MonthSelector extends StatelessWidget {
  final int currentMonth;
  final int currentYear;
  final List<String> monthNames;
  final Function(int month, int year) onMonthChange;

  const MonthSelector({
    super.key,
    required this.currentMonth,
    required this.currentYear,
    required this.monthNames,
    required this.onMonthChange,
  });

  void _previousMonth() {
    int newMonth = currentMonth - 1;
    int newYear = currentYear;
    
    if (newMonth < 1) {
      newMonth = 12;
      newYear--;
    }
    
    onMonthChange(newMonth, newYear);
  }

  void _nextMonth() {
    int newMonth = currentMonth + 1;
    int newYear = currentYear;
    
    if (newMonth > 12) {
      newMonth = 1;
      newYear++;
    }
    
    onMonthChange(newMonth, newYear);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: const Icon(Icons.chevron_left, size: 20),
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF4A4A4A),
              minimumSize: const Size(40, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${monthNames[currentMonth - 1]} $currentYear',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(Icons.chevron_right, size: 20),
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF4A4A4A),
              minimumSize: const Size(40, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}