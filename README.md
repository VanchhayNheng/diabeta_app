# DIABETA - Flutter App

A modern diabetes management application with glassmorphism design, built with Flutter.

## 🎨 Design Features

- **Glassmorphism UI**: Beautiful frosted glass effects with blur and transparency
- **Gradient Backgrounds**: Smooth color transitions (purple to mint/pink)
- **Modern Animations**: Smooth transitions and micro-interactions
- **Clean Architecture**: Well-organized code structure
- **Ready for API**: Easy integration points for backend services

## 📱 Screens Implemented

### Core Features
1. **Splash Screen** - Animated intro with logo
2. **Home Dashboard** - Overview with stats and quick actions
3. **Blood Glucose Tracking** - Chart visualization and reading entry
4. **AI Assistant Chat** - Conversational health assistant
5. **Reports & Analytics** - Trends, insights, and statistics
6. **Settings & Profile** - User preferences and account management

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── models/         # Data models
│   │   └── models.dart # User, GlucoseReading, Medication, etc.
│   ├── theme/          # App theming
│   │   └── app_theme.dart
│   └── navigation/     # Navigation logic
│       └── main_scaffold.dart
├── features/           # Feature modules
│   ├── splash/
│   │   └── screens/
│   │       └── splash_screen.dart
│   ├── home/
│   │   └── screens/
│   │       └── home_screen.dart
│   ├── glucose/
│   │   └── screens/
│   │       └── glucose_tracking_screen.dart
│   ├── assistant/
│   │   └── screens/
│   │       └── assistant_screen.dart
│   ├── reports/
│   │   └── screens/
│   │       └── reports_screen.dart
│   └── settings/
│       └── screens/
│           └── settings_screen.dart
├── shared/
│   └── widgets/        # Reusable widgets
│       ├── glass_widgets.dart
│       └── bottom_nav_bar.dart
└── main.dart          # App entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio (recommended IDEs)

### Installation

1. **Clone or create the project**
   ```bash
   flutter create diabeta_app
   cd diabeta_app
   ```

2. **Copy all files to your project**
   - Copy the entire lib/ folder structure
   - Replace pubspec.yaml with the provided one

3. **Get dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Dependencies

### UI & Design
- `google_fonts` - Custom typography
- `flutter_svg` - SVG rendering
- `flutter_glassmorphism` - Glassmorphism effects

### State Management
- `provider` - State management (ready for your business logic)

### Charts & Visualization
- `fl_chart` - Beautiful charts for glucose tracking

### Navigation
- `go_router` - Modern routing (configured for future expansion)

### Storage
- `shared_preferences` - Local data persistence

### API (Ready for Integration)
- `dio` - HTTP client
- `http` - Alternative HTTP client

### Utilities
- `intl` - Date/time formatting
- `image_picker` - Photo selection
- `cached_network_image` - Image caching
- `uuid` - Unique ID generation

## 🔌 API Integration Points

The app is structured to easily integrate with your backend. Here are the main integration points:

### 1. Authentication
Create `lib/core/services/auth_service.dart`:
```dart
class AuthService {
  Future<User> login(String email, String password) async {
    // Call your API
    final response = await dio.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });
    return User.fromJson(response.data);
  }
}
```

### 2. Glucose Readings
Create `lib/core/services/glucose_service.dart`:
```dart
class GlucoseService {
  Future<List<GlucoseReading>> getReadings() async {
    final response = await dio.get('/api/glucose/readings');
    return (response.data as List)
        .map((json) => GlucoseReading.fromJson(json))
        .toList();
  }
  
  Future<GlucoseReading> addReading(GlucoseReading reading) async {
    final response = await dio.post('/api/glucose/readings', 
        data: reading.toJson());
    return GlucoseReading.fromJson(response.data);
  }
}
```

### 3. AI Assistant
Create `lib/core/services/ai_service.dart`:
```dart
class AIService {
  Future<String> sendMessage(String message, {String? imageUrl}) async {
    final response = await dio.post('/api/ai/chat', data: {
      'message': message,
      'imageUrl': imageUrl,
    });
    return response.data['reply'];
  }
}
```

## 📊 State Management Setup

The app uses Provider for state management. To add your business logic:

1. **Create a provider**
   ```dart
   // lib/core/providers/glucose_provider.dart
   class GlucoseProvider with ChangeNotifier {
     List<GlucoseReading> _readings = [];
     
     List<GlucoseReading> get readings => _readings;
     
     Future<void> loadReadings() async {
       _readings = await GlucoseService().getReadings();
       notifyListeners();
     }
     
     Future<void> addReading(GlucoseReading reading) async {
       final newReading = await GlucoseService().addReading(reading);
       _readings.add(newReading);
       notifyListeners();
     }
   }
   ```

2. **Register in main.dart**
   ```dart
   void main() {
     runApp(
       MultiProvider(
         providers: [
           ChangeNotifierProvider(create: (_) => GlucoseProvider()),
           ChangeNotifierProvider(create: (_) => UserProvider()),
         ],
         child: DiabetaApp(),
       ),
     );
   }
   ```

3. **Use in screens**
   ```dart
   class HomeScreen extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       final glucoseProvider = context.watch<GlucoseProvider>();
       
       return Text('Latest: ${glucoseProvider.readings.last.value}');
     }
   }
   ```

## 🎨 Customization

### Colors
Edit `lib/core/theme/app_theme.dart`:
```dart
static const Color primaryPurple = Color(0xFF667EEA);
static const Color secondaryPurple = Color(0xFF764BA2);
// Change these to your brand colors
```

### Typography
Already using Google Fonts (Inter). To change:
```dart
displayLarge: GoogleFonts.yourFont(
  fontSize: 56,
  fontWeight: FontWeight.w700,
),
```

### Glassmorphism Effect
Adjust in `lib/shared/widgets/glass_widgets.dart`:
```dart
GlassCard(
  opacity: 0.95,  // Glass transparency
  blur: 20,        // Blur amount
  child: ...
)
```

## 📱 Platform-Specific Setup

### Android
Update `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

### iOS
Update `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access for food photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access</string>
```

## 🔧 Development Tips

### 1. Hot Reload
Press `r` in terminal or save files in IDE for instant updates

### 2. Debug Mode
```bash
flutter run --debug
```

### 3. Build Release
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### 4. Testing
Add tests in `test/` folder:
```dart
void main() {
  test('Glucose reading in range check', () {
    final reading = GlucoseReading(
      id: '1',
      value: 120,
      timestamp: DateTime.now(),
      type: 'fasting',
    );
    expect(reading.isInRange, true);
  });
}
```

## 🐛 Common Issues & Solutions

### Issue: Glassmorphism not showing
**Solution**: Make sure you're using a device/emulator that supports blur effects

### Issue: Charts not displaying
**Solution**: Ensure fl_chart is properly installed:
```bash
flutter pub get
flutter clean
flutter pub get
```

### Issue: Google Fonts not loading
**Solution**: Check internet connection on first run (fonts are cached after)

## 📈 Next Steps

### Recommended Additions

1. **Authentication Flow**
   - Login screen
   - Registration flow
   - Password reset

2. **Medication Management**
   - Add/edit medications
   - Medication reminders
   - Adherence tracking

3. **Data Sync**
   - Backend integration
   - Offline support
   - Data backup

4. **Notifications**
   - Local notifications for reminders
   - Push notifications for insights

5. **Analytics**
   - More detailed reports
   - Export to PDF
   - Share with doctor

6. **Wearable Integration**
   - Apple Health
   - Google Fit
   - Continuous glucose monitors

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [FL Chart Examples](https://pub.dev/packages/fl_chart)
- [Material Design Guidelines](https://material.io/design)

## 🤝 Contributing

To add new features:

1. Create a new feature folder in `lib/features/`
2. Follow the existing pattern
3. Add screens in `screens/` subfolder
4. Use shared widgets from `lib/shared/widgets/`
5. Keep models in `lib/core/models/`

## 📄 License

This project is ready for your use. Customize as needed for your application.

## 💡 Support

For questions about:
- **Flutter setup**: Check Flutter docs
- **Design customization**: Refer to app_theme.dart
- **API integration**: See API Integration Points section above

---

**Built with ❤️ using Flutter**

Ready to revolutionize diabetes management!