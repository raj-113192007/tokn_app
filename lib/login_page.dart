import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_otp_page.dart';
import 'forgot_password_page.dart';
import 'widgets/animation_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoginEnabled = false;

  // Error messages
  String? _identifierError;

  @override
  void initState() {
    super.initState();
    _identifierController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final input = _identifierController.text.trim();
    final password = _passwordController.text;

    // Detect if Phone (10 digits only) or Email (has @ and .)
    bool isPhone = RegExp(r'^\d{10}$').hasMatch(input);
    bool isEmail = input.contains('@') && input.contains('.');

    setState(() {
      if (input.isEmpty) {
        _identifierError = null;
      } else if (!isPhone && !isEmail) {
        _identifierError = 'Enter 10-digit number or valid email';
      } else {
        _identifierError = null;
      }

      // Enable if either is valid AND password is not empty
      _isLoginEnabled = (isPhone || isEmail) && password.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomPaint(
            size: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
            painter: LoginBackgroundPainter(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 10),
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      'Sign In\nTo \nTokN',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: FadeSlideTransition(
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Hero(
                          tag: 'app_logo',
                          child: Image.asset(
                            'assets/splash_logo.png',
                            width: 80,
                            height: 80,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 150),
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 300),
                    beginOffset: const Offset(50.0, 0), // Glide from right
                    child: _buildTextField(
                      controller: _identifierController,
                      hintText: 'Email or Mobile Number',
                      icon: Icons.person_outline,
                      errorText: _identifierError,
                    ),
                  ),
                  const SizedBox(height: 25),
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 400),
                    beginOffset: const Offset(50.0, 0), // Glide from right
                    child: _buildTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 500),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ScaleOnTap(
                            onTap: _isLoginEnabled
                                ? () {
                                    final input = _identifierController.text
                                        .trim();
                                    bool isPhone = RegExp(
                                      r'^\d{10}$',
                                    ).hasMatch(input);

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginOtpPage(
                                          identifier: input,
                                          isPhone: isPhone,
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            child: Container(
                              width: double.infinity,
                              height: 55,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _isLoginEnabled
                                      ? const Color(0xFF2E4C9D)
                                      : Colors.grey,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  'Sign in',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _isLoginEnabled
                                        ? const Color(0xFF1A1A1A)
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        FadeSlideTransition(
                          delay: const Duration(milliseconds: 600),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'By continuing you agree to our ',
                                ),
                                TextSpan(
                                  text: 'Term and Conditions',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2E4C9D),
                                  ),
                                ),
                              ],
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: (value) => _validateForm(),
      obscureText: isPassword && !_isPasswordVisible,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black87),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (errorText != null)
                const Icon(Icons.error, color: Colors.red, size: 24),
              if (isPassword)
                IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
            ],
          ),
        ),
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black87),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
      style: GoogleFonts.poppins(fontSize: 16),
    );
  }
}

class LoginBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFF3B9966) // Green color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.40);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.45,
      0,
      size.height * 0.25,
    );

    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
