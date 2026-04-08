import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tokn/splash_screen.dart';

import 'package:home_widget/home_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:provider/provider.dart';
import 'package:tokn/services/language_provider.dart';
import 'package:tokn/l10n/app_localizations.dart';
import 'package:tokn/services/security_service.dart';
import 'package:tokn/widgets/lock_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wmcyhvbwtqcroolbyozl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndtY3lodmJ3dHFjcm9vbGJ5b3psIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ0Mjc2NzQsImV4cCI6MjA5MDAwMzY3NH0.rtWprVrlFC940s889nbpFAfDFgCktd5XLAHkhXp5Xlk',
  );
  
  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  if (!kIsWeb) {
    HomeWidget.setAppGroupId('tokn_app_group');
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


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
              Locale('pa'), // Punjabi
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
