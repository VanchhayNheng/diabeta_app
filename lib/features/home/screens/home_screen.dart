import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../../../shared/widgets/profile_avatar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                    Text(
                      'Hello, Nick 👋',
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
                        onPressed: () {},
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
                            onTap: () {},
                          ),
                          const SizedBox(width: 10),
                          QuickActionCard(
                            icon: '🥗',
                            title: 'Meal Log',
                            onTap: () {},
                          ),
                          const SizedBox(width: 10),
                          QuickActionCard(
                            icon: '🏃',
                            title: 'Exercise',
                            onTap: () {},
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

            // Essentials Grid
            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 20),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           'Essentials',
            //           style: Theme.of(context).textTheme.headlineMedium,
            //         ),
            //         const SizedBox(height: 16),
            //         GridView.count(
            //           crossAxisCount: 2,
            //           shrinkWrap: true,
            //           physics: const NeverScrollableScrollPhysics(),
            //           mainAxisSpacing: 15,
            //           crossAxisSpacing: 15,
            //           childAspectRatio: 1.0,
            //           children: [
            //             FeatureCard(
            //               icon: '🔬',
            //               title: 'Regular Tests',
            //               subtitle: 'HbA1c, Lipids',
            //               onTap: () {},
            //             ),
            //             FeatureCard(
            //               icon: '💊',
            //               title: 'Medications',
            //               subtitle: 'Daily Tracker',
            //               onTap: () {},
            //             ),
            //             FeatureCard(
            //               icon: '🏃',
            //               title: 'Exercise',
            //               subtitle: 'Stay Active',
            //               onTap: () {},
            //             ),
            //             FeatureCard(
            //               icon: '🥗',
            //               title: 'Nutrition',
            //               subtitle: 'Healthy Diet',
            //               onTap: () {},
            //             ),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}