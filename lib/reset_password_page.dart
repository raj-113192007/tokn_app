import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/animation_utils.dart';
import 'package:tokn/services/supabase_service.dart';
import 'package:tokn/widgets/tokn_snackbar.dart';
import 'package:tokn/login_page.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Set New Password',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              'Create New Password',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E4C9D),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Please enter and confirm your new password to secure your account.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 50),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: 'New Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2E4C9D), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outline),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2E4C9D), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ScaleOnTap(
                onTap: _isLoading ? null : _handleResetPassword,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E4C9D),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: _isLoading 
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Reset Password',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      ToknSnackBar.show(context, message: 'Please fill all fields', type: SnackBarType.error);
      return;
    }

    if (password != confirmPassword) {
      ToknSnackBar.show(context, message: 'Passwords do not match', type: SnackBarType.error);
      return;
    }

    if (password.length < 6) {
      ToknSnackBar.show(context, message: 'Password must be at least 6 characters', type: SnackBarType.error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await SupabaseService().updateUser(password: password);
      
      if (mounted) {
        ToknSnackBar.show(context, message: 'Password reset successful!', type: SnackBarType.success);
        // Go back to login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ToknSnackBar.show(context, message: 'Failed to reset password: ${e.toString()}', type: SnackBarType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
