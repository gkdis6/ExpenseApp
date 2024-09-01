import 'package:financial_app/screens/user_registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:financial_app/supabase.dart';
import 'package:financial_app/screens/budget_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final SupabaseClient _supabase = SupabaseClientInstance.client;

  Future<void> _login() async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.session != null) {
        // 로그인 성공 시 대시보드로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BudgetScreen()),
        );
      } else {
        // 로그인 실패 시 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: 로그인에 실패했습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: ${e.toString()}')),
      );
    }
  }

  Future<void> _signUp() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => RegistrationScreen()),
    );
  }

  Future<void> _logout() async {
    try {
      await _supabase.auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃 실패: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              child: Text('로그인'),
            ),
            ElevatedButton(
              onPressed: _signUp,
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
