import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../service/health_data_service.dart';

class HealthInformationScreen extends StatefulWidget {
  const HealthInformationScreen({super.key});

  @override
  State<HealthInformationScreen> createState() => _HealthInformationScreenState();
}

class _HealthInformationScreenState extends State<HealthInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _healthDataService = HealthDataService();

  bool _isEditing = false;
  bool _isLoading = true;

  Map<String, dynamic> _healthData = {};
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  /// Load health data from local storage
  Future<void> _loadHealthData() async {
    setState(() => _isLoading = true);

    try {
      final data = await _healthDataService.loadHealthData();

      setState(() {
        _healthData = data;
        _controllers = _healthData.map(
              (key, value) => MapEntry(key, TextEditingController(text: value.toString())),
        );
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      // Update in-memory data
      _controllers.forEach((key, controller) {
        _healthData[key] = controller.text;
      });

      // Recalculate BMI
      final height = double.tryParse(_controllers['height']!.text) ?? 0;
      final weight = double.tryParse(_controllers['weight']!.text) ?? 0;
      if (height > 0 && weight > 0) {
        final bmi = weight / ((height / 100) * (height / 100));
        _healthData['bmi'] = bmi.toStringAsFixed(1);
        _controllers['bmi']!.text = bmi.toStringAsFixed(1);
      }

      // Save to local storage
      final success = await _healthDataService.saveHealthData(_healthData);

      setState(() => _isEditing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                success
                    ? '✅ Health information saved successfully!'
                    : '⚠️ Failed to save data. Please try again.'
            ),
            backgroundColor: success ? AppTheme.successGreen : Colors.red,
          ),
        );
      }
    }
  }

  void _cancelEditing() {
    setState(() {
      _controllers.forEach((key, controller) {
        controller.text = _healthData[key].toString();
      });
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryPurple,
            ),
          )
              : Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Health Information',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (!_isEditing)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => setState(() => _isEditing = true),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
                        ),
                      ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Diabetes Information
                        _SectionHeader(title: 'Diabetes Information'),
                        const SizedBox(height: 16),
                        GlassCard(
                          child: Column(
                            children: [
                              _HealthField(
                                label: 'Diabetes Type',
                                icon: Icons.medical_information,
                                controller: _controllers['diabetesType']!,
                                enabled: _isEditing,
                              ),
                              const SizedBox(height: 16),
                              _HealthField(
                                label: 'Year of Diagnosis',
                                icon: Icons.calendar_today,
                                controller: _controllers['diagnosisYear']!,
                                enabled: _isEditing,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              _HealthField(
                                label: 'Latest A1C (%)',
                                icon: Icons.bloodtype,
                                controller: _controllers['a1c']!,
                                enabled: _isEditing,
                                keyboardType: TextInputType.number,
                                suffix: '%',
                              ),
                              const SizedBox(height: 16),
                              _HealthField(
                                label: 'Fasting Glucose (mg/dL)',
                                icon: Icons.water_drop,
                                controller: _controllers['fastingGlucose']!,
                                enabled: _isEditing,
                                keyboardType: TextInputType.number,
                                suffix: 'mg/dL',
                              ),
                              const SizedBox(height: 16),
                              _HealthField(
                                label: 'Target Glucose Range',
                                icon: Icons.track_changes,
                                controller: _controllers['targetGlucose']!,
                                enabled: _isEditing,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Physical Metrics
                        _SectionHeader(title: 'Physical Metrics'),
                        const SizedBox(height: 16),
                        GlassCard(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _HealthField(
                                      label: 'Height (cm)',
                                      icon: Icons.height,
                                      controller: _controllers['height']!,
                                      enabled: _isEditing,
                                      keyboardType: TextInputType.number,
                                      suffix: 'cm',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _HealthField(
                                      label: 'Weight (kg)',
                                      icon: Icons.monitor_weight,
                                      controller: _controllers['weight']!,
                                      enabled: _isEditing,
                                      keyboardType: TextInputType.number,
                                      suffix: 'kg',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _HealthField(
                                label: 'BMI',
                                icon: Icons.calculate,
                                controller: _controllers['bmi']!,
                                enabled: false,
                                suffix: 'kg/m²',
                              ),
                              const SizedBox(height: 16),
                              _HealthField(
                                label: 'Blood Pressure',
                                icon: Icons.favorite,
                                controller: _controllers['bloodPressure']!,
                                enabled: _isEditing,
                                suffix: 'mmHg',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Medical Conditions
                        _SectionHeader(title: 'Medical History'),
                        const SizedBox(height: 16),
                        GlassCard(
                          child: Column(
                            children: [
                              _HealthField(
                                label: 'Allergies',
                                icon: Icons.warning_amber,
                                controller: _controllers['allergies']!,
                                enabled: _isEditing,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 16),
                              _HealthField(
                                label: 'Other Conditions',
                                icon: Icons.local_hospital,
                                controller: _controllers['conditions']!,
                                enabled: _isEditing,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // BMI Indicator
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BMI Category',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _BMIIndicator(
                                bmi: double.tryParse(_healthData['bmi'].toString()) ?? 0,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Action Buttons
                        if (_isEditing)
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _cancelEditing,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    side: BorderSide(color: AppTheme.textSecondary),
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _saveChanges,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: AppTheme.primaryPurple,
                                  ),
                                  child: Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _HealthField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool enabled;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? suffix;

  const _HealthField({
    required this.label,
    required this.icon,
    required this.controller,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primaryPurple),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled
                ? Colors.white.withOpacity(0.5)
                : Colors.grey.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryPurple, width: 2),
            ),
            suffixText: suffix,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _BMIIndicator extends StatelessWidget {
  final double bmi;

  const _BMIIndicator({required this.bmi});

  String get _category {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color get _color {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return AppTheme.successGreen;
    if (bmi < 30) return Colors.orange;
    return AppTheme.errorRed;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                bmi.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _category,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _color,
                  ),
                ),
                Text(
                  'Based on your height and weight',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}