import 'package:flutter/material.dart';
import 'package:financial_app/screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  // final _supabase = SupabaseClientInstance.client;
  // final session = _supabase.auth.currentSession;
  // runApp(MyApp(isLoggedIn: session != null));
  runApp(MaterialApp(
    home: LoginScreen(),
    // theme: ThemeData(
    //   colorScheme: ColorScheme.fromSeed(
    //     primary: Color(0xff191A45),
    //     secondary: Color(0xffF5F2B8),
    //     seedColor: Color(0xff191A45),
    //   ),
    //   // useMaterial3: true,
    // ),
  ));

  // runApp(
  //   MaterialApp.router(
  //     routerConfig: GoRouter(routes: [
  //       GoRoute(path: '/', name: 'home', builder: (context, _) => MyApp(isLoggedIn: session != null),)
  //       GoRoute(path: '/', name: 'home', builder: (context, _) => MyApp(isLoggedIn: session != null),)
  //     ]),
  //   )
  // )
}
