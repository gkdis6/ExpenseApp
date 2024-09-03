import 'package:flutter/material.dart';
import 'package:financial_app/screens/chart_view.dart';
import 'package:financial_app/screens/calendar_view.dart';

class BudgetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Budget Manager"),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChartView()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalendarView()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text("Welcome to Budget Manager!"),
      ),
    );
  }
}