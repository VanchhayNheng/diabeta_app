import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/profile_service.dart';

class ProfileAvatar extends StatefulWidget {
  final double size;
  final bool editable;
  final VoidCallback? onImageChanged;
  final double borderWidth;

  const ProfileAvatar({
    super.key,
    this.size = 100,
    this.editable = false,
    this.onImageChanged,
    this.borderWidth = 3,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  String? _profileImagePath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    setState(() => _isLoading = true);

    final path = await ProfileService.getProfileImagePath();

    setState(() {
      _profileImagePath = path;
      _isLoading = false;
    });
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              if (_profileImagePath != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _removeImage();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final path = await ProfileService.pickProfileImage();
    if (path != null) {
      setState(() => _profileImagePath = path);
      widget.onImageChanged?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Profile photo updated')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    final path = await ProfileService.takeProfilePhoto();
    if (path != null) {
      setState(() => _profileImagePath = path);
      widget.onImageChanged?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Profile photo updated')),
        );
      }
    }
  }

  Future<void> _removeImage() async {
    await ProfileService.removeProfileImage();
    setState(() => _profileImagePath = null);
    widget.onImageChanged?.call();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo removed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.editable ? _showImageSourceDialog : null,
      child: Stack(
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: AppTheme.primaryShadow,
              border: Border.all(
                color: Colors.white,
                width: widget.borderWidth,
              ),
            ),
            child: ClipOval(
              child: _isLoading
                  ? Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              )
                  : _profileImagePath != null && File(_profileImagePath!).existsSync()
                  ? Image.file(
                File(_profileImagePath!),
                width: widget.size,
                height: widget.size,
                fit: BoxFit.cover,
              )
                  : Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.primaryShadow,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/nick_wilde.jpg'), // Your image path
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          if (widget.editable)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: widget.size * 0.3,
                height: widget.size * 0.3,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: widget.size * 0.15,
                ),
              ),
            ),
        ],
      ),
    );
  }
}