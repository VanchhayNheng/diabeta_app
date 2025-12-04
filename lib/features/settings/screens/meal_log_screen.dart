import 'package:flutter/material.dart';
import '../../../core/services/api_services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../../settings/service/user_data_service.dart';

class MealLogScreen extends StatefulWidget {
  const MealLogScreen({super.key});

  @override
  State<MealLogScreen> createState() => _MealLogScreenState();
}

class _MealLogScreenState extends State<MealLogScreen> {
  final _mealLogService = MealLogService();
  final _userDataService = UserDataService();
  List<Map<String, dynamic>> _mealLogs = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadMealLogs();
  }

  Future<void> _loadMealLogs() async {
    setState(() => _isLoading = true);

    try {
      _userId = await _userDataService.getUserId();
      final logs = await _mealLogService.getMeals(userId: _userId!);

      setState(() {
        _mealLogs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading meals: $e')),
        );
      }
    }
  }

  void _addMeal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMealScreen(userId: _userId!),
      ),
    );

    if (result == true) {
      _loadMealLogs();
    }
  }

  void _deleteMeal(Map<String, dynamic> meal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal Log'),
        content: const Text('Are you sure you want to delete this meal log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _mealLogService.deleteMeal(meal['id'], _userId!);
                _loadMealLogs();
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

  String _getMealIcon(String? mealTime) {
    if (mealTime == null) return '🥗';
    final hour = DateTime.parse(mealTime).hour;
    if (hour < 11) return '🍳';
    if (hour < 15) return '🥗';
    if (hour < 19) return '🍽️';
    return '🌙';
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
                    Text('Meal Log', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addMeal,
                      style: IconButton.styleFrom(backgroundColor: AppTheme.primaryPurple, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _mealLogs.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🥗', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      Text('No meals logged yet', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      TextButton.icon(onPressed: _addMeal, icon: const Icon(Icons.add), label: const Text('Add Meal')),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _mealLogs.length,
                  itemBuilder: (context, index) {
                    final meal = _mealLogs[index];
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
                                  decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(12)),
                                  child: Center(child: Text(_getMealIcon(meal['meal_time']), style: TextStyle(fontSize: 24))),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(meal['meal_name'], style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                      Text(
                                        DateTime.parse(meal['meal_time']).toString().substring(0, 16),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(icon: Icon(Icons.delete, color: AppTheme.errorRed), onPressed: () => _deleteMeal(meal)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _NutritionBadge(icon: Icons.grain, label: '${meal['carbs']}g carbs'),
                                _NutritionBadge(icon: Icons.fitness_center, label: '${meal['protein']}g protein'),
                                _NutritionBadge(icon: Icons.local_fire_department, label: '${meal['calories']} cal'),
                              ],
                            ),
                            if (meal['notes']?.isNotEmpty ?? false) ...[
                              const SizedBox(height: 8),
                              Text('Note: ${meal['notes']}', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
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

class _NutritionBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _NutritionBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppTheme.primaryPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryPurple),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: AppTheme.primaryPurple)),
        ],
      ),
    );
  }
}

class AddMealScreen extends StatefulWidget {
  final String userId;
  const AddMealScreen({super.key, required this.userId});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mealLogService = MealLogService();
  late TextEditingController _nameController;
  late TextEditingController _carbsController;
  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _caloriesController;
  late TextEditingController _notesController;
  DateTime _selectedTime = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _carbsController = TextEditingController();
    _proteinController = TextEditingController();
    _fatController = TextEditingController();
    _caloriesController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _carbsController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(context: context, initialDate: _selectedTime, firstDate: DateTime(2020), lastDate: DateTime.now());
    if (date != null) {
      final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_selectedTime));
      if (time != null) {
        setState(() => _selectedTime = DateTime(date.year, date.month, date.day, time.hour, time.minute));
      }
    }
  }

  Future<void> _saveMeal() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        await _mealLogService.saveMeal(
          mealName: _nameController.text,
          mealTime: _selectedTime,
          carbs: int.parse(_carbsController.text),
          protein: int.tryParse(_proteinController.text),
          fat: int.tryParse(_fatController.text),
          calories: int.parse(_caloriesController.text),
          notes: _notesController.text,
          userId: widget.userId,
        );

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Meal logged successfully!'), backgroundColor: AppTheme.successGreen),
          );
        }
      } catch (e) {
        setState(() => _isSaving = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    const SizedBox(width: 8),
                    Text('Add Meal', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
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
                                controller: _nameController,
                                decoration: InputDecoration(labelText: 'Meal Name', hintText: 'e.g., Grilled chicken salad', prefixIcon: Icon(Icons.fastfood)),
                                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: _selectDateTime,
                                child: InputDecorator(
                                  decoration: InputDecoration(labelText: 'Date & Time', prefixIcon: Icon(Icons.access_time)),
                                  child: Text(_selectedTime.toString().substring(0, 16)),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _carbsController,
                                      decoration: InputDecoration(labelText: 'Carbs (g)', prefixIcon: Icon(Icons.grain)),
                                      keyboardType: TextInputType.number,
                                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _proteinController,
                                      decoration: InputDecoration(labelText: 'Protein (g)', prefixIcon: Icon(Icons.fitness_center)),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _fatController,
                                      decoration: InputDecoration(labelText: 'Fat (g)', prefixIcon: Icon(Icons.water_drop)),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _caloriesController,
                                      decoration: InputDecoration(labelText: 'Calories', prefixIcon: Icon(Icons.local_fire_department)),
                                      keyboardType: TextInputType.number,
                                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _notesController,
                                decoration: InputDecoration(labelText: 'Notes (optional)', hintText: 'How did you feel?', prefixIcon: Icon(Icons.notes)),
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveMeal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPurple,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isSaving
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('Add Meal', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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