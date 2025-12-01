class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final DateTime dateOfBirth;
  final String gender;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.dateOfBirth,
    required this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
    };
  }
}

class GlucoseReading {
  final String id;
  final double value;
  final DateTime timestamp;
  final String type; // 'before_meal', 'after_meal', 'fasting', 'bedtime'
  final String? notes;

  GlucoseReading({
    required this.id,
    required this.value,
    required this.timestamp,
    required this.type,
    this.notes,
  });

  bool get isInRange => value >= 70 && value <= 180;
  bool get isHigh => value > 180;
  bool get isLow => value < 70;

  factory GlucoseReading.fromJson(Map<String, dynamic> json) {
    return GlucoseReading(
      id: json['id'],
      value: json['value'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'notes': notes,
    };
  }
}

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String frequency; // 'once_daily', 'twice_daily', etc.
  final List<String> times; // ['08:00', '20:00']
  final bool isActive;
  final String icon; // emoji or icon name

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.times,
    this.isActive = true,
    this.icon = '💊',
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      times: List<String>.from(json['times']),
      isActive: json['isActive'] ?? true,
      icon: json['icon'] ?? '💊',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'times': times,
      'isActive': isActive,
      'icon': icon,
    };
  }
}

class MedicationLog {
  final String id;
  final String medicationId;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final bool isTaken;

  MedicationLog({
    required this.id,
    required this.medicationId,
    required this.scheduledTime,
    this.takenTime,
    this.isTaken = false,
  });

  bool get isPending => !isTaken && scheduledTime.isAfter(DateTime.now());
  bool get isDueSoon => !isTaken && 
      scheduledTime.difference(DateTime.now()).inMinutes <= 30;
  bool get isMissed => !isTaken && scheduledTime.isBefore(DateTime.now());

  factory MedicationLog.fromJson(Map<String, dynamic> json) {
    return MedicationLog(
      id: json['id'],
      medicationId: json['medicationId'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      takenTime: json['takenTime'] != null 
          ? DateTime.parse(json['takenTime']) 
          : null,
      isTaken: json['isTaken'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'takenTime': takenTime?.toIso8601String(),
      'isTaken': isTaken,
    };
  }
}

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? imageUrl;
  final List<String>? imageUrls;
  final String? audioPath;
  final Duration? audioDuration;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.imageUrl,
    this.imageUrls,
    this.audioPath,
    this.audioDuration,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}

class HealthInsight {
  final String id;
  final String title;
  final String description;
  final String type; // 'success', 'warning', 'info'
  final String icon;
  final DateTime timestamp;

  HealthInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.icon,
    required this.timestamp,
  });

  factory HealthInsight.fromJson(Map<String, dynamic> json) {
    return HealthInsight(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      icon: json['icon'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'icon': icon,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
