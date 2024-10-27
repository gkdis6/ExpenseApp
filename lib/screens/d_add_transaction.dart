import 'package:financial_app/utils/supabase.dart';
import 'package:financial_app/utils/trans.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddTransactionDialog extends StatefulWidget {
  @override
  _AddTransactionDialogState createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final SupabaseClient _supabase = SupabaseClientInstance.client;
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategory;

  DateTime _selectedDate = DateTime.now();

  void initState() {
    super.initState();
    _fetchCategories(); // 카테고리 불러오기
  }

  Future<void> _fetchCategories() async {
    final user = _supabase.auth.currentUser;
    final userId = user?.id; // 현재 사용자의 user_id
    final response = await _supabase
        .from('category')
        .select()
        .eq('user_id', userId as String);
    if (response.isNotEmpty) {
      setState(() {
        _categories = response;
        _selectedCategory =
            _categories[0]['id'].toString(); // 첫 번째 카테고리 ID를 초기값으로 설정
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch categories: $response')),
      );
    }
  }

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

    if (description.isNotEmpty && amount > 0 && _selectedCategory != null) {
      final response = await _supabase.from('transaction').insert({
        'description': description,
        'amount': amount.toInt(),
        'date': date.toIso8601String(),
        'category_id': _selectedCategory, // 선택된 카테고리 ID 추가
      });

      if (response.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction added successfully!')),
        );
        Navigator.pop(context); // 등록 후 이전 화면으로 돌아감
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to add transaction: ${response.error?.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Transaction'),
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
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: Text("Select Category"),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['id'].toString(), // 카테고리의 ID를 사용
                  child: Row(
                    children: [
                      Container(
                        width: 12, // 원의 너비
                        height: 12, // 원의 높이
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: transColor(category['color']), // 색상을 표시
                        ),
                      ),
                      SizedBox(width: 8), // 아이템 간 간격
                      Text(category['name']), // 카테고리 이름 표시
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
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
          ],
        ),
      ),
    );
  }
}
