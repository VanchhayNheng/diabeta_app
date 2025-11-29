# API Integration Guide

This guide will help you integrate your backend API with the DIABETA Flutter app.

## 📋 Quick Start

### 1. Configure Your API

Open `lib/core/services/api_services.dart` and update:

```dart
class ApiConfig {
  static const String baseUrl = 'https://your-api.com/api';  // ← Change this
  static const String apiKey = 'your-api-key-here';           // ← Add if needed
}
```

### 2. Test API Connection

Create a simple test:

```dart
// In your main.dart or a test file
void testAPI() async {
  try {
    final authService = AuthService();
    final result = await authService.login('test@email.com', 'password');
    print('API Connected: $result');
  } catch (e) {
    print('API Error: $e');
  }
}
```

## 🔌 Available Services

### AuthService
Handles user authentication:
- `login(email, password)` - User login
- `register(...)` - New user registration  
- `logout()` - User logout

### GlucoseService
Manages glucose readings:
- `getReadings()` - Fetch all readings
- `addReading(value, type, notes)` - Add new reading
- `deleteReading(id)` - Delete a reading
- `getStatistics()` - Get analytics data

### MedicationService
Handles medications:
- `getMedications()` - List all medications
- `addMedication(...)` - Add new medication
- `logMedication(id, takenAt)` - Log medication taken

### AIService
AI assistant features:
- `sendMessage(message, imageUrl)` - Chat with AI
- `getInsights()` - Get health insights

## 🔄 Integration Steps

### Step 1: Replace Mock Data with Real API

**Example: Home Screen**

Before (mock data):
```dart
// HomeScreen currently shows static data
Text('145') // Static glucose value
```

After (with API):
```dart
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _glucoseService = GlucoseService();
  List<GlucoseReading> _readings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _glucoseService.getReadings();
      setState(() {
        _readings = data.map((json) => GlucoseReading.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final latestReading = _readings.isNotEmpty ? _readings.last : null;
    
    return Container(
      // ... rest of UI
      Text(latestReading?.value.toString() ?? '--')
    );
  }
}
```

### Step 2: Add Provider for State Management

Create `lib/core/providers/glucose_provider.dart`:

```dart
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_services.dart';

class GlucoseProvider with ChangeNotifier {
  final _service = GlucoseService();
  
  List<GlucoseReading> _readings = [];
  bool _isLoading = false;
  String? _error;

  List<GlucoseReading> get readings => _readings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  GlucoseReading? get latestReading => 
      _readings.isNotEmpty ? _readings.last : null;
  
  double get averageGlucose {
    if (_readings.isEmpty) return 0;
    final sum = _readings.fold(0.0, (sum, reading) => sum + reading.value);
    return sum / _readings.length;
  }

  Future<void> loadReadings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _service.getReadings();
      _readings = data
          .map((json) => GlucoseReading.fromJson(json))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReading(double value, String type, {String? notes}) async {
    try {
      final data = await _service.addReading(
        value: value,
        type: type,
        notes: notes,
      );
      
      final newReading = GlucoseReading.fromJson(data);
      _readings.add(newReading);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteReading(String id) async {
    try {
      await _service.deleteReading(id);
      _readings.removeWhere((reading) => reading.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
```

### Step 3: Register Providers in main.dart

```dart
import 'package:provider/provider.dart';
import 'core/providers/glucose_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GlucoseProvider()),
        // Add more providers as needed
      ],
      child: DiabetaApp(),
    ),
  );
}
```

### Step 4: Use Provider in Screens

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Load data when screen first opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GlucoseProvider>().loadReadings();
    });

    return Consumer<GlucoseProvider>(
      builder: (context, glucoseProvider, child) {
        if (glucoseProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (glucoseProvider.error != null) {
          return Center(
            child: Text('Error: ${glucoseProvider.error}'),
          );
        }

        return Container(
          // ... UI with real data
          Text(glucoseProvider.latestReading?.value.toString() ?? '--'),
          Text('Average: ${glucoseProvider.averageGlucose.toStringAsFixed(1)}'),
        );
      },
    );
  }
}
```

## 🔐 Authentication Flow

### 1. Add Authentication Check

Update `main.dart`:

```dart
class DiabetaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<bool>(
        future: _checkAuth(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          }
          
          final isAuthenticated = snapshot.data ?? false;
          return isAuthenticated ? MainScaffold() : LoginScreen();
        },
      ),
    );
  }

  Future<bool> _checkAuth() async {
    // Check if user has valid token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }
}
```

### 2. Create Login Screen

```dart
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    
    try {
      await _authService.login(
        _emailController.text,
        _passwordController.text,
      );
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScaffold()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GlassTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),
                GlassTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                ),
                SizedBox(height: 30),
                GradientButton(
                  text: 'Login',
                  onPressed: _login,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## 📊 Real-time Updates

### Using StreamBuilder for Live Data

```dart
class GlucoseTrackingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GlucoseReading>>(
      stream: GlucoseService().readingsStream(), // Your API stream
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final readings = snapshot.data!;
          return _buildChart(readings);
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

## 🔔 Push Notifications Setup

### 1. Add Firebase Messaging

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
```

### 2. Initialize Firebase

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Request permission
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  
  // Get device token
  final token = await messaging.getToken();
  print('FCM Token: $token');
  // Send this token to your backend
  
  runApp(DiabetaApp());
}
```

## 🧪 Testing Your Integration

### 1. Unit Tests

```dart
// test/services/glucose_service_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GlucoseService', () {
    test('fetches readings successfully', () async {
      final service = GlucoseService();
      final readings = await service.getReadings();
      expect(readings, isNotEmpty);
    });

    test('adds reading successfully', () async {
      final service = GlucoseService();
      final reading = await service.addReading(
        value: 120,
        type: 'fasting',
      );
      expect(reading['value'], 120);
    });
  });
}
```

### 2. Integration Tests

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full app flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Test login
    await tester.enterText(find.byType(TextField).first, 'test@email.com');
    await tester.enterText(find.byType(TextField).last, 'password');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify home screen loaded
    expect(find.text('Hello,'), findsOneWidget);
  });
}
```

## 📱 Offline Support

### Using Hive for Local Storage

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
```

```dart
class GlucoseProvider with ChangeNotifier {
  final _box = Hive.box('glucose_readings');

  Future<void> loadReadings() async {
    try {
      // Try API first
      final data = await _service.getReadings();
      _readings = data.map((json) => GlucoseReading.fromJson(json)).toList();
      
      // Cache locally
      await _box.put('readings', _readings);
    } catch (e) {
      // Fallback to cache if offline
      final cached = _box.get('readings');
      if (cached != null) {
        _readings = cached;
      }
    }
    notifyListeners();
  }
}
```

## 🚀 Production Checklist

- [ ] Replace `ApiConfig.baseUrl` with production URL
- [ ] Add proper error handling for all API calls
- [ ] Implement authentication token refresh
- [ ] Add loading states to all data fetching
- [ ] Test on slow network connections
- [ ] Implement offline data caching
- [ ] Add retry logic for failed requests
- [ ] Set up crash reporting (Firebase Crashlytics)
- [ ] Add analytics tracking
- [ ] Test with real API data
- [ ] Implement proper logout flow
- [ ] Add data sync indicators

## 📞 Need Help?

If you encounter issues:
1. Check API service console logs
2. Verify API endpoint URLs
3. Test API with Postman first
4. Check network permissions in AndroidManifest.xml / Info.plist
5. Ensure CORS is configured on your backend

---

**You're ready to integrate your backend!** 🎉