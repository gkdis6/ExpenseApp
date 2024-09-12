import 'package:flutter/material.dart';
import 'package:financial_app/screens/chart_view.dart';
import 'package:financial_app/screens/calendar_view.dart';
import 'package:financial_app/utils/auth.dart';

class BudgetScreen extends StatefulWidget {
  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late int index;

  @override
  void initState() {
    super.initState();
    index = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () => logout(context),
        ),
        // title: Text("Budget Manager"),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.bar_chart),
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => ChartView()),
        //       );
        //     },
        //   ),
        //   IconButton(
        //     icon: Icon(Icons.calendar_today),
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => CalendarView()),
        //       );
        //     },
        //   ),
        // ],
      ),
      body: SwitchBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Chart')
        ],
        currentIndex: index,
        onTap: (newIndex) => setState(() {
          index = newIndex;
        }),
      ),
    );
  }

  Widget SwitchBody() {
    switch (index) {
      case 1:
        return ChartView();
      case 0:
      default:
        return CalendarView();
    }
  }
}
