import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../../settings/service/user_data_service.dart';

class GlucoseScreen extends StatefulWidget {
  const GlucoseScreen({super.key});

  @override
  State<GlucoseScreen> createState() => _GlucoseScreenState();
}

class _GlucoseScreenState extends State<GlucoseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _glucoseController = TextEditingController();
  final _notesController = TextEditingController();
  final _glucoseService = GlucoseService();
  final _userDataService = UserDataService();

  String _selectedReadingTime = 'Before breakfast';
  DateTime _selectedDateTime = DateTime.now();
  bool _isSubmitting = false;

  final List<String> _readingTimes = [
    'Before breakfast',
    'After breakfast',
    'Before lunch',
    'After lunch',
    'Before dinner',
    'After dinner',
    'Before exercise',
    'After exercise',
    'Bedtime',
  ];

  @override
  void dispose() {
    _glucoseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryPurple,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppTheme.primaryPurple,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submitReading() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final glucoseValue = double.parse(_glucoseController.text);

      // Format the notes
      final notes = _notesController.text.isEmpty
          ? _selectedReadingTime
          : '$_selectedReadingTime - ${_notesController.text}';

      // Call the API
      await _glucoseService.addReading(
        value: glucoseValue,
        type: _selectedReadingTime,
        notes: notes,
      );

      if (!mounted) return;

      // Show success message
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Glucose reading added successfully!'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppTheme.radiusMedium,
          ),
        ),
      );

      // Return to home screen
      Navigator.pop(context, true); // Pass true to indicate success

      // Clear form
      _glucoseController.clear();
      _notesController.clear();
      setState(() {
        _selectedDateTime = DateTime.now();
        _selectedReadingTime = 'Before breakfast';
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppTheme.radiusMedium,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Add Glucose',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Info Card
                        GlassCard(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryPurple.withOpacity(0.1),
                                  borderRadius: AppTheme.radiusMedium,
                                ),
                                child: const Icon(
                                  Icons.info_outline,
                                  color: AppTheme.primaryPurple,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Blood glucose normal range: 20-600 mg/dL',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Glucose Value
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Glucose Value',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _glucoseController,
                                keyboardType: TextInputType.number,
                                style: Theme.of(context).textTheme.bodyLarge,
                                decoration: InputDecoration(
                                  hintText: 'Enter glucose value',
                                  suffixText: 'mg/dL',
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.5),
                                  border: OutlineInputBorder(
                                    borderRadius: AppTheme.radiusMedium,
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter glucose value';
                                  }
                                  final glucose = double.tryParse(value);
                                  if (glucose == null) {
                                    return 'Please enter a valid number';
                                  }
                                  if (glucose < 20 || glucose > 600) {
                                    return 'Value must be between 20-600 mg/dL';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Reading Time
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reading Time',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: AppTheme.radiusMedium,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedReadingTime,
                                    isExpanded: true,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    items: _readingTimes.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _selectedReadingTime = newValue;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Date & Time
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date & Time',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: _selectDateTime,
                                borderRadius: AppTheme.radiusMedium,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    borderRadius: AppTheme.radiusMedium,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 20,
                                        color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        DateFormat('MMM dd, yyyy - hh:mm a')
                                            .format(_selectedDateTime),
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Notes (Optional)
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notes (Optional)',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _notesController,
                                maxLines: 3,
                                style: Theme.of(context).textTheme.bodyLarge,
                                decoration: InputDecoration(
                                  hintText: 'Add any additional notes...',
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.5),
                                  border: OutlineInputBorder(
                                    borderRadius: AppTheme.radiusMedium,
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Submit Button
                        _isSubmitting
                            ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: AppTheme.radiusLarge,
                          ),
                          child: const Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                            : GradientButton(
                          text: 'Save Reading',
                          onPressed: () => _submitReading(),
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