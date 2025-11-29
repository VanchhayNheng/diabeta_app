import 'package:dio/dio.dart';

/// Base API configuration
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
          // Add API key if needed
          // 'X-API-Key': ApiConfig.apiKey,
        },
      ),
    );

    // Add interceptors for logging, auth tokens, etc.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          // final token = getStoredToken();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }
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

/// Example: Authentication Service
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
      
      // TODO: Store auth token
      // await _storeToken(response.data['token']);
      
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
      // TODO: Clear stored token
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}

/// Example: Glucose Service
class GlucoseService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Map<String, dynamic>>> getReadings({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/glucose/readings',  // Update this path based on your docs
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

/// AI Assistant Service - Updated for your API
class AIService {
  final ApiClient _apiClient = ApiClient();

  /// Send message to AI with optional image
  Future<Map<String, dynamic>> sendMessage({
    required String text,
    String? imageBase64,
    String? audioBase64,
    required Map<String, dynamic> userProfile,
    String? sessionId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/chat',  // Make sure this matches your API
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


  /// Extract just the message from response
  String getMessageFromResponse(Map<String, dynamic> response) {
    return response['message'] ?? '';
  }

  /// Get structured meal data from response
  Map<String, dynamic>? getMealData(Map<String, dynamic> response) {
    return response['structured']?['meal'];
  }

  /// Get blood sugar prediction from response
  Map<String, dynamic>? getPrediction(Map<String, dynamic> response) {
    return response['structured']?['prediction'];
  }
}

/// Example: Medication Service
class MedicationService {
  final ApiClient _apiClient = ApiClient();
  
  Future<List<Map<String, dynamic>>> getMedications() async {
    try {
      final response = await _apiClient.dio.get('/medications');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> addMedication({
    required String name,
    required String dosage,
    required List<String> times,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/medications',
        data: {
          'name': name,
          'dosage': dosage,
          'times': times,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> logMedication(String medicationId, DateTime takenAt) async {
    try {
      await _apiClient.dio.post(
        '/medications/$medicationId/log',
        data: {
          'takenAt': takenAt.toIso8601String(),
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

/// TODO: Implement token storage
// Future<void> _storeToken(String token) async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.setString('auth_token', token);
// }

// Future<String?> getStoredToken() async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getString('auth_token');
// }

// Future<void> clearStoredToken() async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.remove('auth_token');
// }
