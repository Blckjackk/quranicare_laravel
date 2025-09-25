import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyRecapScreen extends StatefulWidget {
  const DailyRecapScreen({super.key});

  @override
  State<DailyRecapScreen> createState() => _DailyRecapScreenState();
}

class _DailyRecapScreenState extends State<DailyRecapScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  
  // Sample data for activities
  final Map<DateTime, List<ActivityData>> _activities = {
    DateTime(2025, 7, 16): [
      ActivityData(
        title: 'Dzikir dan Doa Ketenangan',
        subtitle: '1 kali Akses',
        isCompleted: true,
      ),
      ActivityData(
        title: 'Audio Relax Islami',
        subtitle: '2 kali Akses',
        isCompleted: true,
      ),
      ActivityData(
        title: 'Jurnal Refleksi',
        subtitle: '1 kali Akses',
        isCompleted: true,
      ),
      ActivityData(
        title: 'Breathing Islami Exercise',
        subtitle: '3 kali Akses',
        isCompleted: true,
      ),
      ActivityData(
        title: 'Qalbu Chat',
        subtitle: '1 kali Akses',
        isCompleted: true,
      ),
      ActivityData(
        title: 'Quranic Psychologic Learning',
        subtitle: '2 kali Akses',
        isCompleted: true,
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F8F8),
              Color(0xFFE8F5E8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2D5A5A).withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFF2D5A5A),
                          size: 20,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Daily Recap',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D5A5A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 40), // Balance for back button
                  ],
                ),
              ),

              // Calendar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D5A5A).withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Calendar Header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8FA68E), Color(0xFF7A9B7A)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButton<int>(
                            value: _currentMonth.month,
                            dropdownColor: const Color(0xFF8FA68E),
                            iconEnabledColor: Colors.white,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            underline: const SizedBox(),
                            items: List.generate(12, (index) {
                              return DropdownMenuItem(
                                value: index + 1,
                                child: Text(
                                  DateFormat.MMMM().format(DateTime(2025, index + 1)),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }),
                            onChanged: (month) {
                              setState(() {
                                _currentMonth = DateTime(_currentMonth.year, month!, 1);
                              });
                            },
                          ),
                          DropdownButton<int>(
                            value: _currentMonth.year,
                            dropdownColor: const Color(0xFF8FA68E),
                            iconEnabledColor: Colors.white,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            underline: const SizedBox(),
                            items: List.generate(10, (index) {
                              int year = 2020 + index;
                              return DropdownMenuItem(
                                value: year,
                                child: Text(
                                  year.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }),
                            onChanged: (year) {
                              setState(() {
                                _currentMonth = DateTime(year!, _currentMonth.month, 1);
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Weekdays header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                          .map((day) => Container(
                                width: 35,
                                height: 35,
                                alignment: Alignment.center,
                                child: Text(
                                  day,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748b),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),

                    const SizedBox(height: 8),

                    // Calendar days
                    ..._buildCalendarWeeks(),
                  ],
                ),
              ),

              // Quote Section
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D5A5A).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assalamualaikum, Dafaat!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5A5A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kamu sudah melangkah lebih dekat dengan ketenangan jiwa hari ini! Terus lanjutkan ya!',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF2D5A5A).withOpacity(0.7),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Activities Section
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ringkasan untuk ${DateFormat('EEEE, dd MMMM yyyy', 'id').format(_selectedDate)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D5A5A),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Expanded(
                        child: _buildActivitiesList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCalendarWeeks() {
    List<Widget> weeks = [];
    DateTime firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    DateTime lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    
    int startWeekday = firstDay.weekday;
    int totalDays = lastDay.day;
    
    List<Widget> days = [];
    
    // Add empty containers for days before first day of month
    for (int i = 1; i < startWeekday; i++) {
      days.add(const SizedBox(width: 35, height: 35));
    }
    
    // Add days of the month
    for (int day = 1; day <= totalDays; day++) {
      DateTime date = DateTime(_currentMonth.year, _currentMonth.month, day);
      bool isSelected = _isSameDay(date, _selectedDate);
      bool hasActivity = _activities.containsKey(DateTime(date.year, date.month, date.day));
      
      days.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            width: 35,
            height: 35,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected 
                  ? const Color(0xFF8FA68E)
                  : hasActivity 
                      ? const Color(0xFF8FA68E).withOpacity(0.2)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              day.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? Colors.white
                    : hasActivity 
                        ? const Color(0xFF8FA68E)
                        : const Color(0xFF64748b),
              ),
            ),
          ),
        ),
      );
    }
    
    // Group days into weeks
    for (int i = 0; i < days.length; i += 7) {
      List<Widget> week = days.sublist(i, (i + 7 > days.length) ? days.length : i + 7);
      while (week.length < 7) {
        week.add(const SizedBox(width: 35, height: 35));
      }
      weeks.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: week,
          ),
        ),
      );
    }
    
    return weeks;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildActivitiesList() {
    DateTime key = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    List<ActivityData> activities = _activities[key] ?? [];
    
    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 48,
              color: const Color(0xFF8FA68E).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada aktivitas di hari ini',
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF64748b).withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, index) {
        ActivityData activity = activities[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFF8FA68E).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2D5A5A).withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF8FA68E),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D5A5A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF64748b).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ActivityData {
  final String title;
  final String subtitle;
  final bool isCompleted;

  ActivityData({
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
  });
}