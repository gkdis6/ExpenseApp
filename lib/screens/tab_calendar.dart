import 'package:financial_app/utils/supabase.dart';
import 'package:financial_app/utils/trans.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarTab extends StatefulWidget {
  final DateTime selectedDay;
  final Function(DateTime) onMonthChange;
  final ValueChanged<DateTime> onFocusedDayChanged; // focusedDay 변경 시 호출할 콜백

  const CalendarTab({
    super.key,
    required this.selectedDay,
    required this.onMonthChange,
    required this.onFocusedDayChanged,
  });

  @override
  _CalendarTabState createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  final SupabaseClient _supabase = SupabaseClientInstance.client;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> _selectedDayTransactions = [];
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDay;
    _fetchMonthlyTransactions(_focusedDay);
  }

  @override
  void didUpdateWidget(CalendarTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // selectedMonth가 변경되었을 때 _focusedDay 갱신
    if (widget.selectedDay != oldWidget.selectedDay) {
      setState(() {
        _focusedDay = widget.selectedDay;
        _selectedDay = widget.selectedDay;
        _fetchMonthlyTransactions(_focusedDay);
        _fetchTransactionsForDay(widget.selectedDay);
      });
    }
  }

  Future<void> _fetchTransactionsForDay(DateTime date) async {
    final response = await _supabase
        .from('transaction')
        .select('*, category(*)')
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
        .select('*, category(*)')
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
            // headerVisible: false,
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
              widget.onFocusedDayChanged(_focusedDay);
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
              setState(() {
                _focusedDay = focusedDay;
              });
              widget.onFocusedDayChanged(_focusedDay);
              widget.onMonthChange(focusedDay);
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
              headerTitleBuilder: (context, day) => SizedBox.shrink(),
            ),
          ),
          Expanded(
            child: _selectedDayTransactions.isEmpty
                ? Center(child: Text("No transactions for this day"))
                : ListView.builder(
                    itemCount: _selectedDayTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _selectedDayTransactions[index];
                      final category = transaction['category'];
                      final categoryColor =
                          transColor(category['color']); // 색상 변환
                      final categoryName = category['name'];

                      return Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween, // 양쪽 끝에 배치
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            width: 200, // 원하는 폭으로 설정
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8), // 내부 여백 조정
                              title: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.start, // 왼쪽 정렬
                                children: [
                                  Text(transaction['description']),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start, // 왼쪽 정렬
                                children: [
                                  Text('${transaction['amount']} 원'),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: categoryColor?.withOpacity(0.2) ??
                                  Colors.grey.withOpacity(0.2), // 연한 배경색
                              borderRadius: BorderRadius.circular(8), // 둥근 모서리
                            ),
                            child: Text(
                              '$categoryName',
                              style: TextStyle(
                                  color: categoryColor ?? Colors.grey),
                            ),
                          ), // 카테고리 이름
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsMarker(List events) {
    Map<int, int> categorySum = {};
    Map<int, String> colorCodes = {};

    for (var event in events) {
      int categoryId = event['category_id'];
      int amount = event['amount'];
      String colorCode = event['category']['color'];

      if (categorySum.containsKey(categoryId)) {
        categorySum[categoryId] = categorySum[categoryId]! + amount;
      } else {
        categorySum[categoryId] = amount;
        colorCodes[categoryId] = colorCode;
      }
    }

    // 가장 높은 금액의 카테고리 찾기
    int highestCategory = categorySum.keys.first;
    int highestSum = categorySum[highestCategory]!;

    categorySum.forEach((category, sum) {
      if (sum > highestSum) {
        highestCategory = category;
        highestSum = sum;
      }
    });

    // 해당 카테고리의 색상으로 마커 색상 설정
    Color markerColor =
        transColor(colorCodes[highestCategory]!) ?? Colors.blueAccent;

    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: markerColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
