import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tokn/services/security_service.dart';

class LockScreen extends StatefulWidget {
  final Widget child;
  const LockScreen({super.key, required this.child});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final List<String> _pin = [];
  bool _isError = false;

  void _onDigitPress(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin.add(digit);
        _isError = false;
      });
      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin.removeLast();
        _isError = false;
      });
    }
  }

  Future<void> _verifyPin() async {
    final securityProvider = Provider.of<SecurityProvider>(context, listen: false);
    final success = await securityProvider.verifyPin(_pin.join());
    if (success) {
      // Unlocked
    } else {
      setState(() {
        _pin.clear();
        _isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final securityProvider = Provider.of<SecurityProvider>(context);
    
    if (!securityProvider.isLocked) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),
            // Header
            const Icon(Icons.lock_outline, size: 64, color: Color(0xFF2E4C9D)),
            const SizedBox(height: 24),
            Text(
              'Enter App PIN',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isError ? 'Incorrect PIN, try again' : 'Please enter your 4-digit PIN',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: _isError ? Colors.redAccent : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 48),
            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                bool isFilled = index < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? const Color(0xFF2E4C9D) : Colors.grey[200],
                    border: _isError && !isFilled ? Border.all(color: Colors.redAccent.withOpacity(0.5)) : null,
                  ),
                );
              }),
            ),
            const Spacer(flex: 1),
            // Keypad
            _buildKeypad(),
            const SizedBox(height: 24),
            // Biometric Fallback
            if (securityProvider.biometricEnabled)
              TextButton.icon(
                onPressed: () => securityProvider.authenticateBiometric(),
                icon: const Icon(Icons.fingerprint, color: Color(0xFF2E4C9D)),
                label: Text(
                  'Use Fingerprint',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF2E4C9D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildKey('1'), _buildKey('2'), _buildKey('3')],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildKey('4'), _buildKey('5'), _buildKey('6')],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildKey('7'), _buildKey('8'), _buildKey('9')],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 64, height: 64),
              _buildKey('0'),
              _buildDeleteKey(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String digit) {
    return GestureDetector(
      onTap: () => _onDigitPress(digit),
      child: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFF7F9FC),
        ),
        child: Center(
          child: Text(
            digit,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E4C9D),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey() {
    return GestureDetector(
      onTap: _onDelete,
      child: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.backspace_outlined, color: Color(0xFF2E4C9D), size: 24),
        ),
      ),
    );
  }
}
