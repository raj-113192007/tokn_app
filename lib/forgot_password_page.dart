// ignore_for_file: avoid_print, unused_local_variable, unused_element, use_build_context_synchronously, unused_field, file_names, constant_identifier_names, deprecated_member_use, unused_import
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/animation_utils.dart';
import 'services/api_service.dart';
import 'widgets/tokn_snackbar.dart';
import 'login_otp_page.dart';



class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

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
          'Forgot Password',
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
              'Reset Password',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E4C9D),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Enter your registered mobile number to receive a verification code.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 50),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Mobile Number',
                prefixIcon: const Icon(Icons.person_outline),
                prefixText: (_controller.text.isNotEmpty && RegExp(r'^\d+$').hasMatch(_controller.text)) 
                  ? '+91 ' : null,
                prefixStyle: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2E4C9D), width: 2),
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ScaleOnTap(
                onTap: _isLoading ? null : () async {
                  final input = _controller.text.trim();
                  if (input.isEmpty) return;
                  
                  setState(() => _isLoading = true);
                  final result = await ApiService.resetPassword(input);
                  
                  if (mounted) {
                    setState(() => _isLoading = false);
                    ToknSnackBar.show(
                      context, 
                      message: result['message'],
                      type: result['success'] ? SnackBarType.success : SnackBarType.error,
                    );
                    
                    if (result['success']) {
                      if (result['type'] == 'phone') {
                        // Navigate to OTP page for phone verification
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginOtpPage(
                              identifier: result['phone'],
                              isPhone: true,
                              isResetPassword: true,
                            ),
                          ),
                        );
                      } else {
                        // Email link sent, go back to login
                        Navigator.pop(context);
                      }
                    }
                  }
                },
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
                          'Continue',
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
}
