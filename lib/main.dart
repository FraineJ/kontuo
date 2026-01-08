import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'data/services/storage_service.dart';
import 'data/models/user_profile.dart';
import 'presentation/screens/onboarding/welcome_screen.dart';
import 'presentation/screens/onboarding/user_profile_screen.dart';
import 'presentation/screens/onboarding/configuration_screen.dart';
import 'presentation/screens/onboarding/permissions_screen.dart';
import 'presentation/screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Google Mobile Ads
  await MobileAds.instance.initialize();
  // Initialize date formatting for Spanish locale
  await initializeDateFormatting('es', null);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.darkBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const KontuoApp());
}

class KontuoApp extends StatelessWidget {
  const KontuoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kontuo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/onboarding/profile': (context) => const UserProfileScreen(),
        '/onboarding/configuration': (context) => const ConfigurationScreen(),
        '/onboarding/permissions': (context) => const PermissionsScreen(),
        '/home': (context) => const MainNavigation(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    final storageService = StorageService();
    final profile = await storageService.getUserProfile();
    
    if (!mounted) return;
    
    if (profile != null && profile.onboardingCompleted) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.positiveGreen,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Text(
              'K',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w300,
                color: AppTheme.primaryBlack,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
