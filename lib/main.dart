import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/main_scaffold.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'core/services/api_services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Test API connection
  testAPIConnection();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const DiabetaApp());
}

// Add this test function
void testAPIConnection() async {
  try {
    final client = ApiClient();
    final response = await client.dio.get('/');
    print('✅ API Connected: ${response.statusCode}');
    print('Response: ${response.data}');
  } catch (e) {
    print('❌ API Error: $e');
  }
}

class DiabetaApp extends StatelessWidget {
  const DiabetaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DIABETA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScaffold(),
      },
    );
  }
}