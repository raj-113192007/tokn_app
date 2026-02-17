import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tokn/home_page.dart';
import 'widgets/animation_utils.dart';

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
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
                      onCodeChanged: (isComplete) {
                        setState(() {
                          _isPhoneCodeComplete = isComplete;
                        });
                      },
                      onConfirm: () {
                        setState(() {
                          _isPhoneVerified = true;
                        });
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
                      onCodeChanged: (isComplete) {
                        setState(() {
                          _isEmailCodeComplete = isComplete;
                        });
                      },
                      onConfirm: () {
                        setState(() {
                          _isEmailVerified = true;
                        });
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
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                            (route) => false,
                          );
                        },
                        child: OutlinedButton(
                          onPressed: null, // ScaleOnTap manages it
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF2E4C9D),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'SIGN UP',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
    );
  }

  Widget _buildVerificationSection({
    required String title,
    required String value,
    required bool isVerified,
    required bool isCodeComplete,
    required Function(bool) onCodeChanged,
    required VoidCallback onConfirm,
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
        OtpInputRow(onChanged: onCodeChanged),

        const SizedBox(height: 5),
        const OtpTimerControl(),

        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 45,
          child: ScaleOnTap(
            onTap: onConfirm,
            child: ElevatedButton(
              onPressed: null, // Managed by ScaleOnTap
              style: ElevatedButton.styleFrom(
                backgroundColor: isVerified
                    ? Colors.white
                    : (isCodeComplete ? const Color(0xFF2E4C9D) : Colors.grey),
                side: isVerified
                    ? const BorderSide(color: Colors.green, width: 2)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
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
  final Function(bool) onChanged;
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

              bool isComplete = _controllers.every((c) => c.text.isNotEmpty);
              widget.onChanged(isComplete);
            },
          ),
        );
      }),
    );
  }
}

class OtpTimerControl extends StatefulWidget {
  const OtpTimerControl({super.key});

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
