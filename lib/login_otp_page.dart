import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tokn/home_page.dart';
import 'widgets/animation_utils.dart';
import 'services/supabase_service.dart';
import 'services/api_service.dart';
import 'widgets/tokn_snackbar.dart';




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
  bool _isLoading = false;

  Future<void> _verifyOtp(String otp) async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.verifyOtp(
        phone: widget.isPhone ? widget.identifier : null,
        email: !widget.isPhone ? widget.identifier : null,
        otp: otp,
      );

      
      if (mounted) {
        setState(() => _isLoading = false);
        if (result['success'] == true && result['session'] != null) {
          setState(() => _isVerified = true);
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
          });
        } else {
          ToknSnackBar.show(context, message: result['message'] ?? 'Unknown error');
        }


      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ToknSnackBar.show(context, message: e.toString());

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
                          onConfirm: (otp) {
                            _verifyOtp(otp);
                          },
                        ),
                      ),
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

  String _currentOtp = "";

  Widget _buildVerificationSection({
    required String title,
    required String value,
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
        const SizedBox(height: 20),

        // OTP Input Fields
        LoginOtpInputRow(
          onChanged: (isComplete, otp) {
            setState(() {
              _isCodeComplete = isComplete;
              _currentOtp = otp;
              if (isComplete) {
                _verifyOtp(otp);
              }
            });
          },
        ),

        const SizedBox(height: 10),
        LoginOtpTimerControl(onResend: () async {
          setState(() => _isLoading = true);
          try {
            if (widget.isPhone) {
              await SupabaseService().signInWithOtp(phone: widget.identifier);
            } else {
              await SupabaseService().signInWithOtp(email: widget.identifier);
            }

            if (mounted) {
              setState(() => _isLoading = false);
              ToknSnackBar.show(context, message: 'OTP Resent!', type: SnackBarType.success);

            }
          } catch (e) {
            if (mounted) {
              setState(() => _isLoading = false);
              ToknSnackBar.show(context, message: e.toString());

            }
          }
        }),


        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ScaleOnTap(
            onTap: _isVerified ? null : () => onConfirm(_currentOtp),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _isVerified
                    ? Colors.white
                    : (_isCodeComplete ? const Color(0xFF2E4C9D) : Colors.grey),
                border: _isVerified
                    ? Border.all(color: Colors.green, width: 2)
                    : null,
                borderRadius: BorderRadius.circular(30),
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
  final Function(bool, String) onChanged;
  const LoginOtpInputRow({super.key, required this.onChanged});

  @override
  State<LoginOtpInputRow> createState() => _LoginOtpInputRowState();
}

class _LoginOtpInputRowState extends State<LoginOtpInputRow> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());


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
      children: List.generate(6, (index) {
        return SizedBox(
          width: 45,
          height: 55,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: GoogleFonts.poppins(
              fontSize: 20,
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
              if (value.isNotEmpty && index < 5) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }

              String code = _controllers.map((c) => c.text).join();
              bool isComplete = code.length == 6;
              widget.onChanged(isComplete, code);
            },
          ),
        );
      }),
    );

  }
}

class LoginOtpTimerControl extends StatefulWidget {
  final VoidCallback onResend;
  const LoginOtpTimerControl({super.key, required this.onResend});

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
                  widget.onResend();
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
