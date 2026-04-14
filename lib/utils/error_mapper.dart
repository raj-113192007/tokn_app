class ErrorMapper {
  static String mapError(String error) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('invalid login credentials') || 
        lowerError.contains('invalid-credentials')) {
      return "Invalid email or password. Please try again.";
    }
    
    if (lowerError.contains('user not found') || 
        lowerError.contains('user-not-found')) {
      return "No account found with these details.";
    }

    if (lowerError.contains('user already exists') || 
        lowerError.contains('already registered')) {
      return "This email or phone number is already registered.";
    }

    if (lowerError.contains('weak password')) {
      return "Password must be at least 8 characters long.";
    }

    if (lowerError.contains('network') || lowerError.contains('failed host lookup')) {
      return "Connection failed. Please check your internet.";
    }

    if (lowerError.contains('too many requests') || 
        lowerError.contains('over_email_send_rate_limit') ||
        lowerError.contains('over_sms_send_rate_limit')) {
      return "Too many requests. Please wait a few minutes before trying again.";
    }

    if (lowerError.contains('sms_provider_error') || 
        lowerError.contains('sms provider error') ||
        lowerError.contains('sms_send_failed')) {
      if (lowerError.contains('trial accounts cannot send messages to unverified numbers')) {
        return "System is using a Twilio Trial account. Cannot send OTP to unverified numbers.";
      }
      return "SMS service is temporarily unavailable. Please try again later or contact support.";
    }

    if (lowerError.contains('otp expired') || 
        lowerError.contains('otp_expired') || 
        lowerError.contains('invalid token') || 
        lowerError.contains('invalid_token')) {
      return "Invalid or expired OTP. Please request a new one.";
    }

    // Default fallback - cleaning up Supabase AuthException format
    String message = error.replaceAll('AuthException(message: ', '').replaceAll(')', '');
    if (message.contains(':')) {
      message = message.split(':').last.trim();
    }
    return message;
  }

}
