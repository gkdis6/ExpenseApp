import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:financial_app/supabase.dart';

class RegistrationScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SupabaseClient _supabase = SupabaseClientInstance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  final AuthResponse response = await _supabase.auth.signUp(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );

                  if (response.user != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('회원가입 성공! 이제 로그인하세요.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('회원가입 실패: 알 수 없는 오류가 발생했습니다.')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('회원가입 실패: ${e.toString()}')),
                  );
                }
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
