import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../service/meal_log_service.dart';

class MealLogScreen extends StatefulWidget {
  const MealLogScreen({super.key});

  @override
  State<MealLogScreen> createState() => _MealLogScreenState();
}

class _MealLogScreenState extends State<MealLogScreen> {
  final _mealLogService = MealLogService();
  List<Map<String, dynamic>> _mealLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMealLogs();
  }

  Future<void> _loadMealLogs() async {
    setState(() => _isLoading = true);
    final logs = await _mealLogService.loadMealLogs();
    setState(() {
      _mealLogs = logs;
      _isLoading = false;
    });
  }

  Future<void> _saveMealLogs() async {
    await _mealLogService.saveMealLogs(_mealLogs);
  }

  void _addMeal() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMealScreen(
          onSave: (meal) {
            setState(() {
              meal['id'] = DateTime.now().millisecondsSinceEpoch.toString();
              _mealLogs.insert(0, meal);
            });
            _saveMealLogs();
          },
        ),
      ),
    );
  }

  void _editMeal(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMealScreen(
          meal: _mealLogs[index],
          onSave: (meal) {
            setState(() {
              _mealLogs[index] = meal;
            });
            _saveMealLogs();
          },
        ),
      ),
    );
  }

  void _deleteMeal(int index) {
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
            onPressed: () {
              setState(() {
                _mealLogs.removeAt(index);
              });
              _saveMealLogs();
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
                      'Meal Log',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addMeal,
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
                    : _mealLogs.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🥗', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      Text(
                        'No meals logged yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _addMeal,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Meal'),
                      ),
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
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getMealIcon(meal['mealType']),
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
                                        meal['mealType'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        meal['time'],
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
                                      onTap: () => _editMeal(index),
                                    ),
                                    PopupMenuItem(
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, size: 18, color: AppTheme.errorRed),
                                          SizedBox(width: 8),
                                          Text('Delete', style: TextStyle(color: AppTheme.errorRed)),
                                        ],
                                      ),
                                      onTap: () => _deleteMeal(index),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              meal['foodItems'],
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _NutritionBadge(
                                  icon: Icons.grain,
                                  label: '${meal['carbs']}g carbs',
                                ),
                                const SizedBox(width: 8),
                                _NutritionBadge(
                                  icon: Icons.local_fire_department,
                                  label: '${meal['calories']} cal',
                                ),
                              ],
                            ),
                            if (meal['notes']?.isNotEmpty ?? false) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Note: ${meal['notes']}',
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

  String _getMealIcon(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return '🍳';
      case 'Lunch':
        return '🥗';
      case 'Dinner':
        return '🍽️';
      case 'Snack':
        return '🍎';
      default:
        return '🥗';
    }
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

class AddMealScreen extends StatefulWidget {
  final Map<String, dynamic>? meal;
  final Function(Map<String, dynamic>) onSave;

  const AddMealScreen({super.key, this.meal, required this.onSave});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _foodItemsController;
  late TextEditingController _carbsController;
  late TextEditingController _caloriesController;
  late TextEditingController _notesController;
  String _mealType = 'Breakfast';
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _foodItemsController = TextEditingController(text: widget.meal?['foodItems'] ?? '');
    _carbsController = TextEditingController(text: widget.meal?['carbs'] ?? '');
    _caloriesController = TextEditingController(text: widget.meal?['calories'] ?? '');
    _notesController = TextEditingController(text: widget.meal?['notes'] ?? '');
    if (widget.meal != null) {
      _mealType = widget.meal!['mealType'];
      final timeParts = widget.meal!['time'].split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1].split(' ')[0]),
      );
    }
  }

  @override
  void dispose() {
    _foodItemsController.dispose();
    _carbsController.dispose();
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

  void _saveMeal() {
    if (_formKey.currentState!.validate()) {
      final meal = {
        'id': widget.meal?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'mealType': _mealType,
        'foodItems': _foodItemsController.text,
        'carbs': _carbsController.text,
        'calories': _caloriesController.text,
        'time': _selectedTime.format(context),
        'date': DateTime.now().toIso8601String(),
        'notes': _notesController.text,
      };
      widget.onSave(meal);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Meal logged successfully!'),
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
                      widget.meal == null ? 'Add Meal' : 'Edit Meal',
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
                                value: _mealType,
                                decoration: InputDecoration(
                                  labelText: 'Meal Type',
                                  prefixIcon: Icon(Icons.restaurant),
                                ),
                                items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                                    .toList(),
                                onChanged: (value) => setState(() => _mealType = value!),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _foodItemsController,
                                decoration: InputDecoration(
                                  labelText: 'Food Items',
                                  hintText: 'e.g., Grilled chicken, rice, vegetables',
                                  prefixIcon: Icon(Icons.fastfood),
                                ),
                                maxLines: 2,
                                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _carbsController,
                                      decoration: InputDecoration(
                                        labelText: 'Carbs (g)',
                                        prefixIcon: Icon(Icons.grain),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _caloriesController,
                                      decoration: InputDecoration(
                                        labelText: 'Calories',
                                        prefixIcon: Icon(Icons.local_fire_department),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                                    ),
                                  ),
                                ],
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
                          onPressed: _saveMeal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPurple,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            widget.meal == null ? 'Add Meal' : 'Save Changes',
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