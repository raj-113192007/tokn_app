// ignore_for_file: avoid_print, unused_local_variable, unused_element, use_build_context_synchronously, unused_field, file_names, constant_identifier_names, deprecated_member_use, unused_import
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient('https://wmcyhvbwtqcroolbyozl.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndtY3lodmJ3dHFjcm9vbGJ5b3psIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ0Mjc2NzQsImV4cCI6MjA5MDAwMzY3NH0.rtWprVrlFC940s889nbpFAfDFgCktd5XLAHkhXp5Xlk');
  try {
    print('Calling signInWithOtp for a test phone number...');
    await supabase.auth.signInWithOtp(
      phone: '+919999999999',
    );
    print('OTP Sent successfully via signInWithOtp');
  } catch (e) {
    print('Error with signInWithOtp: $e');
  }
}
