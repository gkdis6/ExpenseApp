import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:financial_app/utils/supabase.dart';

class CalendarView extends StatefulWidget {
  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final SupabaseClient _supabase = SupabaseClientInstance.client;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> _selectedDayTransactions = [];

  Future<void> _fetchTransactionsForDay(DateTime date) async {
    final response = await _supabase
        .from('transaction')
        .select()
        .eq('date', date.toIso8601String().substring(0, 10)); // YYYY-MM-DD

    if (!response.isEmpty) {
      setState(() {
        _selectedDayTransactions = response;
      });
    } else {
      setState(() {
        _selectedDayTransactions = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calendar View"),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _fetchTransactionsForDay(selectedDay);
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          Expanded(
            child: _selectedDayTransactions.isEmpty
                ? Center(child: Text("No transactions for this day"))
                : ListView.builder(
                    itemCount: _selectedDayTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _selectedDayTransactions[index];
                      return ListTile(
                        title: Text(transaction['description']),
                        subtitle: Text('${transaction['amount']}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
