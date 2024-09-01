import 'package:financial_app/screens/budget_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:financial_app/screens/login_screen.dart';
import 'package:financial_app/supabase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final _supabase = SupabaseClientInstance.client;
  final session = _supabase.auth.currentSession;
  runApp(MyApp(isLoggedIn: session != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isLoggedIn ? BudgetScreen() : LoginScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final SupabaseClient _supabase = SupabaseClientInstance.client;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('가계부 대시보드'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _supabase.auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text('대시보드 콘텐츠'),
      ),
    );
  }
}
