import 'dart:convert';
import 'dart:ui';
import 'package:diabeta_app/features/settings/screens/GlucoseScreen.dart';
import 'package:diabeta_app/features/settings/screens/report_issue_screen.dart';
import 'package:diabeta_app/features/settings/screens/user_information_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_widgets.dart';
import 'about_us_screen.dart';
import 'exercise_log_screeen.dart';
import 'health_information_screen.dart';
import 'meal_log_screen.dart';
import 'medication_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSigningOut = false;
  bool _isLoading = true;
  Map<String, dynamic>? _userProfile;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _navigateToUserInfo() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserInformationScreen(),
      ),
    );

    // Refresh profile info when returning
    if (result == true || mounted) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('user_profile');

      if (profileJson == null) {
        throw Exception('Profile not found. Please login again.');
      }

      // Parse stored profile
      final profile = Map<String, dynamic>.from(
        jsonDecode(profileJson) as Map,
      );

      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSignOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => _buildSignOutDialog(),
    );

    if (shouldSignOut == true) {
      setState(() => _isSigningOut = true);

      try {
        final authService = AuthService();
        await authService.logout();
      } catch (e) {
        // Ignore - still clear local data
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }

      setState(() => _isSigningOut = false);
    }
  }

  Widget _buildSignOutDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: AppTheme.radiusXL,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: AppTheme.radiusXL,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: AppTheme.elevation3,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.1),
                    borderRadius: AppTheme.radiusMedium,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppTheme.errorRed,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Sign Out',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to sign out of your account?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        borderRadius: AppTheme.radiusMedium,
                        child: InkWell(
                          onTap: () => Navigator.pop(context, false),
                          borderRadius: AppTheme.radiusMedium,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            child: Text(
                              'Cancel',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed,
                          borderRadius: AppTheme.radiusMedium,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(context, true),
                            borderRadius: AppTheme.radiusMedium,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              alignment: Alignment.center,
                              child: Text(
                                'Sign Out',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryPurple,
            ),
          )
              : _errorMessage != null
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppTheme.errorRed,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load profile',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    text: 'Retry',
                    onPressed: _loadUserProfile,
                  ),
                ],
              ),
            ),
          )
              : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Header
                  Text(
                    'Profile',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),

                  const SizedBox(height: 24),

                  // Profile Card
                  GlassCard(
                    child: Row(
                      children: [
                        // Profile Image
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: AppTheme.radiusLarge,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: AppTheme.elevation1,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(17),
                            child: Image.network(
                              'https://api.dicebear.com/7.x/avataaars/png?seed=${_userProfile?['full_name'] ?? 'User'}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppTheme.textTertiary.withOpacity(0.2),
                                  child: const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: AppTheme.textSecondary,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userProfile?['full_name'] ?? 'User',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _userProfile?['email'] ?? '',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryPurple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppTheme.primaryPurple.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      '${_userProfile?['age'] ?? 'N/A'} years old',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppTheme.primaryPurple,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (_userProfile?['a1c'] != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.successGreen.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppTheme.successGreen.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        'A1C: ${_userProfile?['a1c']}%',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: AppTheme.successGreen,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // My Log Section
                  Text(
                    'My Log',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _buildSettingsItem(
                          icon: '🩸',
                          title: 'Glucose',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GlucoseScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildSettingsItem(
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
                        _buildDivider(),
                        _buildSettingsItem(
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
                        _buildDivider(),
                        _buildSettingsItem(
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
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Account Settings Section
                  Text(
                    'Account Settings',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  GlassCard(
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

                  const SizedBox(height: 24),

                  // Sign Out Button
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: _buildSignOutButton(),
                  ),

                  const SizedBox(height: 16),

                  // App Version
                  Center(
                    child: Text(
                      'DIABETA v1.0.0',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textTertiary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 1,
        color: AppTheme.textTertiary.withOpacity(0.2),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isSigningOut ? null : _handleSignOut,
        borderRadius: AppTheme.radiusXL,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.1),
                  borderRadius: AppTheme.radiusSmall,
                ),
                child: _isSigningOut
                    ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.errorRed,
                  ),
                )
                    : const Icon(
                  Icons.logout_rounded,
                  color: AppTheme.errorRed,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Sign Out',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.errorRed,
                  ),
                ),
              ),
              if (!_isSigningOut)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.errorRed,
                  size: 24,
                ),
            ],
          ),
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