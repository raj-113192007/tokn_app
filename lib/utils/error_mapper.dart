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
        lowerError.contains('over_email_send_rate_limit')) {
      return "Too many requests. Please wait a few minutes before trying again.";
    }

    if (lowerError.contains('otp expired') || lowerError.contains('invalid token')) {
      return "Invalid or expired OTP. Please request a new one.";
    }

    // Default fallback
    return error.split(':').last.trim();
  }

}
