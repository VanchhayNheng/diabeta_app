import 'package:flutter/material.dart';
import '../../../core/services/api_services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../service/user_data_service.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final _medicationService = MedicationService();
  final _userDataService = UserDataService();
  List<Map<String, dynamic>> _medications = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() => _isLoading = true);

    try {
      _userId = await _userDataService.getUserId();
      final medications = await _medicationService.getMedications(
        userId: _userId!,
        activeOnly: true,
      );

      setState(() {
        _medications = medications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading medications: $e')),
        );
      }
    }
  }

  void _addMedication() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicationScreen(userId: _userId!),
      ),
    );

    if (result == true) {
      _loadMedications();
    }
  }

  void _editMedication(Map<String, dynamic> medication) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicationScreen(
          userId: _userId!,
          medication: medication,
        ),
      ),
    );

    if (result == true) {
      _loadMedications();
    }
  }

  void _deleteMedication(Map<String, dynamic> medication) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medication'),
        content: Text('Are you sure you want to delete ${medication['medication_name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _medicationService.deleteMedication(
                  medication['id'],
                  _userId!,
                );
                _loadMedications();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Medication deleted'),
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
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _medications.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('💊', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      Text(
                        'No medications added yet',
                        style: Theme.of(context).textTheme.titleMedium,
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
                                        med['medication_name'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${med['dosage']} • ${med['frequency']}',
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
                                  onPressed: () => _deleteMedication(med),
                                ),
                                // PopupMenuButton(
                                //   itemBuilder: (context) => [
                                //     PopupMenuItem(
                                //       child: Row(
                                //         children: [
                                //           Icon(Icons.edit, size: 18),
                                //           SizedBox(width: 8),
                                //           Text('Edit'),
                                //         ],
                                //       ),
                                //       onTap: () => _editMedication(med),
                                //     ),
                                //     PopupMenuItem(
                                //       child: Row(
                                //         children: [
                                //           Icon(Icons.delete, size: 18, color: AppTheme.errorRed),
                                //           SizedBox(width: 8),
                                //           Text('Delete', style: TextStyle(color: AppTheme.errorRed)),
                                //         ],
                                //       ),
                                //       onTap: () => _deleteMedication(med),
                                //     ),
                                //   ],
                                // ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Divider(color: Colors.grey.withOpacity(0.2)),
                            const SizedBox(height: 12),
                            _InfoRow(
                              icon: Icons.access_time,
                              label: 'Time',
                              value: med['time_of_day'] ?? "",
                            ),
                            if (med['notes']?.isNotEmpty ?? false) ...[
                              const SizedBox(height: 8),
                              _InfoRow(
                                icon: Icons.info_outline,
                                label: 'Notes',
                                value: med['notes'],
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
  final String userId;
  final Map<String, dynamic>? medication;

  const AddMedicationScreen({
    super.key,
    required this.userId,
    this.medication,
  });

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicationService = MedicationService();

  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _notesController;
  String _frequency = 'Once daily';
  String _timeOfDay = 'Morning';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication?['medication_name'] ?? '');
    _dosageController = TextEditingController(text: widget.medication?['dosage'] ?? '');
    _notesController = TextEditingController(text: widget.medication?['notes'] ?? '');
    if (widget.medication != null) {
      _frequency = widget.medication!['frequency'];
      _timeOfDay =  "";
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveMedication() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        await _medicationService.saveMedication(
          medicationName: _nameController.text,
          dosage: _dosageController.text,
          frequency: _frequency,
          timeOfDay: _timeOfDay,
          notes: _notesController.text,
          userId: 'alice_session',//widget.userId,
          id: widget.medication?['id'],
          isActive: true,
        );

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Medication saved successfully!'),
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
                      widget.medication == null ? 'Add Medication' : 'Edit Medication',
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
                                items: ['Once daily', 'Twice daily', 'Three times daily', 'As needed']
                                    .map((freq) => DropdownMenuItem(value: freq, child: Text(freq)))
                                    .toList(),
                                onChanged: (value) => setState(() => _frequency = value!),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _timeOfDay,
                                decoration: InputDecoration(
                                  labelText: 'Time of Day',
                                  prefixIcon: Icon(Icons.access_time),
                                ),
                                items: ['Morning', 'Afternoon', 'Evening', 'Night']
                                    .map((time) => DropdownMenuItem(value: time, child: Text(time)))
                                    .toList(),
                                onChanged: (value) => setState(() => _timeOfDay = value!),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _notesController,
                                decoration: InputDecoration(
                                  labelText: 'Notes (optional)',
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
                          onPressed: _isSaving ? null : _saveMedication,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPurple,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isSaving
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                            widget.medication == null ? 'Add Medication' : 'Save Changes',
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