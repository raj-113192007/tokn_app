import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tokn/home_page.dart';
import 'widgets/animation_utils.dart';
import 'services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/api_service.dart';
import 'widgets/tokn_snackbar.dart';
import 'package:pinput/pinput.dart';
import 'utils/error_mapper.dart';

class SignupOtpPage extends StatefulWidget {
  final String fullName;
  final String email;
  final String phone;
  final String password;
//this is only for the supabse authentication/.
  const SignupOtpPage({
    super.key,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  State<SignupOtpPage> createState() => _SignupOtpPageState();
}

class _SignupOtpPageState extends State<SignupOtpPage> {
  bool _isVerified = false;
  bool _isCodeComplete = false;
  bool _isLoading = false;
  String _currentOtp = "";

  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);
    print('DEBUG: Verifying OTP $_currentOtp for ${widget.phone}');
    try {
      final result = await ApiService.verifySignupOtp(
        email: widget.email,
        phone: widget.phone,
        fullName: widget.fullName,
        password: widget.password,
        otp: _currentOtp,
      );

      print('DEBUG: Verification Result - Success: ${result['success']}');

      if (mounted) {
        setState(() => _isLoading = false);
        if (result['success'] == true) {
          setState(() => _isVerified = true);
          ToknSnackBar.show(context, message: 'Account Created Successfully!', type: SnackBarType.success);
          
          Future.delayed(const Duration(milliseconds: 1000), () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
          });
        } else {
          ToknSnackBar.show(context, message: result['message'] ?? 'Verification failed');
        }
      }
    } catch (e) {
      print('DEBUG: Verification Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ToknSnackBar.show(context, message: ErrorMapper.mapError(e.toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                height: size.height * 0.15,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFEA953B), // Signup Theme Orange
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 55,
                      left: 0,
                      right: 0,
                      child: Text(
                        'Verify Your Account',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 45,
                      left: 10,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                  child: Column(
                    children: [
                      FadeSlideTransition(
                        delay: const Duration(milliseconds: 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enter verification code sent to',
                              style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              widget.phone,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 30),
                            
                            // OTP Input using Pinput for Autofill support
                            Center(
                              child: Pinput(
                                length: 6,
                                autofillHints: const [AutofillHints.oneTimeCode],
                                androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsRetrieverApi,
                                defaultPinTheme: PinTheme(
                                  width: 45,
                                  height: 55,
                                  textStyle: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFEA953B), width: 1.5),
                                  ),
                                ),
                                focusedPinTheme: PinTheme(
                                  width: 45,
                                  height: 55,
                                  textStyle: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFEA953B), width: 2.5),
                                  ),
                                ),
                                onCompleted: (pin) {
                                  _currentOtp = pin;
                                  _isCodeComplete = true;
                                  _verifyOtp();
                                },
                                onChanged: (pin) {
                                  setState(() {
                                    _currentOtp = pin;
                                    _isCodeComplete = pin.length == 6;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 20),
                            Center(
                              child: SignupOtpTimerControl(
                                  onResend: () async {
                                    setState(() => _isLoading = true);
                                    print('DEBUG: Requesting OTP resend for ${widget.phone}');
                                    try {
                                      // Properly resend OTP using the new resendOTP service
                                      await SupabaseService().resendOTP(
                                        phone: widget.phone,
                                        type: OtpType.signup,
                                      );
                                      if (mounted) {
                                        setState(() => _isLoading = false);
                                        ToknSnackBar.show(context, message: 'OTP Resent!', type: SnackBarType.success);
                                      }
                                    } catch (e) {
                                      print('DEBUG: Resend Error: $e');
                                      if (mounted) {
                                        setState(() => _isLoading = false);
                                        ToknSnackBar.show(context, message: ErrorMapper.mapError(e.toString()));
                                      }
                                    }
                                  },
                              ),
                            ),

                            const SizedBox(height: 30),
                            
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ScaleOnTap(
                                onTap: (_isCodeComplete && !_isLoading && !_isVerified) ? _verifyOtp : null,
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _isVerified 
                                        ? Colors.green 
                                        : (_isCodeComplete ? const Color(0xFF2E4C9D) : Colors.grey[300]),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: _isVerified 
                                      ? const Icon(Icons.check, color: Colors.white, size: 30)
                                      : (_isLoading 
                                          ? const CircularProgressIndicator(color: Colors.white)
                                          : Text(
                                              'Verify & Create Account',
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: _isCodeComplete ? Colors.white : Colors.grey[600],
                                              ),
                                            )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SignupOtpTimerControl extends StatefulWidget {
  final VoidCallback onResend;
  const SignupOtpTimerControl({super.key, required this.onResend});

  @override
  State<SignupOtpTimerControl> createState() => _SignupOtpTimerControlState();
}

class _SignupOtpTimerControlState extends State<SignupOtpTimerControl> {
  int _secondsRemaining = 90;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _formatTime(_secondsRemaining),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: _secondsRemaining == 0
              ? () {
                  setState(() {
                    _secondsRemaining = 90;
                    _startTimer();
                  });
                  widget.onResend();
                }
              : null,
          child: Text(
            'Resend Code',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFEA953B),
            ),
          ),
        ),
      ],
    );
  }
}

