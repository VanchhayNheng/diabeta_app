import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../service/medication_data_service.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final _medicationService = MedicationDataService();
  List<Map<String, dynamic>> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  /// Load medications from local storage
  Future<void> _loadMedications() async {
    setState(() => _isLoading = true);

    final medications = await _medicationService.loadMedications();

    setState(() {
      _medications = medications;
      _isLoading = false;
    });
  }

  /// Save medications to local storage
  Future<void> _saveMedications() async {
    final success = await _medicationService.saveMedications(_medications);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Failed to save medications'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _addMedication() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicationScreen(
          onSave: (medication) {
            setState(() {
              _medications.add(medication);
            });
            _saveMedications();
          },
        ),
      ),
    );
  }

  void _editMedication(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicationScreen(
          medication: _medications[index],
          onSave: (medication) {
            setState(() {
              _medications[index] = medication;
            });
            _saveMedications();
          },
        ),
      ),
    );
  }

  void _deleteMedication(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medication'),
        content: Text('Are you sure you want to delete ${_medications[index]['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _medications.removeAt(index);
              });
              _saveMedications();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Medication deleted'),
                  backgroundColor: AppTheme.errorRed,
                ),
              );
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
                      'Your Medication',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addMedication,
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryPurple,
                  ),
                )
                    : _medications.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '💊',
                        style: TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No medications added yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _addMedication,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Medication'),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _medications.length,
                  itemBuilder: (context, index) {
                    final med = _medications[index];
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
                                  child: const Center(
                                    child: Text('💊', style: TextStyle(fontSize: 24)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        med['name'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${med['dosage']} • ${med['frequency']}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
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
                                      onTap: () => _editMedication(index),
                                    ),
                                    PopupMenuItem(
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete,
                                              size: 18, color: AppTheme.errorRed),
                                          SizedBox(width: 8),
                                          Text('Delete',
                                              style: TextStyle(
                                                  color: AppTheme.errorRed)),
                                        ],
                                      ),
                                      onTap: () => _deleteMedication(index),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Divider(color: Colors.grey.withOpacity(0.2)),
                            const SizedBox(height: 12),
                            _InfoRow(
                              icon: Icons.access_time,
                              label: 'Schedule',
                              value: (med['time'] as List).join(', '),
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.info_outline,
                              label: 'Instructions',
                              value: med['instructions'],
                            ),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryPurple),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class AddMedicationScreen extends StatefulWidget {
  final Map<String, dynamic>? medication;
  final Function(Map<String, dynamic>) onSave;

  const AddMedicationScreen({
    super.key,
    this.medication,
    required this.onSave,
  });

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _instructionsController;
  String _frequency = 'Once daily';
  List<String> _times = ['08:00 AM'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication?['name'] ?? '');
    _dosageController = TextEditingController(text: widget.medication?['dosage'] ?? '');
    _instructionsController =
        TextEditingController(text: widget.medication?['instructions'] ?? '');
    if (widget.medication != null) {
      _frequency = widget.medication!['frequency'];
      _times = List<String>.from(widget.medication!['time']);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _saveMedication() {
    if (_formKey.currentState!.validate()) {
      widget.onSave({
        'name': _nameController.text,
        'dosage': _dosageController.text,
        'frequency': _frequency,
        'time': _times,
        'instructions': _instructionsController.text,
        'active': true,
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Medication saved successfully!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
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
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.medication == null ? 'Add Medication' : 'Edit Medication',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
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
                        GlassCard(
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Medication Name',
                                  hintText: 'e.g., Metformin',
                                  prefixIcon: Icon(Icons.medication),
                                ),
                                validator: (value) =>
                                value?.isEmpty ?? true ? 'Name is required' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _dosageController,
                                decoration: InputDecoration(
                                  labelText: 'Dosage',
                                  hintText: 'e.g., 500mg',
                                  prefixIcon: Icon(Icons.straighten),
                                ),
                                validator: (value) =>
                                value?.isEmpty ?? true ? 'Dosage is required' : null,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _frequency,
                                decoration: InputDecoration(
                                  labelText: 'Frequency',
                                  prefixIcon: Icon(Icons.repeat),
                                ),
                                items: [
                                  'Once daily',
                                  'Twice daily',
                                  'Three times daily',
                                  'Four times daily',
                                  'As needed'
                                ].map((freq) {
                                  return DropdownMenuItem(
                                    value: freq,
                                    child: Text(freq),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _frequency = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _instructionsController,
                                decoration: InputDecoration(
                                  labelText: 'Instructions',
                                  hintText: 'e.g., Take with food',
                                  prefixIcon: Icon(Icons.notes),
                                ),
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saveMedication,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPurple,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                              widget.medication == null
                                  ? 'Add Medication'
                                  : 'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )
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