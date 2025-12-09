import 'package:flutter/material.dart';

import '../../features/assistant/screens/assistant_screen.dart';
import '../../features/settings/screens/GlucoseScreen.dart';
import '../../features/settings/screens/exercise_log_screeen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/medication_screen.dart';
import '../../features/settings/screens/meal_log_screen.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  // Create GlobalKeys to access the state of each screen
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _assistantKey = GlobalKey();
  final GlobalKey _reportsKey = GlobalKey();
  final GlobalKey _settingsKey = GlobalKey();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        key: _homeKey,
        onNavigateToAssistant: () => setState(() => _currentIndex = 1),
        onNavigateToMedications: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => MedicationScreen(),
          ));
        },
        onNavigateToMealLog: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => MealLogScreen(),
          ));
        },
        onNavigateToExercise: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => ExerciseLogScreen(),
          ));
        },
        onNavigateToGlucose: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GlucoseScreen(),
            ),
          );

          // Refresh home screen if data was added
          if (result == true) {
            (_homeKey.currentState as dynamic)?.refresh();
          }
        },
      ),
      AssistantScreen(key: _assistantKey),
      ReportsScreen(key: _reportsKey),
      SettingsScreen(key: _settingsKey),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      // If switching from settings (index 3) to home (index 0), refresh home screen
      if (_currentIndex == 3 && index == 0) {
        // Cast to dynamic and call refresh method
        (_homeKey.currentState as dynamic)?.refresh();
      }
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}