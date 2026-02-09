import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/animation_utils.dart';

class LoginOtpPage extends StatefulWidget {
  final String identifier;
  final bool isPhone;

  const LoginOtpPage({
    super.key,
    required this.identifier,
    required this.isPhone,
  });

  @override
  State<LoginOtpPage> createState() => _LoginOtpPageState();
}

class _LoginOtpPageState extends State<LoginOtpPage> {
  bool _isVerified = false;
  bool _isCodeComplete = false;

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
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
              child: Column(
                children: [
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 100),
                    child: _buildVerificationSection(
                      title: widget.isPhone
                          ? 'Sent to your phone'
                          : 'Sent to your e-mail',
                      value: widget.identifier,
                      onConfirm: () {
                        // Login Logic
                      },
                    ),
                  ),
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
        const SizedBox(height: 20),

        // OTP Input Fields
        LoginOtpInputRow(
          onChanged: (isComplete) {
            setState(() {
              _isCodeComplete = isComplete;
            });
          },
        ),

        const SizedBox(height: 10),
        const LoginOtpTimerControl(),

        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ScaleOnTap(
            onTap: () {
              setState(() {
                _isVerified = true;
              });
              onConfirm();
            },
            child: ElevatedButton(
              onPressed: null, // Managed by ScaleOnTap
              style: ElevatedButton.styleFrom(
                backgroundColor: _isVerified
                    ? Colors.white
                    : (_isCodeComplete ? const Color(0xFF2E4C9D) : Colors.grey),
                side: _isVerified
                    ? const BorderSide(color: Colors.green, width: 2)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _isVerified
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 30,
                    )
                  : Text(
                      'Sign In',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
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

class LoginOtpInputRow extends StatefulWidget {
  final Function(bool) onChanged;
  const LoginOtpInputRow({super.key, required this.onChanged});

  @override
  State<LoginOtpInputRow> createState() => _LoginOtpInputRowState();
}

class _LoginOtpInputRowState extends State<LoginOtpInputRow> {
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
          width: 60,
          height: 60,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: GoogleFonts.poppins(
              fontSize: 22,
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

class LoginOtpTimerControl extends StatefulWidget {
  const LoginOtpTimerControl({super.key});

  @override
  State<LoginOtpTimerControl> createState() => _LoginOtpTimerControlState();
}

class _LoginOtpTimerControlState extends State<LoginOtpTimerControl> {
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
                }
              : null,
          child: Text(
            'Resend Code',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2E4C9D),
            ),
          ),
        ),
      ],
    );
  }
}
