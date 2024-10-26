// utils/auth.dart
import 'package:financial_app/screens/f_login.dart';
import 'package:financial_app/utils/supabase.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> logout(BuildContext context) async {
  final SupabaseClient _supabase = SupabaseClientInstance.client;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');

    await _supabase.auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginFragment()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('로그아웃 실패: ${e.toString()}')),
    );
  }
}
