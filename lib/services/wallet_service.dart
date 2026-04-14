// ignore_for_file: avoid_print, unused_local_variable, unused_element, use_build_context_synchronously, unused_field, file_names, constant_identifier_names, deprecated_member_use, unused_import
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletService {
  final _supabase = Supabase.instance.client;

  // The receiver's UPI ID (the raj slice provided: 7061121632@slc)
  static const String receiverUpiId = '7061121632@slc';
  static const String receiverName = 'TokN Payments';

  // Get current wallet balance
  Future<double> getBalance() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 0.0;

    try {
      final response = await _supabase
          .from('wallets')
          .select('balance')
          .eq('id', userId)
          .maybeSingle();
      
      if (response == null) return 0.0;
      return (response['balance'] as num).toDouble();
    } catch (e) {
      print('Error fetching balance: $e');
      return 0.0;
    }
  }

  // Get transaction history
  Future<List<Map<String, dynamic>>> getTransactionHistory() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('wallet_transactions')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  // Initiate UPI Payment via URL Launcher
  Future<bool> launchUpiPayment({required double amount, String? note}) async {
    // Create the UPI URI with proper encoding for all parameters
    final Map<String, String> queryParams = {
      'pa': receiverUpiId,
      'pn': receiverName,
      'am': amount.toStringAsFixed(2),
      'cu': 'INR',
    };
    
    if (note != null && note.isNotEmpty) {
      queryParams['tn'] = note;
    }

    final Uri uri = Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: queryParams,
    );

    try {
      // Use launchUrl directly with a fallback check
      // For UPI, LaunchMode.externalApplication is crucial to trigger the chooser
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        print('Direct launch returned false for URI: $uri');
        // Fallback for some specific Android configurations
        return await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      }
      return true;
    } catch (e) {
      print('Error launching UPI: $e');
      return false;
    }
  }

  // Update balance in Supabase after successful UPI payment
  Future<bool> finalizeRecharge({
    required double amount,
    required String txnId,
    required String responseCode,
    String? description,
  }) async {
    try {
      await _supabase.rpc('add_wallet_funds', params: {
        'p_amount': amount,
        'p_description': description ?? 'Wallet Recharge',
        'p_txn_id': txnId,
        'p_response_code': responseCode,
      });
      return true;
    } catch (e) {
      print('Error finalizing recharge: $e');
      return false;
    }
  }

  // Deduct balance from wallet
  Future<Map<String, dynamic>> deductBalance({
    required double amount,
    required String description,
    String? referenceId,
  }) async {
    try {
      final response = await _supabase.rpc('deduct_wallet_funds', params: {
        'p_amount': amount,
        'p_description': description,
        'p_reference_id': referenceId,
      });
      return {'success': true, 'data': response};
    } catch (e) {
      print('Error deducting balance: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
