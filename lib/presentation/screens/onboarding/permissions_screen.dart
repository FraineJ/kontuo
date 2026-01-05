import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/services/storage_service.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  Future<void> _completeOnboarding(BuildContext context, Map<String, dynamic> args) async {
    final storageService = StorageService();
    
    final profile = UserProfile(
      name: args['name'] as String,
      currency: args['currency'] as String,
      financialGoal: args['financialGoal'] as String,
      knowledgeLevel: args['knowledgeLevel'] as String,
      monthlyBudget: args['monthlyBudget'] as double,
      incomeFrequency: args['incomeFrequency'] as String,
      onboardingCompleted: true,
    );

    await storageService.saveUserProfile(profile);
    
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Uso Offline',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: AppTheme.textPrimary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(
                      icon: Icons.phone_android,
                      title: 'Almacenamiento Local',
                      description: 'Todos tus datos se guardan localmente en tu dispositivo. No necesitas conexión a internet para usar Kontuo.',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.lock,
                      title: 'Privacidad Total',
                      description: 'Tus datos financieros nunca salen de tu dispositivo. Tienes control total sobre tu información.',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.sync,
                      title: 'Funciona Sin Internet',
                      description: 'Puedes registrar gastos, ingresos y gestionar tus finanzas completamente offline.',
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (args != null) {
                      _completeOnboarding(context, args);
                    }
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
                    'Comenzar con Kontuo',
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.positiveGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

