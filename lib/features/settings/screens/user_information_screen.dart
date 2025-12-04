import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../service/user_data_service.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userDataService = UserDataService();

  bool _isEditing = false;
  bool _isLoading = true;

  Map<String, String> _userData = {};
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Load user data from API
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final data = await _userDataService.loadUserData();

      setState(() {
        _userData = data;
        _controllers = {
          'name': TextEditingController(text: _userData['name']),
          'email': TextEditingController(text: _userData['email']),
          'phone': TextEditingController(text: _userData['phone']),
          'dateOfBirth': TextEditingController(text: _userData['dateOfBirth']),
          'gender': TextEditingController(text: _userData['gender']),
          'address': TextEditingController(text: _userData['address']),
          'emergencyContact': TextEditingController(text: _userData['emergencyContact']),
          'emergencyPhone': TextEditingController(text: _userData['emergencyPhone']),
          'a1c': TextEditingController(text: _userData['a1c']),
          'weight': TextEditingController(text: _userData['weight']),
        };
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

  /// Save changes to API
  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      // Update in-memory data
      _controllers.forEach((key, controller) {
        _userData[key] = controller.text;
      });

      // Save to API
      final success = await _userDataService.saveUserData(_userData);

      setState(() => _isEditing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                success
                    ? '✅ Information saved successfully!'
                    : '⚠️ Failed to save. Please try again.'
            ),
            backgroundColor: success ? AppTheme.successGreen : Colors.red,
          ),
        );
      }

      // Reload data from API to get updated values
      // if (success) {
      //   await _loadUserData();
      //   // Return true to indicate data was updated
      //   if (mounted) {
      //     Navigator.pop(context, true);
      //   }
      // }
    }
  }

  void _cancelEditing() {
    setState(() {
      _controllers.forEach((key, controller) {
        controller.text = _userData[key] ?? '';
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
                      'Your Information',
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
                        // Personal Information
                        _SectionHeader(title: 'Personal Information'),
                        const SizedBox(height: 16),
                        GlassCard(
                          child: Column(
                            children: [
                              _InfoField(
                                label: 'Full Name',
                                icon: Icons.person,
                                controller: _controllers['name']!,
                                enabled: _isEditing,
                                validator: (value) =>
                                value?.isEmpty ?? true ? 'Name is required' : null,
                              ),
                              const SizedBox(height: 16),
                              _InfoField(
                                label: 'Email',
                                icon: Icons.email,
                                controller: _controllers['email']!,
                                enabled: _isEditing,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return 'Email is required';
                                  if (!value!.contains('@')) return 'Invalid email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _InfoField(
                                label: 'Phone Number',
                                icon: Icons.phone,
                                controller: _controllers['phone']!,
                                enabled: _isEditing,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              _InfoField(
                                label: 'Date of Birth',
                                icon: Icons.cake,
                                controller: _controllers['dateOfBirth']!,
                                enabled: _isEditing,
                                readOnly: true,
                                onTap: _isEditing ? () => _selectDate(context) : null,
                              ),
                              const SizedBox(height: 16),
                              _InfoField(
                                label: 'Gender',
                                icon: Icons.wc,
                                controller: _controllers['gender']!,
                                enabled: _isEditing,
                              ),
                              const SizedBox(height: 16),
                              _InfoField(
                                label: 'Address',
                                icon: Icons.home,
                                controller: _controllers['address']!,
                                enabled: _isEditing,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Health Information
                        _SectionHeader(title: 'Health Information'),
                        const SizedBox(height: 16),
                        GlassCard(
                          child: Column(
                            children: [
                              _InfoField(
                                label: 'A1C Level (%)',
                                icon: Icons.bloodtype,
                                controller: _controllers['a1c']!,
                                enabled: _isEditing,
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value?.isNotEmpty ?? false) {
                                    final a1c = double.tryParse(value!);
                                    if (a1c == null) return 'Invalid A1C value';
                                    if (a1c < 4 || a1c > 20) return 'A1C should be between 4-20%';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _InfoField(
                                label: 'Weight (kg)',
                                icon: Icons.monitor_weight,
                                controller: _controllers['weight']!,
                                enabled: _isEditing,
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value?.isNotEmpty ?? false) {
                                    final weight = double.tryParse(value!);
                                    if (weight == null) return 'Invalid weight';
                                    if (weight < 20 || weight > 300) return 'Weight should be between 20-300 kg';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Emergency Contact
                        _SectionHeader(title: 'Emergency Contact'),
                        const SizedBox(height: 16),
                        GlassCard(
                          child: Column(
                            children: [
                              _InfoField(
                                label: 'Contact Name',
                                icon: Icons.contact_emergency,
                                controller: _controllers['emergencyContact']!,
                                enabled: _isEditing,
                              ),
                              const SizedBox(height: 16),
                              _InfoField(
                                label: 'Contact Phone',
                                icon: Icons.phone_in_talk,
                                controller: _controllers['emergencyPhone']!,
                                enabled: _isEditing,
                                keyboardType: TextInputType.phone,
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
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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

  Future<void> _selectDate(BuildContext context) async {
    // Parse existing date if available
    DateTime initialDate = DateTime(1990, 5, 15);
    if (_controllers['dateOfBirth']!.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_controllers['dateOfBirth']!.text);
      } catch (e) {
        // Use default if parsing fails
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _controllers['dateOfBirth']!.text =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
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

class _InfoField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool enabled;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;

  const _InfoField({
    required this.label,
    required this.icon,
    required this.controller,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.readOnly = false,
    this.onTap,
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
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          onTap: onTap,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}