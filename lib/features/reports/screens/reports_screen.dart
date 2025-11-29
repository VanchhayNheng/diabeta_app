import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_theme.dart';
// import '../../../shared/widgets/glass_widgets.dart'; // GlassCard is now defined below

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key}); // Added const and super.key

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'Month';

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
                      'Reports',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _PeriodButton(
                            text: 'Week',
                            isSelected: _selectedPeriod == 'Week',
                            onTap: () => setState(() => _selectedPeriod = 'Week'),
                          ),
                          _PeriodButton(
                            text: 'Month',
                            isSelected: _selectedPeriod == 'Month',
                            onTap: () => setState(() => _selectedPeriod = 'Month'),
                          ),
                          _PeriodButton(
                            text: 'Year',
                            isSelected: _selectedPeriod == 'Year',
                            onTap: () => setState(() => _selectedPeriod = 'Year'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Stats Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  // Taller aspect ratio to prevent overflow and look better
                  childAspectRatio: 0.9,
                  children: const [
                    // Changed icon: '📊' to iconData: Icons.bar_chart
                    StatCard(
                      iconData: Icons.bar_chart,
                      value: '142',
                      label: 'Avg. Glucose',
                      change: '↓ 5% vs last month',
                      isPositive: false, // Changed to false for the down arrow
                    ),
                    // Changed icon: '🎯' to iconData: Icons.check_circle_outline
                    StatCard(
                      iconData: Icons.check_circle_outline,
                      value: '89%',
                      label: 'In Range',
                      change: '↑ 3% vs last month',
                      isPositive: true,
                    ),
                    // Changed icon: '📈' to iconData: Icons.trending_up
                    StatCard(
                      iconData: Icons.trending_up,
                      value: '6.2%',
                      label: 'Est. HbA1c',
                      change: '↓ 0.3% vs last month',
                      isPositive: false, // Changed to false for the down arrow
                    ),
                    // Changed icon: '⏰' to iconData: Icons.access_time
                    StatCard(
                      iconData: Icons.access_time,
                      value: '124',
                      label: 'Total Readings',
                      change: '↑ 12% vs last month',
                      isPositive: true,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Glucose Trends Chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Glucose Trends',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 180,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: const [
                                  FlSpot(0, 80),
                                  FlSpot(1, 70),
                                  FlSpot(2, 50),
                                  FlSpot(3, 45),
                                  FlSpot(4, 40),
                                  FlSpot(5, 38),
                                  FlSpot(6, 35),
                                  FlSpot(7, 30),
                                  FlSpot(8, 25),
                                ],
                                isCurved: true,
                                gradient: AppTheme.primaryGradient,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color: index == 8
                                          ? AppTheme.secondaryPurple
                                          : AppTheme.primaryPurple,
                                      strokeWidth: index == 8 ? 2 : 0,
                                      strokeColor: Colors.white,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppTheme.primaryPurple.withOpacity(0.3),
                                      AppTheme.primaryPurple.withOpacity(0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // AI Insights
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Insights',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      const _InsightCard(
                        icon: '🎯',
                        title: 'Great Progress!',
                        description: 'Your glucose levels have been consistently in range for 5 days. Keep up the excellent work!',
                        color: AppTheme.successGreen,
                      ),
                      const SizedBox(height: 12),
                      const _InsightCard(
                        icon: '💡',
                        title: 'Pattern Detected',
                        description: 'Your readings tend to spike after lunch. Consider smaller portions or a 10-minute walk after meals.',
                        color: AppTheme.warningOrange,
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

class _PeriodButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    super.key, // Added super.key
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? AppTheme.elevation1 : null,
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppTheme.primaryPurple,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final Color color;

  const _InsightCard({
    super.key, // Added super.key
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------
// ADDED WIDGET DEFINITIONS FOR CODE TO RUN AND IMPROVE AESTHETICS
// -------------------------------------------------------------------

// Placeholder for GlassCard (shared widget)
class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: child,
    );
  }
}

// StatCard definition (with aesthetic improvements)
class StatCard extends StatelessWidget {
  final IconData iconData; // Changed from String 'icon'
  final String value;
  final String label;
  final String? change;
  final bool? isPositive;

  const StatCard({
    super.key,
    required this.iconData,
    required this.value,
    required this.label,
    this.change,
    this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard( // Using the defined GlassCard for a consistent look
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Styled Icon (Replaces Emoji)
          Icon(
            iconData,
            size: 30, // Slightly smaller
            color: AppTheme.primaryPurple.withOpacity(0.8),
          ),
          const SizedBox(height: 4),

          // Main Value
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryPurple,
              fontWeight: FontWeight.bold,
              fontSize: 28, // Adjusted size
            ),
          ),
          const SizedBox(height: 2),

          // Label
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),

          // Change Indicator
          if (change != null) ...[
            const SizedBox(height: 8),
            Text(
              change!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isPositive == true
                    ? AppTheme.successGreen
                    : AppTheme.errorRed,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}