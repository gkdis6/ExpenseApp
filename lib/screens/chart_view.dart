import 'package:financial_app/utils/supabase.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartView extends StatefulWidget {
  @override
  _ChartViewState createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {
  final SupabaseClient _supabase = SupabaseClientInstance.client;
  DateTime _selectedMonth = DateTime.now();

  Future<List<Map<String, dynamic>>> _fetchMonthlyTransactions() async {
    final response = await _supabase
        .from('transaction')
        .select()
        .gte(
            'date',
            DateTime(_selectedMonth.year, _selectedMonth.month, 1)
                .toIso8601String())
        .lt(
            'date',
            DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1)
                .toIso8601String())
        .order('date', ascending: true);

    if (response != null && response.isNotEmpty) {
      List<Map<String, dynamic>> transactions =
          List<Map<String, dynamic>>.from(response);

      // 누적합 계산
      double cumulativeSum = 0;
      for (var transaction in transactions) {
        cumulativeSum += transaction['amount'];
        transaction['cumulativeAmount'] = cumulativeSum;
      }

      return transactions;
    } else {
      return []; // 데이터가 없으면 빈 리스트 반환
    }
  }

  void _changeMonth(int months) {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + months, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Monthly Overview"),
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
              return Center(child: Text('No data available'));
            } else {
              final transactions = snapshot.data!;
              return SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  intervalType: DateTimeIntervalType.days,
                  dateFormat: DateFormat.d(),
                  interval: 1,
                ),
                series: <ChartSeries>[
                  LineSeries<Map<String, dynamic>, DateTime>(
                    dataSource: transactions,
                    xValueMapper: (transaction, _) =>
                        DateTime.parse(transaction['date']),
                    yValueMapper: (transaction, _) =>
                        transaction['cumulativeAmount'],
                    markerSettings: MarkerSettings(isVisible: true),
                  ),
                ],
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
