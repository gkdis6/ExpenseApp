import 'package:financial_app/screens/tab_calendar.dart';
import 'package:financial_app/screens/tab_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/auth.dart';
import 'd_add_transaction.dart';

class BudgetFragment extends StatefulWidget {
  @override
  State<BudgetFragment> createState() => _BudgetFragmentState();
}

class _BudgetFragmentState extends State<BudgetFragment> {
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

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddTransactionDialog(
            // onTransactionAdded: () {
            //   // 트랜잭션이 추가된 후 수행할 작업
            //   print('Transaction added!');
            // },
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _screens = [
      CalendarTab(
        selectedMonth: _selectedMonth,
        onMonthChange: _changeMonth,
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
        title: Text(DateFormat.yMMM().format(_selectedMonth)),
        actions: [
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
