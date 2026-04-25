// ignore_for_file: avoid_print, unused_local_variable, unused_element, use_build_context_synchronously, unused_field, file_names, constant_identifier_names, deprecated_member_use, unused_import
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:tokn/services/chat_security_service.dart';



class SupabaseService {
  // Record Login Activity
  Future<void> recordLoginActivity() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return;

      String deviceInfo = "Unknown Device";
      String location = "Unknown Location";

      // 1. Get Device Info
      try {
        final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
        if (kIsWeb) {
          final webInfo = await deviceInfoPlugin.webBrowserInfo;
          deviceInfo = "${webInfo.browserName.name} on ${webInfo.platform}";
        } else if (Platform.isAndroid) {
          final androidInfo = await deviceInfoPlugin.androidInfo;
          deviceInfo = "${androidInfo.manufacturer} ${androidInfo.model} (Android ${androidInfo.version.release})";
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfoPlugin.iosInfo;
          deviceInfo = "${iosInfo.name} ${iosInfo.model} (iOS ${iosInfo.systemVersion})";
        } else if (Platform.isWindows) {
          final winInfo = await deviceInfoPlugin.windowsInfo;
          deviceInfo = "Windows: ${winInfo.computerName}";
        }
      } catch (e) {
        print("Error getting device info: $e");
      }

      // 2. Get Location (Approximate or via Geolocator if permission granted)
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
            Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: const Duration(seconds: 5),
            );
            location = "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
          }
        }
      } catch (e) {
        print("Error getting location: $e");
      }

      // 3. Insert into database
      await client.from('login_activity').insert({
        'user_id': user.id,
        'device_info': deviceInfo,
        'location': location,
        'login_time': DateTime.now().toIso8601String(),
      });
      
      print("Login activity recorded for user: ${user.id}");
    } catch (e) {
      print("Error recording login activity: $e");
    }
  }


  static final client = Supabase.instance.client;
  
  // Robust phone cleaning for Indian context
  String _formatPhone(String phone) {
    String clean = phone.trim().replaceAll(RegExp(r'[^\d+]'), '');
    
    // Remove leading zero
    if (clean.startsWith('0')) clean = clean.substring(1);
    
    // 10 digits -> add +91
    if (clean.length == 10 && !clean.startsWith('+')) {
      return '+91$clean';
    }
    
    // 12 digits starting with 91 -> add +
    if (clean.length == 12 && clean.startsWith('91')) {
      return '+$clean';
    }
    
    // If already has +, just return
    if (clean.startsWith('+')) return clean;
    
    // Fallback: if not empty and no plus, add it (might be other country code)
    if (clean.isNotEmpty && !clean.startsWith('+')) {
      return '+$clean';
    }
    
    return clean;
  }

  // ─── AUTH ───────────────────────────────────────────────

  // Check if email or phone is already registered in profiles
  Future<bool> isEmailOrPhoneRegistered(String email, String phone) async {
    String formattedPhone = _formatPhone(phone);

    print('SUPABASE_DEBUG: Checking registration for Email: "$email", Phone: "$formattedPhone"');
    
    try {
      PostgrestFilterBuilder query = client.from('profiles').select('id');
      
      final cleanEmail = email.trim().toLowerCase();
      
      if (cleanEmail.isNotEmpty && formattedPhone.isNotEmpty) {
        query = query.or('email.eq.$cleanEmail,phone.eq.$formattedPhone');
      } else if (cleanEmail.isNotEmpty) {
        query = query.eq('email', cleanEmail);
      } else if (formattedPhone.isNotEmpty) {
        query = query.eq('phone', formattedPhone);
      } else {
        return false;
      }

      final response = await query;
      final exists = (response as List).isNotEmpty;
      print('SUPABASE_DEBUG: Registration check result: $exists');
      return exists;
    } catch (e) {
      print('SUPABASE_DEBUG: Registration check ERROR: $e');
      rethrow;
    }
  }

  // Sign up with Email
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await client.auth.signUp(
      email: email.trim().toLowerCase(),
      password: password,
      data: {'full_name': fullName},
    );
  }

  // Sign up with Phone
  Future<AuthResponse> signUpWithPhone({
    required String phone,
    required String password,
    required String fullName,
  }) async {
    final cleanedPhone = _formatPhone(phone);
    print('SUPABASE_DEBUG: Calling signUp with Phone: $cleanedPhone');
    
    try {
      final response = await client.auth.signUp(
        phone: cleanedPhone,
        password: password,
        data: {'full_name': fullName},
      );
      print('SUPABASE_DEBUG: signUp Response - UserID: ${response.user?.id}, Session: ${response.session != null}');
      return response;
    } catch (e) {
      print('SUPABASE_DEBUG: signUp ERROR: $e');
      rethrow;
    }
  }

  // Sign in with Password (Email or Phone)
  Future<AuthResponse> signInWithPassword({
    String? email,
    String? phone,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      phone: phone,
      password: password,
    );
  }

  // Sign in with OTP (Email or Phone)
  Future<void> signInWithOtp({
    String? email,
    String? phone,
  }) async {
    await client.auth.signInWithOtp(
      email: email,
      phone: phone,
    );
  }

  // Verify OTP
  Future<AuthResponse> verifyOTP({
    String? email,
    String? phone,
    required String token,
    OtpType type = OtpType.sms,
  }) async {
    return await client.auth.verifyOTP(
      email: email,
      phone: phone,
      token: token,
      type: type,
    );
  }



  // Reset Password (strictly via Mobile OTP as per requirement)
  Future<Map<String, dynamic>> resetPassword(String identifier) async {
    String formattedPhone = _formatPhone(identifier);

    print('SUPABASE_DEBUG: Attempting password reset for $formattedPhone');

    // Check if user exists with this phone
    final isRegistered = await isEmailOrPhoneRegistered('', formattedPhone);

    if (!isRegistered) {
      print('SUPABASE_DEBUG: User not found for reset');
      throw Exception('No account found with this phone number.');
    }
    
    try {
      print('SUPABASE_DEBUG: Sending OTP via signInWithOtp for reset (Phone: $formattedPhone)');
      await client.auth.signInWithOtp(
        phone: formattedPhone,
      );
      print('SUPABASE_DEBUG: Reset OTP sent successfully');
      return {'success': true, 'type': 'phone', 'phone': formattedPhone};
    } catch (e) {
      print('SUPABASE_DEBUG: signInWithOtp ERROR: $e');
      if (e is AuthException) {
        print('SUPABASE_DEBUG: AuthException details: ${e.message}, ${e.statusCode}');
      }
      rethrow;
    }
  }

  // Update User (e.g. set password/email after OTP signup)
  Future<void> updateUser({String? email, String? password}) async {
    await client.auth.updateUser(
      UserAttributes(
        email: email,
        password: password,
      ),
    );
  }

  // Resend OTP
  Future<void> resendOTP({
    String? email,
    String? phone,
    required OtpType type,
  }) async {
    final cleanedPhone = phone != null ? _formatPhone(phone) : null;
    print('SUPABASE_DEBUG: Calling resend OTP - Type: $type, Phone: $cleanedPhone');
    
    try {
      await client.auth.resend(
        email: email,
        phone: cleanedPhone,
        type: type,
      );
      print('SUPABASE_DEBUG: resend successful');
    } catch (e) {
      print('SUPABASE_DEBUG: resend ERROR: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Delete User Account
  Future<void> deleteUserAccount() async {
    await client.rpc('delete_user');
    await signOut();
  }

  // ─── PROFILE ───────────────────────────────────────────

  // Get current user profile
  // NOTE: custom_id is now auto-generated by DB trigger — no app-side generation needed
  Future<Map<String, dynamic>?> getProfile() async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    final response = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    
    return response;
  }

  // Create or Update User Profile (only after verification)
  // NOTE: custom_id is auto-generated by DB trigger on INSERT
  Future<void> createUserProfile({
    required String fullName,
    required String email,
    String? phone,
  }) async {
    final user = client.auth.currentUser;
    if (user != null) {
      await client.from('profiles').upsert({
        'id': user.id,
        'full_name': fullName,
        'email': email.trim().toLowerCase(),
        'phone': phone ?? user.phone,
        // updated_at is auto-set by DB trigger on UPDATE
      });
    }
  }

  // Update existing profile fields
  Future<void> updateProfileDetails(Map<String, dynamic> data) async {
    final user = client.auth.currentUser;
    if (user != null) {
      // updated_at is auto-set by DB trigger
      await client.from('profiles').update(data).eq('id', user.id);
    }
  }

  // Update User Location
  Future<void> updateUserLocation(double lat, double lng) async {
    final user = client.auth.currentUser;
    if (user != null) {
      await client.from('profiles').upsert({
        'id': user.id,
        'last_lat': lat,
        'last_lng': lng,
      });
    }
  }

  // Upload Profile Photo
  Future<String?> uploadProfilePhoto(String filePath) async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    final file = File(filePath);
    final fileExt = filePath.split('.').last;
    final fileName = '${user.id}_profile_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final path = 'profiles/$fileName'; // Categorized path

    await client.storage.from('avatars').upload(path, file);
    final imageUrl = client.storage.from('avatars').getPublicUrl(path);

    await client.from('profiles').update({
      'avatar_url': imageUrl,
    }).eq('id', user.id);

    return imageUrl;
  }

  // Upload Family Member Photo
  Future<String?> uploadFamilyMemberPhoto(String memberId, String filePath) async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    final file = File(filePath);
    final fileExt = filePath.split('.').last;
    final fileName = '${memberId}_member_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final path = 'family/$fileName'; // Categorized path

    await client.storage.from('avatars').upload(path, file);
    final imageUrl = client.storage.from('avatars').getPublicUrl(path);

    await client.from('family_members').update({
      'avatar_url': imageUrl,
    }).eq('id', memberId).eq('user_id', user.id);

    return imageUrl;
  }

  // ─── TOKENS ────────────────────────────────────────────

  // Stream tokens for a user (Real-time)
  Stream<List<Map<String, dynamic>>> streamUserTokens() {
    final user = client.auth.currentUser;
    if (user == null) return Stream.value([]);

    return client
        .from('tokens')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('created_at');
  }

  // Book a new token
  Future<Map<String, dynamic>> bookToken({
    required String hospitalId,
    required String bookingType,
    required double price,
    String? patientName,
    String? description,
    String? doctorId,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    // Generate a random token number for now (In real app, this would be auto-incremented by DB)
    final tokenNumber = (DateTime.now().millisecondsSinceEpoch % 100) + 1;

    final response = await client.from('tokens').insert({
      'user_id': user.id,
      'hospital_id': hospitalId,
      'doctor_id': doctorId, // Optional
      'token_number': tokenNumber,
      'patient_name': patientName ?? 'You',
      'problem_description': description ?? '',
      'booking_type': bookingType,
      'price': price,
      'status': 'pending',
    }).select().single();

    return response;
  }

  // Atomic booking with Wallet (Deduct + Book in one go)
  Future<Map<String, dynamic>> bookTokenWithWallet({
    required String hospitalId,
    required String bookingType,
    required double price,
    String? patientName,
    String? description,
    String? doctorId,
  }) async {
    try {
      final response = await client.rpc('book_token_with_wallet', params: {
        'p_hospital_id': hospitalId,
        'p_doctor_id': doctorId ?? '',
        'p_patient_name': patientName ?? 'You',
        'p_description': description ?? '',
        'p_booking_type': bookingType,
        'p_price': price,
      });
      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('Error booking with wallet: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Book token with UPI (Record after external success)
  Future<Map<String, dynamic>> bookTokenWithUpi({
    required String hospitalId,
    required String bookingType,
    required double price,
    required String txnId,
    String? patientName,
    String? description,
    String? doctorId,
  }) async {
    try {
      final response = await client.rpc('book_token_with_upi', params: {
        'p_hospital_id': hospitalId,
        'p_doctor_id': doctorId ?? '',
        'p_patient_name': patientName ?? 'You',
        'p_description': description ?? '',
        'p_booking_type': bookingType,
        'p_price': price,
        'p_txn_id': txnId,
      });
      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('Error booking with UPI: $e');
      return {'success': false, 'error': e.toString()};
    }
  }


  // ─── LIKED HOSPITALS ──────────────────────────────────

  Future<bool> isHospitalLiked(String hospitalId) async {
    final user = client.auth.currentUser;
    if (user == null) return false;

    try {
      final data = await client
          .from('liked_hospitals')
          .select('id')
          .eq('user_id', user.id)
          .eq('hospital_id', hospitalId)
          .maybeSingle();
      return data != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleHospitalLike(String hospitalId) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final isLiked = await isHospitalLiked(hospitalId);
    try {
      if (isLiked) {
        await client
            .from('liked_hospitals')
            .delete()
            .eq('user_id', user.id)
            .eq('hospital_id', hospitalId);
        return false;
      } else {
        await client.from('liked_hospitals').insert({
          'user_id': user.id,
          'hospital_id': hospitalId,
        });
        return true;
      }
    } catch (e) {
      throw Exception('Failed to toggle like');
    }
  }

  Future<List<String>> getLikedHospitalIds() async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    try {
      final List<dynamic> data = await client
          .from('liked_hospitals')
          .select('hospital_id')
          .eq('user_id', user.id);
          
      return data.map((e) => e['hospital_id'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  // ─── FAMILY MEMBERS ───────────────────────────────────

  Future<Map<String, dynamic>?> addFamilyMember(Map<String, dynamic> data) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    
    // Ensure user_id is set
    data['user_id'] = user.id;

    try {
      final response = await client
          .from('family_members')
          .insert(data)
          .select()
          .single();
      return response;
    } catch (e) {
      print('Error adding family member: $e');
      throw Exception('Failed to add family member');
    }
  }

  Future<List<Map<String, dynamic>>> getFamilyMembers() async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    try {
      final List<dynamic> data = await client
          .from('family_members')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
          
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error fetching family members: $e');
      return [];
    }
  }

  Future<bool> deleteFamilyMember(String memberId) async {
    final user = client.auth.currentUser;
    if (user == null) return false;

    try {
      await client
          .from('family_members')
          .delete()
          .eq('id', memberId)
          .eq('user_id', user.id);
      return true;
    } catch (e) {
      return false;
    }
  }
  // ─── HOSPITALS ───────────────────────────────────────
  
  // fetch all Hospitals
  Future<List<Map<String, dynamic>>> getHospitals() async {
    try {
      final List<dynamic> data = await client
          .from('hospitals')
          .select()
          .eq('status', 'active') // Only show active hospitals to patients
          .order('full_name'); // Corrected from 'name' to 'full_name'
      
      return data.map((e) {
        final map = Map<String, dynamic>.from(e);
        map['_id'] = e['id'];
        map['name'] = e['full_name']; // Ensure UI gets 'name' from 'full_name'
        return map;
      }).toList();
    } catch (e) {
      print('Error fetching hospitals: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getHospitalById(String id) async {
    try {
      final data = await client
          .from('hospitals')
          .select('*, doctors(*)')
          .eq('id', id)
          .eq('status', 'active')
          .maybeSingle();
      return data;
    } catch (e) {
      print('Error fetching hospital by ID: $e');
      return null;
    }
  }
  // ─── SUPPORT TICKETS ───────────────────────────────────

  Future<void> submitSupportTicket({
    required String category,
    required String subject,
    required String message,
    File? attachment,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    String? attachmentUrl;
    if (attachment != null) {
      final fileExt = attachment.path.split('.').last;
      final fileName = '${user.id}_ticket_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = fileName;

      await client.storage.from('support_attachments').upload(path, attachment);
      attachmentUrl = client.storage.from('support_attachments').getPublicUrl(path);
    }

    await client.from('support_tickets').insert({
      'user_id': user.id,
      'category': category,
      'subject': subject,
      'message': message,
      'attachment_url': attachmentUrl,
      'status': 'open',
      'user_type': 'user',
    });
  }

  Future<List<Map<String, dynamic>>> getTicketMessages(String ticketId) async {
    try {
      final List<dynamic> data = await client
          .from('ticket_replies')
          .select('*')
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error fetching ticket messages: $e');
      return [];
    }
  }

  Future<void> sendTicketReply(String ticketId, String message) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await client.from('ticket_replies').insert({
      'ticket_id': ticketId,
      'sender_id': user.id,
      'message': message,
      'is_admin': false,
    });
  }

  Future<List<Map<String, dynamic>>> getSupportTickets() async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    final response = await client
        .from('support_tickets')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response as List);
  }

  // ─── CHAT MESSAGES ───────────────────────────────────

  static Future<List<Map<String, dynamic>>> getChatMessages({String? otherUserId}) async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    try {
      final query = client.from('chat_messages').select();
      
      PostgrestFilterBuilder finalQuery;
      if (otherUserId != null) {
        finalQuery = query.or('and(sender_id.eq.${user.id},receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.${user.id})');
      } else {
        // Support/Admin chat (where receiver_id is NULL)
        finalQuery = query.or('and(sender_id.eq.${user.id},receiver_id.is.null),and(sender_id.is.null,receiver_id.eq.${user.id})');
      }

      final response = await finalQuery.order('created_at', ascending: true);
      
      final msgs = List<Map<String, dynamic>>.from(response);
      
      // Decrypt messages
      for (var msg in msgs) {
        msg['message'] = ChatSecurityService.decryptMessage(
          msg['message'] ?? '', 
          msg['sender_id'], 
          msg['receiver_id']
        );
      }
      
      return msgs;
    } catch (e) {
      print('Error fetching chat messages: $e');
      return [];
    }
  }

  /// Sends a message (encrypted)
  static Future<void> sendChatMessage(String message, {String? receiverId, String senderType = 'user'}) async {
    final user = client.auth.currentUser;
    if (user == null) throw 'Not logged in';

    try {
      final encryptedMessage = ChatSecurityService.encryptMessage(message, user.id, receiverId);
      
      await client.from('chat_messages').insert({
        'sender_id': user.id,
        'receiver_id': receiverId,
        'sender_type': senderType,
        'message': encryptedMessage,
      });
    } catch (e) {
      print('Error sending chat message: $e');
      rethrow;
    }
  }

  /// Stream chat messages (Real-time + Decrypted)
  static Stream<List<Map<String, dynamic>>> streamChatMessages({String? otherUserId}) {
    final user = client.auth.currentUser;
    if (user == null) return Stream.value([]);

    // We stream all relevant messages and filter/decrypt in the map
    return client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((data) {
          final filtered = data.where((msg) {
            if (otherUserId != null) {
              return (msg['sender_id'] == user.id && msg['receiver_id'] == otherUserId) ||
                     (msg['sender_id'] == otherUserId && msg['receiver_id'] == user.id);
            } else {
              return (msg['sender_id'] == user.id && msg['receiver_id'] == null) ||
                     (msg['sender_id'] == null && msg['receiver_id'] == user.id);
            }
          }).toList();

          // Decrypt
          for (var msg in filtered) {
            msg['message'] = ChatSecurityService.decryptMessage(
              msg['message'] ?? '', 
              msg['sender_id'], 
              msg['receiver_id']
            );
          }
          return filtered;
        });
  }
}
