import 'package:flutter/material.dart' hide Badge;
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_widgets.dart';

class GlucoseTrackingScreen extends StatelessWidget {
  const GlucoseTrackingScreen({Key? key}) : super(key: key);

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
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.elevation1,
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Blood Glucose',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),

            // Current Glucose Display
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  child: Column(
                    children: [
                      // Large Display
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryPurple.withOpacity(0.1),
                              AppTheme.secondaryPurple.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: AppTheme.radiusLarge,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Current Level',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return AppTheme.primaryGradient.createShader(bounds);
                              },
                              child: Text(
                                '175',
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                            Text(
                              'mg/dL',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Last update 30 min ago • 03:33 pm',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textTertiary,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Badge.success('✓ Within Normal Range'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Chart
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 200,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const days = ['23', '24', '25', '26', '27', '28', '29', '30'];
                                    return Text(
                                      days[value.toInt()],
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: AppTheme.textTertiary,
                                          ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              _makeBar(0, 90),
                              _makeBar(1, 110),
                              _makeBar(2, 100),
                              _makeBar(3, 140),
                              _makeBar(4, 150),
                              _makeBar(5, 170),
                              _makeBar(6, 190),
                              _makeBar(7, 175),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      GradientButton(
                        text: 'UPDATE NOW',
                        onPressed: () {
                          _showAddReadingDialog(context);
                        },
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

  BarChartGroupData _makeBar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: AppTheme.primaryGradient,
          width: 20,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(8),
          ),
        ),
      ],
    );
  }

  void _showAddReadingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddGlucoseReadingDialog(),
    );
  }
}

class AddGlucoseReadingDialog extends StatefulWidget {
  const AddGlucoseReadingDialog({Key? key}) : super(key: key);

  @override
  State<AddGlucoseReadingDialog> createState() => _AddGlucoseReadingDialogState();
}

class _AddGlucoseReadingDialogState extends State<AddGlucoseReadingDialog> {
  final _glucoseController = TextEditingController(text: '175');
  final _notesController = TextEditingController();
  String _selectedType = 'After Meal';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
          borderRadius: AppTheme.radiusXL,
        ),
        child: GlassCard(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Reading',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GlassTextField(
                  label: 'Glucose Level *',
                  hint: '120',
                  controller: _glucoseController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                Text(
                  'Reading Type',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _TypeButton(
                        text: 'Before Meal',
                        isSelected: _selectedType == 'Before Meal',
                        onTap: () => setState(() => _selectedType = 'Before Meal'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TypeButton(
                        text: 'After Meal',
                        isSelected: _selectedType == 'After Meal',
                        onTap: () => setState(() => _selectedType = 'After Meal'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GlassTextField(
                  label: 'Additional Notes',
                  hint: 'Any additional comments...',
                  controller: _notesController,
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                GradientButton(
                  text: 'SAVE READING',
                  onPressed: () {
                    // Save logic here
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reading saved successfully!'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _glucoseController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class _TypeButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.radiusSmall,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : AppTheme.primaryPurple.withOpacity(0.1),
          borderRadius: AppTheme.radiusSmall,
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppTheme.primaryPurple.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: isSelected ? AppTheme.primaryShadow : null,
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSelected ? Colors.white : AppTheme.primaryPurple,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
