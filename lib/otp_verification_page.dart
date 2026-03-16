import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tokn/home_page.dart';
import 'widgets/animation_utils.dart';
import 'services/api_service.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final String phoneNumber;

  const OtpVerificationPage({
    super.key,
    required this.email,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  bool _isPhoneVerified = false;
  bool _isEmailVerified = false;
  bool _isPhoneCodeComplete = false;
  bool _isEmailCodeComplete = false;

  bool _isLoading = false;

  Future<void> _verifyCode(String value, bool isPhone, String code, Function(bool) onVerified) async {
    setState(() => _isLoading = true);
    
    final result = await ApiService.verifyOtp(
      email: isPhone ? null : value,
      phone: isPhone ? value : null,
      otp: code,
    );

    if (mounted) {
      if (result['success'] == true) {
        setState(() {
          _isLoading = false;
          onVerified(true);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${isPhone ? "Phone" : "Email"} verified!'), backgroundColor: Colors.green),
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Verification failed'), backgroundColor: Colors.red),
        );
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
                height: size.height * 0.12,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E4C9D), // Blue background
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 45,
                      left: 0,
                      right: 0,
                      child: Text(
                        'Verification',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 35,
                      left: 10,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: Column(
                    children: [
                      // Phone Verification Section
                      FadeSlideTransition(
                        delay: const Duration(milliseconds: 100),
                        child: _buildVerificationSection(
                          title: 'Sent to your phone',
                          value: widget.phoneNumber,
                          isVerified: _isPhoneVerified,
                          isCodeComplete: _isPhoneCodeComplete,
                          onCodeChanged: (isComplete, code) {
                            setState(() {
                              _isPhoneCodeComplete = isComplete;
                              if (isComplete) {
                                // Optionally auto-verify
                                _verifyCode(widget.phoneNumber, true, code, (v) => _isPhoneVerified = v);
                              }
                            });
                          },
                          onConfirm: (code) {
                            _verifyCode(widget.phoneNumber, true, code, (v) => _isPhoneVerified = v);
                          },
                        ),
                      ),

                      const Divider(height: 25, thickness: 1, color: Colors.grey),

                      // Email Verification Section
                      FadeSlideTransition(
                        delay: const Duration(milliseconds: 300),
                        child: _buildVerificationSection(
                          title: 'Sent to your e-mail',
                          value: widget.email,
                          isVerified: _isEmailVerified,
                          isCodeComplete: _isEmailCodeComplete,
                          onCodeChanged: (isComplete, code) {
                            setState(() {
                              _isEmailCodeComplete = isComplete;
                              if (isComplete) {
                                _verifyCode(widget.email, false, code, (v) => _isEmailVerified = v);
                              }
                            });
                          },
                          onConfirm: (code) {
                            _verifyCode(widget.email, false, code, (v) => _isEmailVerified = v);
                          },
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Final Sign Up Button
                      FadeSlideTransition(
                        delay: const Duration(milliseconds: 500),
                        child: SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ScaleOnTap(
                            onTap: (_isPhoneVerified && _isEmailVerified)
                                ? () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const HomePage(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                : null,
                            child: Container(
                              width: double.infinity,
                              height: 55,
                              decoration: BoxDecoration(
                                color: (_isPhoneVerified && _isEmailVerified)
                                    ? const Color(0xFF2E4C9D)
                                    : Colors.white,
                                border: Border.all(
                                  color: const Color(0xFF2E4C9D),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  'GO TO HOME',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: (_isPhoneVerified && _isEmailVerified)
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  String _currentPhoneCode = "";
  String _currentEmailCode = "";

  Widget _buildVerificationSection({
    required String title,
    required String value,
    required bool isVerified,
    required bool isCodeComplete,
    required Function(bool, String) onCodeChanged,
    required Function(String) onConfirm,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            'Change?',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF2E4C9D),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // OTP Input Fields
        OtpInputRow(onChanged: (complete, code) {
           if (title.contains('phone')) _currentPhoneCode = code;
           else _currentEmailCode = code;
           onCodeChanged(complete, code);
        }),

        const SizedBox(height: 5),
        OtpTimerControl(onResend: () async {
          setState(() => _isLoading = true);
          final res = await ApiService.sendOtp(
            email: title.contains('phone') ? null : value,
            phone: title.contains('phone') ? value : null,
          );
          if (mounted) {
            setState(() => _isLoading = false);
            if (res['success'] == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('OTP Resent!'), backgroundColor: Colors.green),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(res['error'] ?? 'Resend failed'), backgroundColor: Colors.red),
              );
            }
          }
        }),

        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 45,
          child: ScaleOnTap(
            onTap: isVerified ? null : () => onConfirm(title.contains('phone') ? _currentPhoneCode : _currentEmailCode),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isVerified
                    ? Colors.white
                    : (isCodeComplete ? const Color(0xFF2E4C9D) : Colors.grey),
                border: isVerified
                    ? Border.all(color: Colors.green, width: 2)
                    : null,
                borderRadius: BorderRadius.circular(30),
              ),
              child: isVerified
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    )
                  : Text(
                      'Confirm',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class OtpInputRow extends StatefulWidget {
  final Function(bool, String) onChanged;
  const OtpInputRow({super.key, required this.onChanged});

  @override
  State<OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<OtpInputRow> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        return SizedBox(
          width: 50,
          height: 50,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF2E4C9D),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF23B5D3),
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 3) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }

              String code = _controllers.map((c) => c.text).join();
              bool isComplete = code.isNotEmpty;
              widget.onChanged(isComplete, code);
            },
          ),
        );
      }),
    );
  }
}

class OtpTimerControl extends StatefulWidget {
  final VoidCallback onResend;
  const OtpTimerControl({super.key, required this.onResend});

  @override
  State<OtpTimerControl> createState() => _OtpTimerControlState();
}

class _OtpTimerControlState extends State<OtpTimerControl> {
  int _secondsRemaining = 94;
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
        SizedBox(
          height: 30,
          child: TextButton(
            onPressed: _secondsRemaining == 0
                ? () {
                    setState(() {
                      _secondsRemaining = 94;
                      _startTimer();
                    });
                    widget.onResend();
                  }
                : null,
            child: Text(
              'Resend Code',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E4C9D),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
