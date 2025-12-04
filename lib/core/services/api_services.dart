import 'package:dio/dio.dart';

/// Base API configuration
class ApiConfig {
  static const String baseUrl = 'http://203.241.228.97:8000';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
}

/// Base API client with common configuration
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConfig.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConfig.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('RESPONSE[${response.statusCode}] => DATA: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('ERROR[${error.response?.statusCode}] => MESSAGE: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}

/// User service
class UserService {
  final ApiClient _apiClient = ApiClient();

  /// Get user information by user_id
  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    try {
      final response = await _apiClient.dio.get('/api/users/$userId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create new user
  Future<Map<String, dynamic>> createUser({
    required String userId,
    required String email,
    required String fullName,
    required String phone,
    required String dateOfBirth,
    required String gender,
    double? a1c,
    double? weight,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/users/',
        data: {
          'user_id': userId,
          'email': email,
          'full_name': fullName,
          'phone': phone,
          'date_of_birth': dateOfBirth,
          'gender': gender,
          if (a1c != null) 'a1c': a1c,
          if (weight != null) 'weight': weight,
          if (address != null) 'address': address,
          if (emergencyContactName != null) 'emergency_contact_name': emergencyContactName,
          if (emergencyContactPhone != null) 'emergency_contact_phone': emergencyContactPhone,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update user information
  Future<Map<String, dynamic>> updateUser({
    required String userId,
    required String email,
    required String fullName,
    required String phone,
    required String dateOfBirth,
    required String gender,
    double? a1c,
    double? weight,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/users/$userId',
        data: {
          'user_id': userId,
          'email': email,
          'full_name': fullName,
          'phone': phone,
          'date_of_birth': dateOfBirth,
          'gender': gender,
          if (a1c != null) 'a1c': a1c,
          if (weight != null) 'weight': weight,
          if (address != null) 'address': address,
          if (emergencyContactName != null) 'emergency_contact_name': emergencyContactName,
          if (emergencyContactPhone != null) 'emergency_contact_phone': emergencyContactPhone,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}

/// Glucose service with Today's Stats
class GlucoseService {
  final ApiClient _apiClient = ApiClient();

  /// Get today's glucose statistics
  Future<Map<String, dynamic>> getTodayStats({required String userId}) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/health/glucose/stats/today',
        queryParameters: {
          'user_id': userId,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getReadings({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/glucose/readings',
        queryParameters: {
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
        },
      );

      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> addReading({
    required double value,
    required String type,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/glucose/readings',
        data: {
          'value': value,
          'type': type,
          'notes': notes,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteReading(String id) async {
    try {
      await _apiClient.dio.delete('/glucose/readings/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/glucose/statistics',
        queryParameters: {
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}

/// AI Assistant service
class AIService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> sendMessage({
    required String text,
    String? imageBase64,
    String? audioBase64,
    required Map<String, dynamic> userProfile,
    String? sessionId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/chat',
        data: {
          'text': text,
          if (imageBase64 != null) 'image_base64': imageBase64,
          if (audioBase64 != null) 'audio_base64': audioBase64,
          'user_profile': userProfile,
          if (sessionId != null) 'session_id': sessionId,
        },
      );

      return response.data;
    } on DioException catch (e) {
      print('API Error: ${e.response?.statusCode}');
      print('Error data: ${e.response?.data}');
      print('Request URL: ${e.requestOptions.uri}');
      throw _handleError(e);
    }
  }

  String getMessageFromResponse(Map<String, dynamic> response) {
    return response['message'] ?? '';
  }

  Map<String, dynamic>? getMealData(Map<String, dynamic> response) {
    return response['structured']?['meal'];
  }

  Map<String, dynamic>? getPrediction(Map<String, dynamic> response) {
    return response['structured']?['prediction'];
  }
}

/// Authentication service
class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required DateTime dateOfBirth,
    required String gender,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'dateOfBirth': dateOfBirth.toIso8601String(),
          'gender': gender,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}

/// Medication service
class MedicationService {
  final ApiClient _apiClient = ApiClient();

  /// Get all medications for a user
  Future<List<Map<String, dynamic>>> getMedications({
    required String userId,
    bool activeOnly = true,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/health/medications',
        queryParameters: {
          'user_id': userId,
          'active_only': activeOnly,
        },
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Add or update medication
  Future<Map<String, dynamic>> saveMedication({
    required String medicationName,
    required String dosage,
    required String frequency,
    required String timeOfDay,
    String? notes,
    required String userId,
    int? id,
    bool isActive = true,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/health/medications',
        data: {
          'medication_name': medicationName,
          'dosage': dosage,
          'frequency': frequency,
          'time_of_day': timeOfDay,
          'notes': notes ?? '',
          'user_id': userId,
          if (id != null) 'id': id,
          'is_active': isActive,
          'created_at': DateTime.now().toIso8601String(),
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete (deactivate) medication
  Future<void> deleteMedication(int id, String userId) async {
    try {
      await _apiClient.dio.delete(
        '/api/health/medications/$id',
        queryParameters: {
          'user_id': userId,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}

/// Meal Log service
class MealLogService {
  final ApiClient _apiClient = ApiClient();

  /// Get all meal logs for a user
  Future<List<Map<String, dynamic>>> getMeals({
    required String userId,
    int limit = 100,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/health/meals',
        queryParameters: {
          'user_id': userId,
          'limit': limit,
        },
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Add or update meal
  Future<Map<String, dynamic>> saveMeal({
    required String mealName,
    required DateTime mealTime,
    required int carbs,
    int? protein,
    int? fat,
    required int calories,
    String? notes,
    String? imagePath,
    required String userId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/health/meals',
        data: {
          'meal_name': mealName,
          'meal_time': mealTime.toIso8601String(),
          'carbs': carbs,
          'protein': protein ?? 0,
          'fat': fat ?? 0,
          'calories': calories,
          'notes': notes ?? '',
          'image_path': imagePath,
          'user_id': userId,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete meal
  Future<void> deleteMeal(int id, String userId) async {
    try {
      await _apiClient.dio.delete(
        '/api/health/meals/$id',
        queryParameters: {
          'user_id': userId,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}

/// Exercise Log service
class ExerciseLogService {
  final ApiClient _apiClient = ApiClient();

  /// Get all exercise logs for a user
  Future<List<Map<String, dynamic>>> getExercises({
    required String userId,
    int limit = 50,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/health/exercise',
        queryParameters: {
          'user_id': userId,
          'limit': limit,
        },
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Add exercise
  Future<Map<String, dynamic>> saveExercise({
    required String activityType,
    required int durationMinutes,
    required String intensity,
    required int caloriesBurned,
    required DateTime exerciseTime,
    String? notes,
    String userId = 'alice_session',
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/health/exercise',
        data: {
          'activity_type': activityType,
          'duration_minutes': durationMinutes,
          'intensity': intensity,
          'calories_burned': caloriesBurned,
          'exercise_time': exerciseTime.toIso8601String(),
          'notes': notes ?? '',
          'user_id': userId,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete exercise
  Future<void> deleteExercise(int id, String userId) async {
    try {
      await _apiClient.dio.delete(
        '/api/health/exercise/$id',
        queryParameters: {
          'user_id': userId,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}

/// Error handling helper
String _handleError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Connection timeout. Please check your internet connection.';

    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      if (statusCode == 401) {
        return 'Unauthorized. Please login again.';
      } else if (statusCode == 404) {
        return 'Resource not found.';
      } else if (statusCode == 500) {
        return 'Server error. Please try again later.';
      }
      return error.response?.data['message'] ?? 'An error occurred.';

    case DioExceptionType.cancel:
      return 'Request cancelled.';

    default:
      return 'An unexpected error occurred. Please try again.';
  }
}