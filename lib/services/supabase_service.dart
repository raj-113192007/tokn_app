import 'dart:io';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';


class SupabaseService {
  static final client = Supabase.instance.client;

  // 1. Check if email or phone is already registered in profiles
  Future<bool> isEmailOrPhoneRegistered(String email, String phone) async {
    // Normalizing phone and email for better matching (best handled in DB, but app-side check is good too)
    String formattedPhone = phone.trim();
    if (RegExp(r'^\d{10}$').hasMatch(formattedPhone) && !formattedPhone.startsWith('+')) {
      formattedPhone = '+91$formattedPhone';
    }

    final response = await client
        .from('profiles')
        .select('id')
        .or('email.eq.${email.trim().toLowerCase()},phone_number.eq.$formattedPhone');
    
    return (response as List).isNotEmpty;
  }


  // 1. Get current user profile

  Future<Map<String, dynamic>?> getProfile() async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    final response = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    
    // Auto-generate custom_id if missing
    if (response != null && (response['custom_id'] == null || response['custom_id'] == 'Pending')) {
      final customId = 'usr${Random().nextInt(900000) + 100000}';
      await client.from('profiles').update({'custom_id': customId}).eq('id', user.id);
      response['custom_id'] = customId;
    }
    
    return response;
  }

  // 2. Stream tokens for a user (Real-time)
  Stream<List<Map<String, dynamic>>> streamUserTokens() {
    final user = client.auth.currentUser;
    if (user == null) return Stream.value([]);

    return client
        .from('tokens')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('booking_time');
  }

  // 3. Book a new token
  Future<void> bookToken({
    required String doctorId,
    required String hospitalId,
    required int tokenNumber,
    String? patientName,
    String? description,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    await client.from('tokens').insert({
      'user_id': user.id,
      'doctor_id': doctorId,
      'hospital_id': hospitalId,
      'token_number': tokenNumber,
      'patient_name': patientName ?? 'You',
      'problem_description': description ?? '',
      'status': 'pending',
    });
  }

  // 4. Phone Authentication - Start (Sends OTP)
  // 4. Phone Authentication - Start (Sends OTP)
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await client.auth.signUp(
      email: email.trim().toLowerCase(),
      password: password,
      data: {'full_name': fullName},
    );
    return response;
  }

  // Auth: Sign up with Phone/Password
  Future<AuthResponse> signUpWithPhone({
    required String phone,
    required String password,
    required String fullName,
  }) async {
    final response = await client.auth.signUp(
      phone: phone.trim(),
      password: password,
      data: {'full_name': fullName},
    );
    return response;
  }

  // 2. Auth: Sign in with Password (Email or Phone)
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


  // 3. Auth: Sign in with OTP (Email or Phone)
  Future<void> signInWithOtp({
    String? email,
    String? phone,
  }) async {
    await client.auth.signInWithOtp(
      email: email,
      phone: phone,
    );
  }

  // 4. Verify OTP
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

  // 5. Auth: Reset Password
  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }



  // Update User Location
  Future<void> updateUserLocation(double lat, double lng) async {
    final user = client.auth.currentUser;
    if (user != null) {
      await client.from('profiles').upsert({
        'id': user.id,
        'last_lat': lat,
        'last_lng': lng,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // Create or Update User Profile (only after verification)
  Future<void> createUserProfile({
    required String fullName,
    required String email,
    String? phone,
  }) async {
    final user = client.auth.currentUser;
    if (user != null) {
      // Generate a unique ID like "us213213"
      final customId = 'usr${Random().nextInt(900000) + 100000}';
      
      await client.from('profiles').upsert({
        'id': user.id,
        'custom_id': customId,
        'full_name': fullName,
        'email': email.trim().toLowerCase(),
        'phone_number': phone ?? user.phone,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // Update existing profile fields (e.g. from Edit Profile Page or Complete Profile Page)
  Future<void> updateProfileDetails(Map<String, dynamic> data) async {
    final user = client.auth.currentUser;
    if (user != null) {
      data['updated_at'] = DateTime.now().toIso8601String();
      await client.from('profiles').update(data).eq('id', user.id);
    }
  }



  // Upload Profile Photo
  Future<String?> uploadProfilePhoto(String filePath) async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    final file = File(filePath);
    final fileExt = filePath.split('.').last;
    final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final path = 'avatars/$fileName';

    await client.storage.from('avatars').upload(path, file);
    final imageUrl = client.storage.from('avatars').getPublicUrl(path);

    await client.from('profiles').update({
      'avatar_url': imageUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', user.id);

    return imageUrl;
  }

  // 7. Update User (e.g. set password/email after OTP signup)
  Future<void> updateUser({String? email, String? password}) async {
    await client.auth.updateUser(
      UserAttributes(
        email: email,
        password: password,
      ),
    );
  }

  // 8. Resend OTP
  Future<void> resendOTP({
    String? email,
    String? phone,
    required OtpType type,
  }) async {
    await client.auth.resend(
      email: email,
      phone: phone,
      type: type,
    );
  }

  // 9. Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // 10. Delete User Account
  Future<void> deleteUserAccount() async {
    await client.rpc('delete_user');
    await signOut();
  }

  // 11. Liked Hospitals
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
        // Unlike
        await client
            .from('liked_hospitals')
            .delete()
            .eq('user_id', user.id)
            .eq('hospital_id', hospitalId);
        return false;
      } else {
        // Like
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

  // 12. Family Members
  Future<bool> addFamilyMember(Map<String, dynamic> data) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    
    data['user_id'] = user.id;

    try {
      await client.from('family_members').insert(data);
      return true;
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
}



