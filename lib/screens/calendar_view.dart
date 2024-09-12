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
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _fetchMonthlyTransactions(_focusedDay);
  }

  Future<void> _fetchTransactionsForDay(DateTime date) async {
    final response = await _supabase
        .from('transaction')
        .select()
        .eq('date', date.toIso8601String().substring(0, 10));

    if (response != null && response.isNotEmpty) {
      setState(() {
        _selectedDayTransactions = response;
      });
    } else {
      setState(() {
        _selectedDayTransactions = [];
      });
    }
  }

  Future<void> _fetchMonthlyTransactions(DateTime focusedDay) async {
    final firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final lastDayOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);

    final response = await _supabase
        .from('transaction')
        .select()
        .gte('date', firstDayOfMonth.toIso8601String().substring(0, 10))
        .lt('date', lastDayOfMonth.toIso8601String().substring(0, 10));

    if (response != null && response.isNotEmpty) {
      Map<DateTime, List<dynamic>> events = {};

      for (var transaction in response) {
        final date = DateTime.parse(transaction['date']);
        final dateWithoutTime = DateTime(date.year, date.month, date.day);
        if (events[dateWithoutTime] == null) {
          events[dateWithoutTime] = [];
        }
        events[dateWithoutTime]!.add(transaction);
      }

      setState(() {
        _events = events;
      });
    } else {
      setState(() {
        _events = {}; // 데이터가 없을 경우 이벤트 맵 초기화
      });
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final dateWithoutTime = DateTime(day.year, day.month, day.day);
    return _events[dateWithoutTime] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0.0), // 원하는 높이 설정
        child: AppBar(
          automaticallyImplyLeading: false, // 뒤로 가기 버튼 같은 기본 요소를 숨김
          toolbarHeight: 0, // 툴바 높이 설정 (0으로 설정하면 아무것도 표시되지 않음)
          elevation: 0, // 그림자 제거
        ),
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
              _fetchMonthlyTransactions(focusedDay);
            },
            eventLoader: _getEventsForDay,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildEventsMarker(events),
                  );
                }
                return SizedBox();
              },
            ),
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

  Widget _buildEventsMarker(List events) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        shape: BoxShape.circle,
      ),
    );
  }
}
