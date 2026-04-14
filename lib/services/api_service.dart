import 'dart:convert';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tokn/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tokn/utils/error_mapper.dart';




class ApiService {
  static const _storage = FlutterSecureStorage();

  // Helper to clean phone numbers strictly for Supabase
  static String _cleanPhone(String phone) {
    String cleaned = phone.trim().replaceAll(RegExp(r'[^\d+]'), '');
    if (RegExp(r'^\d{10}$').hasMatch(cleaned)) {
      cleaned = '+91$cleaned';
    }
    return cleaned;
  }

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
      final formattedPhone = _cleanPhone(phone);
      
      // 1. Check uniqueness in profiles table first
      final isRegistered = await SupabaseService().isEmailOrPhoneRegistered(email, formattedPhone);
      if (isRegistered) {
        return {
          'success': false, 
          'message': 'Account with this email or phone number already exists.'
        };
      }

      print('DEBUG_FLOW: Attempting signup for $formattedPhone');

      // Use signInWithOtp instead of signUp to guarantee OTP delivery, 
      // preventing silent failures if the user was partially created in Auth.
      await SupabaseService().signInWithOtp(
        phone: formattedPhone,
      );
      
      print('DEBUG_FLOW: signInWithOtp completed for $formattedPhone');

      return {
        'success': true,
        'autoConfirmed': false,
        'message': 'Verification code sent.',
      };
    } catch (e) {
      print('DEBUG_FLOW: ERROR: $e');
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
        type: OtpType.sms, // Fixed to use sms type for phone verification
      );

      if (response.user != null) {
        // Email is already in user metadata if we used signUpWithPhone, 
        // but we verify and set it formally here.
        try {
          await SupabaseService().updateUser(
            email: email,
            password: password,
          );
        } catch (e) {
          final errorStr = e.toString().toLowerCase();
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
    try {
      final hospitals = await SupabaseService().getHospitals();
      return {
        'success': true,
        'count': hospitals.length,
        'data': hospitals
      };
    } catch (e) {
      return {'success': false, 'message': ErrorMapper.mapError(e.toString())};
    }
  }

  // Hospitals: Get details with doctors
  static Future<Map<String, dynamic>?> getHospitalDetails(String id) async {
    try {
      return await SupabaseService().getHospitalById(id);
    } catch (e) {
      return null;
    }
  }

  // Bookings: Create
  static Future<Map<String, dynamic>> createBooking({
    required String hospitalId,
    required String date,
    required String time,
    String type = 'Normal',
    double price = 19.0,
    String? patientName,
    String? description,
  }) async {
    try {
      final data = await SupabaseService().bookToken(
        hospitalId: hospitalId,
        bookingType: type,
        price: price,
        patientName: patientName,
        description: description,
      );
      return {'success': true, 'data': data};
    } catch (e) {
      return {'success': false, 'error': ErrorMapper.mapError(e.toString())};
    }
  }

  // Bookings: Get My Bookings
  static Future<Map<String, dynamic>> getBookings() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return {'success': false, 'error': 'Not logged in'};

      final List<dynamic> rawData = await Supabase.instance.client
          .from('tokens')
          .select('*, hospital:hospital_id(full_name)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final data = rawData.map((item) {
        final map = Map<String, dynamic>.from(item);
        if (map['hospital'] != null) {
          map['hospital']['name'] = map['hospital']['full_name'];
        }
        return map;
      }).toList();

      return {
        'success': true,
        'count': data.length,
        'data': data
      };
    } catch (e) {
      return {'success': false, 'error': ErrorMapper.mapError(e.toString())};
    }
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
