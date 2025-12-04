import 'package:flutter/material.dart';
import '../../../core/services/api_services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../../settings/service/user_data_service.dart';

class ExerciseLogScreen extends StatefulWidget {
  const ExerciseLogScreen({super.key});

  @override
  State<ExerciseLogScreen> createState() => _ExerciseLogScreenState();
}

class _ExerciseLogScreenState extends State<ExerciseLogScreen> {
  final _exerciseLogService = ExerciseLogService();
  final _userDataService = UserDataService();
  List<Map<String, dynamic>> _exerciseLogs = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadExerciseLogs();
  }

  Future<void> _loadExerciseLogs() async {
    setState(() => _isLoading = true);

    try {
      _userId = await _userDataService.getUserId();
      final logs = await _exerciseLogService.getExercises(userId: _userId!);

      setState(() {
        _exerciseLogs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading exercises: $e')),
        );
      }
    }
  }

  void _addExercise() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExerciseScreen(userId: _userId!),
      ),
    );

    if (result == true) {
      _loadExerciseLogs();
    }
  }

  void _deleteExercise(Map<String, dynamic> exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exercise Log'),
        content: const Text('Are you sure you want to delete this exercise log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _exerciseLogService.deleteExercise(exercise['id'], _userId!);
                _loadExerciseLogs();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Exercise log deleted'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }

  String _getActivityIcon(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'walking':
        return '🚶';
      case 'running':
        return '🏃';
      case 'cycling':
        return '🚴';
      case 'swimming':
        return '🏊';
      case 'yoga':
        return '🧘';
      case 'gym':
      case 'weight training':
        return '🏋️';
      case 'basketball':
        return '🏀';
      case 'soccer':
      case 'football':
        return '⚽';
      default:
        return '🏃';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
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
                      'Exercise Log',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addExercise,
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _exerciseLogs.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🏃', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      Text(
                        'No exercises logged yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _addExercise,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Exercise'),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _exerciseLogs.length,
                  itemBuilder: (context, index) {
                    final exercise = _exerciseLogs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getActivityIcon(exercise['activity_type']),
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exercise['activity_type'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        DateTime.parse(exercise['exercise_time'])
                                            .toString()
                                            .substring(0, 16),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: AppTheme.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: AppTheme.errorRed),
                                  onPressed: () => _deleteExercise(exercise),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              children: [
                                _ExerciseBadge(
                                  icon: Icons.timer,
                                  label: '${exercise['duration_minutes']} min',
                                ),
                                const SizedBox(width: 8),
                                _ExerciseBadge(
                                  icon: Icons.speed,
                                  label: exercise['intensity'],
                                ),
                                const SizedBox(width: 8),
                                _ExerciseBadge(
                                  icon: Icons.local_fire_department,
                                  label: '${exercise['calories_burned']} cal',
                                ),
                              ],
                            ),
                            if (exercise['notes']?.isNotEmpty ?? false) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Note: ${exercise['notes']}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ExerciseBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryPurple),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppTheme.primaryPurple),
          ),
        ],
      ),
    );
  }
}

class AddExerciseScreen extends StatefulWidget {
  final String userId;

  const AddExerciseScreen({super.key, required this.userId});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _exerciseLogService = ExerciseLogService();

  late TextEditingController _activityController;
  late TextEditingController _durationController;
  late TextEditingController _caloriesController;
  late TextEditingController _notesController;
  String _intensity = 'Moderate';
  DateTime _selectedTime = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _activityController = TextEditingController();
    _durationController = TextEditingController();
    _caloriesController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _activityController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedTime),
      );
      if (time != null) {
        setState(() {
          _selectedTime = DateTime(
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

  Future<void> _saveExercise() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        await _exerciseLogService.saveExercise(
          activityType: _activityController.text,
          durationMinutes: int.parse(_durationController.text),
          intensity: _intensity,
          caloriesBurned: int.parse(_caloriesController.text),
          exerciseTime: _selectedTime,
          notes: _notesController.text,
          userId: widget.userId,
        );

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Exercise logged successfully!'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        setState(() => _isSaving = false);



        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add Exercise',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        GlassCard(
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _activityController,
                                decoration: InputDecoration(
                                  labelText: 'Activity Type',
                                  hintText: 'e.g., Running, Cycling, Yoga',
                                  prefixIcon: Icon(Icons.directions_run),
                                ),
                                validator: (value) =>
                                value?.isEmpty ?? true ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: _selectDateTime,
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Date & Time',
                                    prefixIcon: Icon(Icons.access_time),
                                  ),
                                  child: Text(
                                    _selectedTime.toString().substring(0, 16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _durationController,
                                      decoration: InputDecoration(
                                        labelText: 'Duration (min)',
                                        prefixIcon: Icon(Icons.timer),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) =>
                                      value?.isEmpty ?? true ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _intensity,
                                      decoration: InputDecoration(
                                        labelText: 'Intensity',
                                        prefixIcon: Icon(Icons.speed),
                                      ),
                                      items: ['Low', 'Moderate', 'High']
                                          .map((i) => DropdownMenuItem(
                                          value: i, child: Text(i)))
                                          .toList(),
                                      onChanged: (value) =>
                                          setState(() => _intensity = value!),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _caloriesController,
                                decoration: InputDecoration(
                                  labelText: 'Calories Burned',
                                  prefixIcon: Icon(Icons.local_fire_department),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) =>
                                value?.isEmpty ?? true ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _notesController,
                                decoration: InputDecoration(
                                  labelText: 'Notes (optional)',
                                  hintText: 'How did you feel?',
                                  prefixIcon: Icon(Icons.notes),
                                ),
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveExercise,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPurple,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isSaving
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                            'Add Exercise',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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