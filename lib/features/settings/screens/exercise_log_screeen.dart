import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../service/exercise_log_service.dart';

class ExerciseLogScreen extends StatefulWidget {
  const ExerciseLogScreen({super.key});

  @override
  State<ExerciseLogScreen> createState() => _ExerciseLogScreenState();
}

class _ExerciseLogScreenState extends State<ExerciseLogScreen> {
  final _exerciseLogService = ExerciseLogService();
  List<Map<String, dynamic>> _exerciseLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExerciseLogs();
  }

  Future<void> _loadExerciseLogs() async {
    setState(() => _isLoading = true);
    final logs = await _exerciseLogService.loadExerciseLogs();
    setState(() {
      _exerciseLogs = logs;
      _isLoading = false;
    });
  }

  Future<void> _saveExerciseLogs() async {
    await _exerciseLogService.saveExerciseLogs(_exerciseLogs);
  }

  void _addExercise() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExerciseScreen(
          onSave: (exercise) {
            setState(() {
              exercise['id'] = DateTime.now().millisecondsSinceEpoch.toString();
              _exerciseLogs.insert(0, exercise);
            });
            _saveExerciseLogs();
          },
        ),
      ),
    );
  }

  void _editExercise(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExerciseScreen(
          exercise: _exerciseLogs[index],
          onSave: (exercise) {
            setState(() {
              _exerciseLogs[index] = exercise;
            });
            _saveExerciseLogs();
          },
        ),
      ),
    );
  }

  void _deleteExercise(int index) {
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
            onPressed: () {
              setState(() {
                _exerciseLogs.removeAt(index);
              });
              _saveExerciseLogs();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
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
                                      _getActivityIcon(exercise['activityType']),
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
                                        exercise['activityType'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        exercise['time'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: AppTheme.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 18),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                      onTap: () => _editExercise(index),
                                    ),
                                    PopupMenuItem(
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, size: 18, color: AppTheme.errorRed),
                                          SizedBox(width: 8),
                                          Text('Delete', style: TextStyle(color: AppTheme.errorRed)),
                                        ],
                                      ),
                                      onTap: () => _deleteExercise(index),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _ExerciseBadge(
                                  icon: Icons.timer,
                                  label: '${exercise['duration']} min',
                                ),
                                const SizedBox(width: 8),
                                _ExerciseBadge(
                                  icon: Icons.speed,
                                  label: exercise['intensity'],
                                ),
                                const SizedBox(width: 8),
                                _ExerciseBadge(
                                  icon: Icons.local_fire_department,
                                  label: '${exercise['calories']} cal',
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

  String _getActivityIcon(String activityType) {
    switch (activityType) {
      case 'Walking':
        return '🚶';
      case 'Running':
        return '🏃';
      case 'Cycling':
        return '🚴';
      case 'Swimming':
        return '🏊';
      case 'Yoga':
        return '🧘';
      case 'Gym':
        return '🏋️';
      default:
        return '🏃';
    }
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
  final Map<String, dynamic>? exercise;
  final Function(Map<String, dynamic>) onSave;

  const AddExerciseScreen({super.key, this.exercise, required this.onSave});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _durationController;
  late TextEditingController _caloriesController;
  late TextEditingController _notesController;
  String _activityType = 'Walking';
  String _intensity = 'Moderate';
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _durationController = TextEditingController(text: widget.exercise?['duration'] ?? '');
    _caloriesController = TextEditingController(text: widget.exercise?['calories'] ?? '');
    _notesController = TextEditingController(text: widget.exercise?['notes'] ?? '');
    if (widget.exercise != null) {
      _activityType = widget.exercise!['activityType'];
      _intensity = widget.exercise!['intensity'];
      final timeParts = widget.exercise!['time'].split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1].split(' ')[0]),
      );
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _saveExercise() {
    if (_formKey.currentState!.validate()) {
      final exercise = {
        'id': widget.exercise?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'activityType': _activityType,
        'duration': _durationController.text,
        'intensity': _intensity,
        'calories': _caloriesController.text,
        'time': _selectedTime.format(context),
        'date': DateTime.now().toIso8601String(),
        'notes': _notesController.text,
      };
      widget.onSave(exercise);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Exercise logged successfully!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
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
                      widget.exercise == null ? 'Add Exercise' : 'Edit Exercise',
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
                              DropdownButtonFormField<String>(
                                value: _activityType,
                                decoration: InputDecoration(
                                  labelText: 'Activity Type',
                                  prefixIcon: Icon(Icons.directions_run),
                                ),
                                items: ['Walking', 'Running', 'Cycling', 'Swimming', 'Yoga', 'Gym', 'Other']
                                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                                    .toList(),
                                onChanged: (value) => setState(() => _activityType = value!),
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
                                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
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
                                          .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                                          .toList(),
                                      onChanged: (value) => setState(() => _intensity = value!),
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
                                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: _selectTime,
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Time',
                                    prefixIcon: Icon(Icons.access_time),
                                  ),
                                  child: Text(_selectedTime.format(context)),
                                ),
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
                          onPressed: _saveExercise,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPurple,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            widget.exercise == null ? 'Add Exercise' : 'Save Changes',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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