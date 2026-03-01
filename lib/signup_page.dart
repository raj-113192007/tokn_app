import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'otp_verification_page.dart';
import 'widgets/animation_utils.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isFormValid = false;

  // Error messages for validation
  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    // Also keeping listeners as backup
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Email check: must have @ and .
    final isEmailValid = email.contains('@') && email.contains('.');

    // Phone: exactly 10 digits
    final isPhoneValid = phone.length == 10;

    // Password: min 8 chars and at least one symbol
    final hasSymbol = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final isPasswordValid = password.length >= 8 && hasSymbol;

    // Password match
    final passwordsMatch = password == confirmPassword && password.isNotEmpty;

    if (mounted) {
      setState(() {
        _nameError = (name.isEmpty && _nameController.text.isNotEmpty)
            ? 'Name is required'
            : null;

        _emailError = (!isEmailValid && email.isNotEmpty)
            ? 'Invalid email (use @ and .)'
            : null;

        _phoneError = (!isPhoneValid && phone.isNotEmpty)
            ? 'Enter 10 digits'
            : null;

        _passwordError = (!isPasswordValid && password.isNotEmpty)
            ? 'Min 8 chars & 1 symbol'
            : null;

        _confirmPasswordError = (!passwordsMatch && confirmPassword.isNotEmpty)
            ? 'Passwords do not match'
            : null;

        _isFormValid =
            name.isNotEmpty &&
            isEmailValid &&
            isPhoneValid &&
            isPasswordValid &&
            passwordsMatch;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEA953B), // Theme Orange
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SizedBox(
              height: size.height,
              child: Stack(
                children: [
                  Positioned(
                    top: size.height * 0.05,
                    left: 0,
                    right: 0,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
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
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Hero(
                                  tag: 'app_logo',
                                  child: Image.asset(
                                    'assets/splash_logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              FadeSlideTransition(
                                delay: const Duration(milliseconds: 100),
                                child: Text(
                                  'CREATE YOUR\nACCOUNT',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: size.height * 0.35,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ClipPath(
                      clipper: TopCurveClipper(),
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 60),
                            FadeSlideTransition(
                              delay: const Duration(milliseconds: 200),
                              beginOffset: const Offset(0.1, 0),
                              child: _buildTextField(
                                controller: _nameController,
                                hintText: 'Full Name',
                                icon: Icons.person_outline,
                                errorText: _nameError,
                              ),
                            ),
                            const SizedBox(height: 20),
                            FadeSlideTransition(
                              delay: const Duration(milliseconds: 300),
                              beginOffset: const Offset(0.1, 0),
                              child: _buildTextField(
                                controller: _emailController,
                                hintText: 'Email Address',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                errorText: _emailError,
                              ),
                            ),
                            const SizedBox(height: 20),
                            FadeSlideTransition(
                              delay: const Duration(milliseconds: 400),
                              beginOffset: const Offset(0.1, 0),
                              child: _buildTextField(
                                controller: _phoneController,
                                hintText: 'Phone Number',
                                icon: Icons.phone_android_outlined,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                errorText: _phoneError,
                              ),
                            ),
                            const SizedBox(height: 20),
                            FadeSlideTransition(
                              delay: const Duration(milliseconds: 500),
                              beginOffset: const Offset(0.1, 0),
                              child: _buildTextField(
                                controller: _passwordController,
                                hintText: 'Password',
                                icon: Icons.lock_outline,
                                isPassword: true,
                                obscureText: _obscurePassword,
                                onTogglePassword: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                errorText: _passwordError,
                              ),
                            ),
                            const SizedBox(height: 20),
                            FadeSlideTransition(
                              delay: const Duration(milliseconds: 600),
                              beginOffset: const Offset(0.1, 0),
                              child: _buildTextField(
                                controller: _confirmPasswordController,
                                hintText: 'Confirm Password',
                                icon: Icons.lock_outline,
                                isPassword: true,
                                obscureText: _obscureConfirmPassword,
                                onTogglePassword: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                                errorText: _confirmPasswordError,
                              ),
                            ),

                            const Spacer(),

                            Center(
                              child: FadeSlideTransition(
                                delay: const Duration(milliseconds: 700),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: 55,
                                      child: ScaleOnTap(
                                        onTap: _isFormValid
                                            ? () async {
                                                final prefs = await SharedPreferences.getInstance();
                                                await prefs.setString('user_name', _nameController.text.trim());
                                                
                                                if (mounted) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          OtpVerificationPage(
                                                            email:
                                                                _emailController
                                                                    .text,
                                                            phoneNumber:
                                                                _phoneController
                                                                    .text,
                                                          ),
                                                    ),
                                                  );
                                                }
                                              }
                                            : null,
                                        child: Container(
                                          width: double.infinity,
                                          height: 55,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: _isFormValid
                                                  ? const Color(0xFF2E4C9D)
                                                  : Colors.grey,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Verify Otp',
                                              style: GoogleFonts.poppins(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: _isFormValid
                                                    ? const Color(0xFF000000)
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    FadeSlideTransition(
                                      delay: const Duration(milliseconds: 800),
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                          children: [
                                            const TextSpan(
                                              text:
                                                  'By continuing you agree to our ',
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
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
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
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: (value) => _validateForm(),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
        prefixIcon: Icon(icon, color: Colors.black87),
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
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: onTogglePassword,
                ),
            ],
          ),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF3B9966), width: 2),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
      style: GoogleFonts.poppins(color: Colors.black87),
    );
  }
}

class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, 80);
    path.quadraticBezierTo(size.width * 0.4, 0, size.width, 60);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
