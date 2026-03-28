import 'dart:convert';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tokn/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tokn/utils/error_mapper.dart';




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
    try {
      // 1. Check uniqueness in profiles table first
      final isRegistered = await SupabaseService().isEmailOrPhoneRegistered(email, phone);
      if (isRegistered) {
        return {
          'success': false, 
          'message': 'Account with this email or phone number already exists.'
        };
      }

      String formattedPhone = phone;
      if (RegExp(r'^\d{10}$').hasMatch(phone) && !phone.startsWith('+')) {
        formattedPhone = '+91$phone';
      }

      // Use signInWithOtp — proven to deliver SMS reliably
      // This creates the user in auth.users if they don't exist
      // and sends an 'sms' type OTP
      await SupabaseService().signInWithOtp(
        phone: formattedPhone,
      );

      return {
        'success': true,
        'message': 'Verification code sent.',
      };

    } catch (e) {
      return {'success': false, 'message': ErrorMapper.mapError(e.toString())};
    }

  }


  // Auth: Login with Password
  static Future<Map<String, dynamic>> login({
    required String identifier, // Email or Phone
    required String password,
  }) async {
    try {
      bool isPhone = RegExp(r'^\d{10}$').hasMatch(identifier);
      String formattedIdentifier = identifier;
      if (isPhone && !identifier.startsWith('+')) {
        formattedIdentifier = '+91$identifier';
      }

      final response = await SupabaseService().signInWithPassword(
        email: !isPhone ? formattedIdentifier : null,
        phone: isPhone ? formattedIdentifier : null,
        password: password,
      );
      return {
        'success': true,
        'user': response.user,
        'session': response.session,
      };
    } catch (e) {
      return {'success': false, 'message': ErrorMapper.mapError(e.toString())};
    }

  }



  // Auth: Send OTP
  static Future<Map<String, dynamic>> sendOtp({
    String? email,
    String? phone,
  }) async {
    try {
      await SupabaseService().signInWithOtp(email: email, phone: phone);
      return {'success': true, 'message': 'OTP sent successfully.'};
    } catch (e) {
      return {'success': false, 'message': ErrorMapper.mapError(e.toString())};
    }

  }


  // Auth: Verify OTP
  static Future<Map<String, dynamic>> verifyOtp({
    String? email,
    String? phone,
    required String otp,
  }) async {
    try {
      final response = await SupabaseService().verifyOTP(
        email: email,
        phone: phone,
        token: otp,
        type: email != null ? OtpType.email : OtpType.sms,
      );
      return {
        'success': true,
        'user': response.user,
        'session': response.session,
      };
    } catch (e) {
      return {'success': false, 'message': ErrorMapper.mapError(e.toString())};
    }

  }

  // Auth: Verify Signup OTP & Create Profile
  static Future<Map<String, dynamic>> verifySignupOtp({
    required String email,
    required String phone,
    required String fullName,
    required String password,
    required String otp,
  }) async {
    try {
      String formattedPhone = phone;
      if (RegExp(r'^\d{10}$').hasMatch(phone) && !phone.startsWith('+')) {
        formattedPhone = '+91$phone';
      }

      final response = await SupabaseService().verifyOTP(
        phone: formattedPhone,
        token: otp,
        type: OtpType.sms,
      );

      if (response.user != null) {
        // After OTP success, set the email/password (Root Fix)
        try {
          await SupabaseService().updateUser(
            email: email,
            password: password,
          );
        } catch (e) {
          final errorStr = e.toString().toLowerCase();
          // If email is already set to THIS user or another one, it might fail.
          // We only throw if it's a "critical" error other than "already exists"
          if (!errorStr.contains('exists') && !errorStr.contains('already registered')) {
            rethrow;
          }
        }
        
        // Finalize profile creation
        try {
          await SupabaseService().createUserProfile(
            fullName: fullName,
            email: email,
            phone: formattedPhone,
          );
        } catch (e) {
          // If profile already exists, we can still proceed
          if (!e.toString().toLowerCase().contains('already exists') && 
              !e.toString().toLowerCase().contains('unique')) {
            rethrow;
          }
        }

        return {'success': true, 'message': 'Signup successful!'};
      }
      
      return {'success': false, 'message': 'Verification failed. Please try again.'};
    } catch (e) {
      return {'success': false, 'message': ErrorMapper.mapError(e.toString())};
    }
  }


  // Auth: Reset Password

  static Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await SupabaseService().resetPassword(email);
      return {'success': true, 'message': 'Password reset link sent to your email.'};
    } catch (e) {
      return {'success': false, 'message': ErrorMapper.mapError(e.toString())};
    }

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
    String type = 'Normal',
    double price = 19.0,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'data': {
        '_id': 'booking_123',
        'hospital': hospitalId,
        'booking_date': date,
        'booking_time': time,
        'booking_type': type,
        'booking_price': price,
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
    await SupabaseService().signOut();
    await _storage.delete(key: 'jwt_token');
  }


  // Check if logged in
  static Future<bool> isLoggedIn() async {
    return SupabaseService.client.auth.currentSession != null;
  }

}
