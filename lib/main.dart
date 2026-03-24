import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Added for kIsWeb
import 'package:shake/shake.dart';
import 'package:tokn/splash_screen.dart';
import 'package:home_widget/home_widget.dart';
import 'package:tokn/services/notification_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tokn/services/language_provider.dart';
import 'package:tokn/l10n/app_localizations.dart';
import 'package:tokn/services/security_service.dart';
import 'package:tokn/widgets/lock_screen.dart';
import 'help_support_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb) {
    HomeWidget.setAppGroupId('tokn_app_group');
  }
  
  try {
    if (!kIsWeb) {
      await NotificationService.init();
      await NotificationService.schedulePeriodicNotification();
      NotificationService.showLiveAlert(); 
    }
  } catch (e) {
    debugPrint("Notification initialization error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  ShakeDetector? detector; // Made nullable

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      detector = ShakeDetector.autoStart(
        onPhoneShake: (event) {
          _showShakeConfirmation();
        },
        shakeThresholdGravity: 1.5,
      );
    }
  }

  @override
  void dispose() {
    detector?.stopListening();
    super.dispose();
  }

  void _showShakeConfirmation() {
    final context = navigatorKey.currentState?.overlay?.context;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Need Help?'),
        content: const Text('We detected a shake. Would you like to open the Help & Support centre?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              navigatorKey.currentState?.push(
                MaterialPageRoute(builder: (context) => const HelpSupportPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E4C9D),
              foregroundColor: Colors.white,
            ),
            child: const Text('Open Help'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => SecurityProvider()),
      ],
      child: Consumer2<LanguageProvider, SecurityProvider>(
        builder: (context, languageProvider, securityProvider, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'TokN',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('hi'), // Hindi
            ],
            locale: languageProvider.currentLocale,
            builder: (context, child) => LockScreen(child: child!),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
