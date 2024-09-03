import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart'; // 차트 라이브러리 사용
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:financial_app/supabase.dart';

class ChartView extends StatefulWidget {
  @override
  _ChartViewState createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {
  final SupabaseClient _supabase = SupabaseClientInstance.client;
  DateTime _selectedMonth = DateTime.now();

  Future<List<dynamic>> _fetchMonthlyTransactions() async {
    // 특정 월의 거래 내역을 가져오는 로직
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
                .toIso8601String());

    if (!response.isEmpty) {
      return response;
    } else {
      throw Exception('Failed to fetch transactions');
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
      body: FutureBuilder<List<dynamic>>(
        future: _fetchMonthlyTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final transactions = snapshot.data!;
            // 차트로 데이터를 시각화
            return SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              series: <ChartSeries>[
                ColumnSeries<dynamic, String>(
                  dataSource: transactions,
                  xValueMapper: (transaction, _) =>
                      transaction['date'].substring(8, 10), // 날짜
                  yValueMapper: (transaction, _) => transaction['amount'], // 금액
                ),
              ],
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
