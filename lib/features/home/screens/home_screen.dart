import 'package:flutter/material.dart';

import '../../../core/services/api_services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../../../shared/widgets/profile_avatar.dart';
import '../../settings/service/user_data_service.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToAssistant;
  final VoidCallback? onNavigateToMedications;
  final VoidCallback? onNavigateToMealLog;
  final VoidCallback? onNavigateToExercise;

  const HomeScreen({
    super.key,
    this.onNavigateToAssistant,
    this.onNavigateToMedications,
    this.onNavigateToMealLog,
    this.onNavigateToExercise
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _userDataService = UserDataService();
  final _glucoseService = GlucoseService();

  String _userName = 'Nick';
  bool _isLoading = true;
  bool _isLoadingStats = true;

  // Glucose stats from API
  double _averageGlucose = 145;
  int _readingsCount = 3;
  double _inRangePercentage = 92;
  int _latestReading = 145;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserName();
    _loadTodayStats();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUserName();
      _loadTodayStats();
    }
  }

  /// Load user name from local storage
  Future<void> _loadUserName() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    final profileInfo = await _userDataService.getProfileBasicInfo();

    if (!mounted) return;

    setState(() {
      final fullName = profileInfo['name'] ?? 'Nick Wilde';
      _userName = fullName.split(' ').first;
      _isLoading = false;
    });
  }

  /// Load today's glucose statistics from API
  Future<void> _loadTodayStats() async {
    if (!mounted) return;

    setState(() {
      _isLoadingStats = true;
      _errorMessage = null;
    });

    try {
      final userId = await _userDataService.getUserId();
      final stats = await _glucoseService.getTodayStats(userId: userId);

      if (!mounted) return;

      setState(() {
        _averageGlucose = stats['average']?.toDouble() ?? 145;
        _readingsCount = stats['readings_count'] ?? 3;
        _inRangePercentage = stats['in_range_percentage']?.toDouble() ?? 92;
        _latestReading = stats['latest_reading']?.toInt() ?? 145;
        _isLoadingStats = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Unable to load latest data';
        _isLoadingStats = false;
        // Keep default values on error
      });

      print('Error loading glucose stats: $e');
    }
  }

  /// Public method to refresh the screen from outside
  void refresh() {
    _loadUserName();
    _loadTodayStats();
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
                      editable: false,
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
                        '📊 Talk With Your Us',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We always here to help check your health',
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Today\'s Overview',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          if (_isLoadingStats)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryPurple,
                                ),
                              ),
                            )
                          else if (_errorMessage != null)
                            IconButton(
                              icon: Icon(Icons.refresh, size: 20),
                              onPressed: _loadTodayStats,
                              tooltip: 'Retry',
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              icon: '📊',
                              value: _latestReading.toString(),
                              label: 'mg/dL',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              icon: '🎯',
                              value: _readingsCount.toString(),
                              label: 'Readings',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              icon: '📈',
                              value: '${_inRangePercentage.toStringAsFixed(0)}%',
                              label: 'In Range',
                            ),
                          ),
                        ],
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: Colors.orange),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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