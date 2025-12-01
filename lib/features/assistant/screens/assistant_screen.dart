import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';
import '../../../core/services/api_services.dart';
import '../../../shared/widgets/profile_avatar.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> with SingleTickerProviderStateMixin{
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIService _aiService = AIService();
  final ImagePicker _picker = ImagePicker();
  final AudioService _audioService = AudioService();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final Map<String, dynamic> _userProfile = {
    'a1c': 7.0,
    'age': 35,
    'weight': 70,
  };

  String? _sessionId;
  final List<ChatMessage> _messages = [];
  final List<File> _selectedImages = [];
  final List<String> _selectedImagesBase64 = [];
  bool _isRecording = false;
  bool _isSending = false;
  String? _recordedAudioPath;
  Duration? _recordingDuration;
  bool _isHolding = false;

  void _onMicButtonDown() {
    if (!_isRecording) {
      setState(() {
        _isHolding = true;
      });
      _startRecording();
    }
  }

  void _onMicButtonUp() {
    if (_isHolding && _isRecording) {
      setState(() {
        _isHolding = false;
      });
      _stopRecording();
    }
  }

  void _onMicButtonTap() {
    if (!_isHolding) {
      _toggleRecording();
    }
  }

  Future<void> _startRecording() async {
    final started = await _audioService.startRecording();

    if (started) {
      setState(() {
        _isRecording = true;
        _recordedAudioPath = null;
        _recordingDuration = null;
      });

      _pulseController.repeat(reverse: true);
    } else {
      setState(() {
        _isHolding = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Failed to start recording. Check microphone permission.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopRecording() async {
    _pulseController.stop();

    final path = await _audioService.stopRecording();

    setState(() {
      _isRecording = false;
      _recordedAudioPath = path;
    });

    if (path != null) {
      final duration = await _audioService.getAudioDuration(path);
      setState(() {
        _recordingDuration = duration;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _sessionId = 'user_${DateTime.now().millisecondsSinceEpoch}';

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _messages.addAll([
      ChatMessage(
        id: '1',
        content: 'Hello! I\'m your diabetes management assistant. I can help you track your meals, analyze nutrition, and predict blood sugar impacts. Send me photos of your meals or ask me anything!',
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ]);
  }

  void _pickImages() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      setState(() {
        _selectedImages.clear();
        _selectedImagesBase64.clear();
        _selectedImages.add(File(image.path));
        _selectedImagesBase64.add('service:image/jpeg;base64,$base64Image');
      });
    }
  }

  void _takePicture() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      setState(() {
        _selectedImages.clear();
        _selectedImagesBase64.clear();
        _selectedImages.add(File(image.path));
        _selectedImagesBase64.add('service:image/jpeg;base64,$base64Image');
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      _selectedImagesBase64.removeAt(index);
    });
  }

  void _clearAllImages() {
    setState(() {
      _selectedImages.clear();
      _selectedImagesBase64.clear();
    });
  }

  void _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '0:00';

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _sendMessage() async {
    final messageText = _messageController.text.trim();

    // Check if we have something to send
    if (messageText.isEmpty &&
        _selectedImagesBase64.isEmpty &&
        _recordedAudioPath == null) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    // Prepare service
    final imageBase64 = _selectedImagesBase64.isNotEmpty
        ? _selectedImagesBase64.first
        : null;

    String? audioBase64;
    String? permanentAudioPath;

    if (_recordedAudioPath != null) {
      try {
        audioBase64 = await _audioService.audioToBase64(_recordedAudioPath!);

        // Create a permanent copy of the audio file for playback
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final directory = Directory(_recordedAudioPath!).parent;
        permanentAudioPath = '${directory.path}/message_$timestamp.aac';
        await File(_recordedAudioPath!).copy(permanentAudioPath);
      } catch (e) {
        print('Error converting audio: $e');
      }
    }

    // Store image paths and audio path for display
    final messagePaths = List<String>.from(_selectedImages.map((f) => f.path));
    final audioDuration = _recordingDuration;

    // Add user message to UI with ALL components
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().toString(),
          content: messageText, // Keep the actual text message
          isUser: true,
          timestamp: DateTime.now(),
          imageUrls: messagePaths.isNotEmpty ? messagePaths : null,
          audioPath: permanentAudioPath, // Use permanent path
          audioDuration: audioDuration, // Add duration
        ),
      );
    });

    // Clear inputs
    _messageController.clear();
    _clearAllImages();

    // Delete the temporary recording file
    final tempAudioPath = _recordedAudioPath;
    setState(() {
      _recordedAudioPath = null;
      _recordingDuration = null;
    });

    _scrollToBottom();

    try {
      // Send to API
      final response = await _aiService.sendMessage(
        text: messageText.isNotEmpty ? messageText : (permanentAudioPath != null ? 'Voice message' : 'Analyze this meal'),
        imageBase64: imageBase64,
        audioBase64: audioBase64,
        userProfile: _userProfile,
        sessionId: _sessionId,
      );

      final aiMessage = _aiService.getMessageFromResponse(response);

      setState(() {
        _messages.add(
          ChatMessage(
            id: DateTime.now().toString(),
            content: aiMessage,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });

      // Delete the temp recording file (not the permanent one)
      if (tempAudioPath != null) {
        await _audioService.deleteAudio(tempAudioPath);
      }

      _scrollToBottom();

    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            id: DateTime.now().toString(),
            content: 'Sorry, I encountered an error. Please try again.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                boxShadow: AppTheme.elevation1,
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🤖', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Assistant',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _isRecording ? '🔴 Recording...' : 'Online', // Show recording status
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _isRecording ? Colors.red : AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _MessageBubble(
                    message: message,
                    audioService: _audioService,
                  );
                },
              ),
            ),

            // Voice Recording Preview
            if (_recordedAudioPath != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.elevation1,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Voice Recording',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatDuration(_recordingDuration),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () => _audioService.playAudio(_recordedAudioPath!),
                      color: AppTheme.primaryPurple,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _recordedAudioPath = null;
                          _recordingDuration = null;
                        });
                      },
                      color: AppTheme.errorRed,
                    ),
                  ],
                ),
              ),

            // Images Preview
            if (_selectedImages.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImages[index],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            // Input Area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                boxShadow: AppTheme.elevation1,
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Voice Button
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return GestureDetector(
                          onLongPressStart: (_) => _onMicButtonDown(),
                          onLongPressEnd: (_) => _onMicButtonUp(),
                          onTap: _onMicButtonTap,
                          child: Transform.scale(
                            scale: _isRecording ? _pulseAnimation.value : 1.0,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _isRecording
                                    ? Colors.red.withOpacity(0.1)
                                    : const Color(0xFFF5F5F5),
                                shape: BoxShape.circle,
                                border: _isRecording
                                    ? Border.all(color: Colors.red, width: 2)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  _isRecording ? '⏹️' : '🎤',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),

                    // Camera Button
                    _ActionButton(
                      icon: '📷',
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
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
                                      _takePicture();
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.photo_library),
                                    title: const Text('Choose from Gallery'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickImages();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),

                    // Text Input
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: _isRecording ? 'Recording...' : 'Message...',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          enabled: !_isRecording,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Send Button
                    GestureDetector(
                      onTap: _isSending || _isRecording ? null : _sendMessage,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: _isRecording
                              ? LinearGradient(colors: [Colors.grey, Colors.grey.shade400])
                              : AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: _isRecording ? null : AppTheme.primaryShadow,
                        ),
                        child: Center(
                          child: _isSending
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _audioService.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final AudioService audioService;

  const _MessageBubble({
    super.key,
    required this.message,
    required this.audioService,
  });

  String _formatDuration(Duration? duration) {
    if (duration == null) return '0:00';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final List<String> images = message.imageUrls ??
        (message.imageUrl != null ? [message.imageUrl!] : []);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
        message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: message.isUser ? AppTheme.primaryGradient : null,
                    color: message.isUser
                        ? null
                        : Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 20),
                    ),
                    boxShadow: AppTheme.elevation1,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display images
                      if (images.isNotEmpty) ...[
                        if (images.length == 1)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(images[0]),
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: images.map((imagePath) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(imagePath),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 12),
                      ],

                      // Display voice message with playback
                      if (message.audioPath != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: message.isUser
                                ? Colors.white.withOpacity(0.2)
                                : AppTheme.primaryPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => audioService.playAudio(message.audioPath!),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: message.isUser
                                        ? Colors.white
                                        : AppTheme.primaryPurple,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: message.isUser
                                        ? AppTheme.primaryPurple
                                        : Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Voice Message',
                                    style: TextStyle(
                                      color: message.isUser
                                          ? Colors.white
                                          : AppTheme.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(message.audioDuration),
                                    style: TextStyle(
                                      color: message.isUser
                                          ? Colors.white.withOpacity(0.8)
                                          : AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (message.content.isNotEmpty) const SizedBox(height: 12),
                      ],

                      // Display text message
                      if (message.content.isNotEmpty)
                        Text(
                          message.content,
                          style: TextStyle(
                            color: message.isUser
                                ? Colors.white
                                : AppTheme.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                shape: BoxShape.circle,
                boxShadow: AppTheme.elevation1,
              ),
              child: const ProfileAvatar(
                editable: false,
                borderWidth: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    return '$hour:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}';
  }
}

class _ActionButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  final bool isActive;
  final double scale;

  const _ActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primaryPurple.withOpacity(0.1)
                : const Color(0xFFF5F5F5),
            shape: BoxShape.circle,
            border: isActive
                ? Border.all(color: Colors.red, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}