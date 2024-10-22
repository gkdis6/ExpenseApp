import 'package:financial_app/screens/calendar_view.dart';
import 'package:financial_app/screens/chart_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/auth.dart';

class BudgetScreen extends StatefulWidget {
  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  DateTime _selectedMonth = DateTime.now();
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _changeMonth(DateTime newMonth) {
    setState(() {
      _selectedMonth = newMonth;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _screens = [
      CalendarView(
        selectedMonth: _selectedMonth,
        onMonthChange: _changeMonth,
      ),
      ChartView(
        selectedMonth: _selectedMonth,
        onMonthChange: _changeMonth,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () => logout(context),
        ),
        title: Text(DateFormat.yMMM().format(_selectedMonth)),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Chart')
        ],
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
