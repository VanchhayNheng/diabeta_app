import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../../../shared/widgets/profile_avatar.dart';

// Import all the screens
import '../service/user_data_service.dart';
import 'user_information_screen.dart';
import 'medication_screen.dart';
import 'meal_log_screen.dart';
import 'exercise_log_screeen.dart';
import 'health_information_screen.dart';
import 'report_issue_screen.dart';
import 'about_us_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  final _userDataService = UserDataService();
  String _userName = 'Nick Wilde';
  String _userEmail = 'nick.w@email.com';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfileInfo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reload profile info when app resumes
    if (state == AppLifecycleState.resumed) {
      _loadProfileInfo();
    }
  }

  /// Load user profile information from API
  Future<void> _loadProfileInfo() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final profileInfo = await _userDataService.getProfileBasicInfo();

      if (!mounted) return;

      setState(() {
        _userName = profileInfo['name'] ?? 'Nick Wilde';
        _userEmail = profileInfo['email'] ?? 'nick.w@email.com';
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading profile info: $e');

      if (!mounted) return;

      setState(() {
        _userName = 'Nick Wilde'; // Fallback
        _userEmail = 'nick.w@email.com'; // Fallback
        _isLoading = false;
      });
    }
  }

  /// Navigate to user information screen and refresh on return
  Future<void> _navigateToUserInfo() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserInformationScreen(),
      ),
    );

    // Refresh profile info when returning from the screen
    // Also check if result indicates data was updated
    if (result == true || mounted) {
      _loadProfileInfo();
    }
  }

  /// Public method to refresh profile from outside
  void refresh() {
    _loadProfileInfo();
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
                child: Text(
                  'Profile',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            ),

            // Profile Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: _isLoading
                      ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                      : Row(
                    children: [
                      const ProfileAvatar(
                        size: 80,
                        editable: true,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userEmail,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '⭐ Premium',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // My Log Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Log',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      _SettingItem(
                        icon: '💊',
                        title: 'Your Medication',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MedicationScreen(),
                            ),
                          );
                        },
                      ),
                      _SettingItem(
                        icon: '🥗',
                        title: 'Meal Log',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MealLogScreen(),
                            ),
                          );
                        },
                      ),
                      _SettingItem(
                        icon: '🏃',
                        title: 'Exercise',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ExerciseLogScreen(),
                            ),
                          );
                        },
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Account Settings
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Settings',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      _SettingItem(
                        icon: '👤',
                        title: 'Your Information',
                        onTap: _navigateToUserInfo,
                      ),
                      _SettingItem(
                        icon: '📋',
                        title: 'Health Information',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HealthInformationScreen(),
                            ),
                          );
                        },
                      ),
                      _SettingItem(
                        icon: '⚠️',
                        title: 'Report an Issue',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReportIssueScreen(),
                            ),
                          );
                        },
                      ),
                      _SettingItem(
                        icon: 'ℹ️',
                        title: 'About Us',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutUsScreen(),
                            ),
                          );
                        },
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  const _SettingItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.showDivider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.textTertiary,
                ),
              ],
            ),
          ),
        ),
        if (showDivider) const SizedBox(height: 12),
      ],
    );
  }
}