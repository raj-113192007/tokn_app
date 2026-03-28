import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tokn/welcome_page.dart';
import 'package:tokn/home_page.dart';
import 'package:tokn/services/supabase_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _textController;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1, milliseconds: 500),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _textController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _textController.forward();
      }
    });

    _initApp();
  }

  Future<void> _initApp() async {
    try {
      // Wait for initial animation
      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
      
      // Request Essential Permissions with a timeout or handled individually
      // Note: If any permission hangs, we still want to move forward
      await [
        Permission.location,
        Permission.phone,
      ].request().timeout(const Duration(seconds: 5), onTimeout: () => {});


      // If already logged in, fetch and update location
      final session = SupabaseService.client.auth.currentSession;
      if (session != null) {
        try {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          await SupabaseService().updateUserLocation(
            position.latitude,
            position.longitude,
          );
        } catch (e) {
          debugPrint("Location fetch error: $e");
        }
      }


    } catch (e) {
      debugPrint("Permission request error: $e");
    } finally {
      // Small delay for UX transition
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        final session = SupabaseService.client.auth.currentSession;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => session != null ? const HomePage() : const WelcomePage(),
          ),
        );
      }

    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/splash_logo.png',
                    width: 150, // Slightly bigger than 120 but not huge
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'TokN',
                  style: GoogleFonts.poppins(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
