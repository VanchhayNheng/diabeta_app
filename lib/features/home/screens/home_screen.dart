import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../../../shared/widgets/profile_avatar.dart';
import '../../settings/service/user_data_service.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToAssistant;
  final VoidCallback? onNavigateToMedications;

  final VoidCallback? onNavigateToMealLog;

  final VoidCallback? onNavigateToExercise;

  const HomeScreen({super.key, this.onNavigateToAssistant, this.onNavigateToMedications, this.onNavigateToMealLog, this.onNavigateToExercise});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _userDataService = UserDataService();
  String _userName = 'Nick';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserName();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reload when app comes to foreground or when screen becomes visible
    if (state == AppLifecycleState.resumed) {
      _loadUserName();
    }
  }

  /// Load user name from local storage
  Future<void> _loadUserName() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    final profileInfo = await _userDataService.getProfileBasicInfo();

    if (!mounted) return;

    setState(() {
      // Extract first name only for the greeting
      final fullName = profileInfo['name'] ?? 'Nick Wilde';
      _userName = fullName.split(' ').first;
      _isLoading = false;
    });
  }

  /// Public method to refresh the screen from outside
  void refresh() {
    _loadUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _isLoading
                        ? Text(
                      'Hello 👋',
                      style: Theme.of(context).textTheme.displaySmall,
                    )
                        : Text(
                      'Hello, $_userName 👋',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const ProfileAvatar(
                      size: 44,
                      editable: false, // Not editable in home screen
                    ),
                  ],
                ),
              ),
            ),

            // Alert Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: AppTheme.radiusXL,
                    boxShadow: AppTheme.primaryShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📊 Check Your Glucose',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'It\'s been 4 hours since your last reading',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: widget.onNavigateToAssistant ?? () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.95),
                          foregroundColor: AppTheme.primaryPurple,
                          elevation: 0,
                        ),
                        child: const Text('Check Now'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Today's Overview
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Overview',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: const [
                          Expanded(
                            child: StatCard(
                              icon: '📊',
                              value: '145',
                              label: 'mg/dL',
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              icon: '🎯',
                              value: '3',
                              label: 'Readings',
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              icon: '📈',
                              value: '92%',
                              label: 'In Range',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 140,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          QuickActionCard(
                            icon: '💊',
                            title: 'Medications',
                            badge: '2 pending',
                            onTap: widget.onNavigateToMedications ?? () {},
                          ),
                          const SizedBox(width: 10),
                          QuickActionCard(
                            icon: '🥗',
                            title: 'Meal Log',
                            onTap: widget.onNavigateToMealLog ?? () {},
                          ),
                          const SizedBox(width: 10),
                          QuickActionCard(
                            icon: '🏃',
                            title: 'Exercise',
                            onTap: widget.onNavigateToExercise ?? () {},
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}