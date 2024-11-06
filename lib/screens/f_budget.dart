import 'package:financial_app/screens/tab_calendar.dart';
import 'package:financial_app/screens/tab_chart.dart';
import 'package:financial_app/utils/common.dart';
import 'package:flutter/material.dart';

import '../utils/auth.dart';
import 'd_add_transaction.dart';

class BudgetFragment extends StatefulWidget {
  @override
  State<BudgetFragment> createState() => _BudgetFragmentState();
}

class _BudgetFragmentState extends State<BudgetFragment> {
  DateTime _selectedMonth = DateTime.now();
  DateTime _focusedDayFromCalendar =
      DateTime.now(); // CalendarTab에서 받아올 focusedDay
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

  void _updateFocusedDay(DateTime focusedDay) {
    setState(() {
      _focusedDayFromCalendar = focusedDay; // 최신 focusedDay 값 저장
    });
  }

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddTransactionDialog(
          initialDate: _currentIndex == 0
              ? _focusedDayFromCalendar // CalendarTab일 때만 focusedDay 전달
              : _selectedMonth,
          onTransactionAdded: (DateTime selectedDate) {
            _changeMonth(selectedDate); // 트랜잭션 추가 후 선택된 날짜로 화면 이동
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _screens = [
      CalendarTab(
        selectedDay: _selectedMonth,
        onMonthChange: _changeMonth,
        onFocusedDayChanged:
            _updateFocusedDay, // CalendarTab에서 focusedDay를 업데이트
      ),
      ChartTab(
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
        title: Text(_selectedMonth.formattedYearMonth),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => {},
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddTransactionDialog(context),
          ),
        ],
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
