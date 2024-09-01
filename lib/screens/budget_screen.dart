import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:financial_app/supabase.dart';
import 'package:financial_app/utils/auth.dart';

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final SupabaseClient _supabase = SupabaseClientInstance.client;

  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _selectedDate
            .toLocal()
            .toString()
            .split(' ')[0]; // YYYY-MM-DD 형식으로 표시
      });
    }
  }

  Future<void> _addTransaction() async {
    final description = _descriptionController.text;
    final amount = double.tryParse(_amountController.text) ?? 0;
    final date = DateTime.tryParse(_dateController.text) ?? DateTime.now();

    if (description.isNotEmpty && amount > 0) {
      final response = await _supabase.from('transaction').insert({
        'description': description,
        'amount': amount.toInt(),
        'date': date.toIso8601String(),
      });

      if (response.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('transaction added successfully!')),
        );
        _descriptionController.clear();
        _amountController.clear();
        _dateController.clear();
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to add transaction: ${response.error?.message}')),
        );
      }
    }
  }

  Future<List<dynamic>> _fetchTransactions() async {
    final response = await _supabase.from('transaction').select();

    if (!response.isEmpty) {
      print(response);
      return response;
    } else {
      throw Exception('Failed to fetch transactions: 알 수 없는 오류 발생');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount'),
            ),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Date (YYYY-MM-DD)',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addTransaction,
              child: Text('Add transaction'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _fetchTransactions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final expenses = snapshot.data!;
                    return ListView.builder(
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        return ListTile(
                          title: Text(expense['description']),
                          subtitle:
                              Text('${expense['amount']} - ${expense['date']}'),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text('No expenses found'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
