import 'package:financial_app/utils/common.dart';
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

    final categories = response.map((item) => item['category']).toList();

    final distinctCategories = categories.fold<List<Map<String, dynamic>>>(
      [],
      (accumulator, current) {
        // 중복 여부를 체크하고 없으면 추가
        if (!accumulator.any((item) => item['id'] == current['id'])) {
          accumulator.add(current);
        }
        return accumulator;
      },
    );
    print(distinctCategories);

    Map<String, Map<String, int>> cumulativeByDateAndCategory = {};
    DateTime startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    DateTime endDate =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    List<Map<String, dynamic>> cumulativeData = [];

    if (response != null && response.isNotEmpty) {
      List<Map<String, dynamic>> transactions =
          List<Map<String, dynamic>>.from(response);

      Map<String, int> categoryTotals = {};

      for (DateTime date = startDate;
          date.isBefore(endDate);
          date = date.add(Duration(days: 1))) {
        String dateString = date.toIso8601String().split('T')[0];
        cumulativeByDateAndCategory[dateString] = {};

        // 해당 날짜에 있는 모든 거래를 누적합에 반영
        for (var transaction in transactions.where((txn) =>
            DateTime.parse(txn['date']).toIso8601String().split('T')[0] ==
            dateString)) {
          String findCategory = transaction['category']['name'];
          int findAmount = transaction['amount'];
          // String findColor = transaction['category']['color'];

          // 누적합 계산
          categoryTotals[findCategory] =
              (categoryTotals[findCategory] ?? 0) + findAmount;

          var existingData = cumulativeData.firstWhere(
            (data) =>
                data['date'] == dateString && data['category'] == findCategory,
            orElse: () => {},
          );

          if (existingData.length > 0) {
            // 이미 있는 경우 누적 금액만 업데이트
            existingData['cumulativeAmount'] = categoryTotals[findCategory];
          } else {
            // 새로 추가
            // cumulativeData.add({
            //   'date': dateString,
            //   'category': findCategory,
            //   'cumulativeAmount': categoryTotals[findCategory],
            //   'color': findColor,
            // });
          }
        }

        for (var category in distinctCategories) {
          String categoryName = category['name'];
          String categoryColor = category['color'];
          cumulativeData.add({
            'date': dateString,
            'category': categoryName,
            'cumulativeAmount': categoryTotals[categoryName] ?? 0,
            'color': categoryColor,
          });
        }
        //
      }

      // print(cumulativeData);
      return cumulativeData;
    } else {
      return [];
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
        // title: Text(_selectedMonth.formattedYearMonth),
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
            final cumulativeData = snapshot.data!;
            if (cumulativeData.isEmpty) {
              return Center(child: Text('데이터를 추가해주세요'));
            } else {
              // 카테고리별로 나눠서 LineSeries 생성
              List<Map<String, dynamic>> categories = [];
              for (var data in cumulativeData) {
                print(data);
                if (!categories
                    .any((item) => item['category'] == data['category'])) {
                  categories.add(
                      {'category': data['category'], 'color': data['color']});
                }
              }

              final transactions = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SfCartesianChart(
                      legend: Legend(
                        isVisible: true,
                        toggleSeriesVisibility:
                            true, // 범례를 클릭하여 시리즈를 숨기거나 표시할 수 있음
                      ),
                      primaryXAxis: DateTimeAxis(
                        intervalType: DateTimeIntervalType.days,
                        dateFormat: DateFormat.d(),
                        interval: 1,
                      ),
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                        activationMode:
                            ActivationMode.singleTap, // 클릭(또는 터치) 시에만 툴팁 활성화
                        tooltipPosition: TooltipPosition.auto,
                        header: '',
                        format: 'point.y 원', // 툴팁 내용 커스텀
                      ), // 툴팁 활성화
                      series: <StackedAreaSeries<Map<String, dynamic>,
                          DateTime>>[
                        for (var category in categories)
                          StackedAreaSeries<Map<String, dynamic>, DateTime>(
                            name: category['category'],
                            color: transColor(category['color']),
                            dataSource: cumulativeData
                                .where((data) =>
                                    data['category'] == category['category'])
                                .toList(),
                            xValueMapper: (data, _) =>
                                DateTime.parse(data['date']),
                            yValueMapper: (data, _) => data['cumulativeAmount'],
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
