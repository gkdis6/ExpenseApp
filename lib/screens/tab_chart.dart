import 'package:financial_app/utils/supabase.dart';
import 'package:financial_app/utils/trans.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartTab extends StatefulWidget {
  final DateTime selectedMonth;
  final Function(DateTime) onMonthChange;

  const ChartTab(
      {super.key, required this.selectedMonth, required this.onMonthChange});

  @override
  _ChartTabState createState() => _ChartTabState();
}

class _ChartTabState extends State<ChartTab> {
  final SupabaseClient _supabase = SupabaseClientInstance.client;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.selectedMonth;
  }

  Future<List<Map<String, dynamic>>> _fetchMonthlyTransactions() async {
    final response = await _supabase
        .from('transaction')
        .select('*, category(name, id, color)')
        .gte(
            'date',
            DateTime(_selectedMonth.year, _selectedMonth.month, 1)
                .toIso8601String())
        .lt(
            'date',
            DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1)
                .toIso8601String())
        .order('date', ascending: true);

    DateTime startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    DateTime endDate =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);

    // 모든 날짜를 포함하는 초기화
    List<Map<String, dynamic>> cumulativeData = [];
    double cumulativeSum = 0; // 누적합 초기화

    // 모든 날짜를 초기화하고 누적합을 설정
    for (DateTime date = startDate;
        date.isBefore(endDate);
        date = date.add(Duration(days: 1))) {
      // 날짜별 초기값 추가
      cumulativeData.add({
        'date': date.toIso8601String().split('T')[0], // 날짜만 사용
        'cumulativeAmount': 0, // 초기값은 0
        'category': '', // 초기 카테고리는 빈 문자열로 설정
        'color': Colors.transparent // 기본 색상은 투명
      });
    }

    if (response != null && response.isNotEmpty) {
      List<Map<String, dynamic>> transactions =
          List<Map<String, dynamic>>.from(response);

      // 누적합 계산
      for (var transaction in transactions) {
        String dateString =
            DateTime.parse(transaction['date']).toIso8601String().split('T')[0];
        double amount = transaction['amount'].toDouble();

        // 누적합 업데이트
        cumulativeSum += amount;

        // 해당 날짜의 누적합 업데이트
        var dataPoint =
            cumulativeData.firstWhere((data) => data['date'] == dateString);
        dataPoint['cumulativeAmount'] = cumulativeSum; // 누적합 업데이트
        dataPoint['category'] = transaction['category']['name']; // 카테고리 업데이트
        dataPoint['color'] = transaction['category']['color']; // 색상 업데이트
      }

      // 거래가 없는 날짜에 누적합을 전날과 동일하게 설정
      for (int i = 1; i < cumulativeData.length; i++) {
        if (cumulativeData[i]['cumulativeAmount'] == 0) {
          cumulativeData[i]['cumulativeAmount'] =
              cumulativeData[i - 1]['cumulativeAmount']; // 이전 날짜의 누적합을 사용
        }
      }

      return cumulativeData;
    } else {
      return cumulativeData; // 거래가 없으면 누적 데이터 리스트 반환
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCategorySummary() async {
    final response = await _supabase
        .from('transaction')
        .select('amount, category(name, id, color)')
        .gte(
            'date',
            DateTime(_selectedMonth.year, _selectedMonth.month, 1)
                .toIso8601String())
        .lt(
            'date',
            DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1)
                .toIso8601String());

    if (response != null && response.isNotEmpty) {
      Map<String, dynamic> categorySummary = {};

      for (var transaction in response) {
        String categoryName = transaction['category']['name'];
        String categoryId = transaction['category']['id'].toString();
        String categoryColor = transaction['category']['color'];
        int amount = transaction['amount'];

        if (categorySummary.containsKey(categoryId)) {
          categorySummary[categoryId]['amount'] += amount;
        } else {
          categorySummary[categoryId] = {
            'name': categoryName,
            'amount': amount,
            'color': categoryColor,
          };
        }
      }

      return categorySummary.values
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } else {
      return [];
    }
  }

  void _changeMonth(int months) {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + months, 1);
      widget.onMonthChange(_selectedMonth);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMMM().format(_selectedMonth)),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => _changeMonth(-1),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchMonthlyTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return Center(child: Text('데이터를 추가해주세요'));
            } else {
              final transactions = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SfCartesianChart(
                      primaryXAxis: DateTimeAxis(
                        intervalType: DateTimeIntervalType.days,
                        dateFormat: DateFormat.d(),
                        interval: 1,
                      ),
                      // tooltipBehavior: TooltipBehavior(
                      //   enable: true,
                      //   activationMode:
                      //       ActivationMode.singleTap, // 클릭(또는 터치) 시에만 툴팁 활성화
                      //   tooltipPosition: TooltipPosition.auto,
                      //   header: 'point.x',
                      //   format: '누적합: point.y 원', // 툴팁 내용 커스텀
                      // ), // 툴팁 활성화
                      series: <ChartSeries>[
                        LineSeries<Map<String, dynamic>, DateTime>(
                          dataSource: transactions,
                          xValueMapper: (transaction, _) =>
                              DateTime.parse(transaction['date']),
                          yValueMapper: (transaction, _) =>
                              transaction['cumulativeAmount'],
                          markerSettings: MarkerSettings(isVisible: true),
                          // dataLabelSettings: DataLabelSettings(isVisible: true),
                        ),
                      ],
                    ),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _fetchCategorySummary(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          final categoryData = snapshot.data!;
                          if (categoryData.isEmpty) {
                            return Center(child: Text('카테고리 데이터를 추가해주세요'));
                          } else {
                            return SfCircularChart(
                              title: ChartTitle(text: '카테고리 별 금액 비율'),
                              legend: Legend(isVisible: true),
                              series: <CircularSeries>[
                                PieSeries<Map<String, dynamic>, String>(
                                  dataSource: categoryData,
                                  xValueMapper: (data, _) => data['name'],
                                  yValueMapper: (data, _) => data['amount'],
                                  pointColorMapper: (data, _) =>
                                      transColor(data['color']),
                                  dataLabelSettings: DataLabelSettings(
                                      isVisible: true,
                                      labelPosition:
                                          ChartDataLabelPosition.outside),
                                ),
                              ],
                            );
                          }
                        } else {
                          return Center(
                              child: Text('No category data available'));
                        }
                      },
                    ),
                  ],
                ),
              );
            }
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
