import 'dart:convert';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const _storage = FlutterSecureStorage();

  // Helper to get headers with token (not really needed for mock, but kept for interface)
  static Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Auth: Signup
  static Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    await _storage.write(key: 'jwt_token', value: 'mock_token_123');
    return {
      'success': true,
      'token': 'mock_token_123',
      'user': {
        'id': 'user_1',
        'full_name': fullName,
        'email': email,
        'phone_number': phone,
      }
    };
  }

  // Auth: Login
  static Future<Map<String, dynamic>> login({
    required String identifier, // Email or Phone
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    await _storage.write(key: 'jwt_token', value: 'mock_token_123');
    return {
      'success': true,
      'token': 'mock_token_123',
      'user': {
        'id': 'user_1',
        'full_name': 'Mock User',
        'email': identifier.contains('@') ? identifier : 'user@example.com',
        'phone_number': identifier.contains('@') ? '1234567890' : identifier,
      }
    };
  }

  // Auth: Send OTP
  static Future<Map<String, dynamic>> sendOtp({
    String? email,
    String? phone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'success': true,
      'message': 'Mock OTP sent successfully.'
    };
  }

  // Auth: Verify OTP
  static Future<Map<String, dynamic>> verifyOtp({
    String? email,
    String? phone,
    required String otp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    await _storage.write(key: 'jwt_token', value: 'mock_token_123');
    return {
      'success': true,
      'token': 'mock_token_123',
      'user': {
        'id': 'user_1',
        'full_name': 'Mock User',
        'email': email ?? 'user@example.com',
        'phone_number': phone ?? '1234567890',
      }
    };
  }

  // Hospitals: Get All
  static Future<Map<String, dynamic>> getHospitals() async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'count': 2,
      'data': [
        {
          '_id': 'hospital_1',
          'name': 'Mock General Hospital',
          'location': 'New York, USA',
          'description': 'A top-rated general hospital.',
          'type': 'General',
          'rating': 4.5
        },
        {
          '_id': 'hospital_2',
          'name': 'Mock City Clinic',
          'location': 'London, UK',
          'description': 'Specialized city clinic.',
          'type': 'Clinic',
          'rating': 4.2
        }
      ]
    };
  }

  // Bookings: Create
  static Future<Map<String, dynamic>> createBooking({
    required String hospitalId,
    required String date,
    required String time,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'data': {
        '_id': 'booking_123',
        'hospital': hospitalId,
        'booking_date': date,
        'booking_time': time,
        'status': 'Pending'
      }
    };
  }

  // Bookings: Get My Bookings
  static Future<Map<String, dynamic>> getBookings() async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'count': 1,
      'data': [
        {
          '_id': 'booking_123',
          'hospital': {
            '_id': 'hospital_1',
            'name': 'Mock General Hospital'
          },
          'booking_date': '2026-12-01',
          'booking_time': '10:00 AM',
          'status': 'Pending'
        }
      ]
    };
  }

  // Logout
  static Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    String? token = await _storage.read(key: 'jwt_token');
    return token != null;
  }
}
