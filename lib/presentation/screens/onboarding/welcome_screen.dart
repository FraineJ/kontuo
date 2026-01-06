import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo placeholder - using text for now
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.positiveGreen,
                  shape: BoxShape.circle,
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
              const SizedBox(height: 48),
              const Text(
                'Kontuo',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: AppTheme.textPrimary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Controla tus finanzas de manera inteligente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: AppTheme.textSecondary,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/onboarding/profile');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.positiveGreen,
                    foregroundColor: AppTheme.primaryBlack,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Comenzar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}


