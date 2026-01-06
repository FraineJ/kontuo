import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/services/storage_service.dart';
import '../onboarding/user_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StorageService _storageService = StorageService();
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _storageService.getUserProfile();
    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        title: const Text('Perfil'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.positiveGreen))
          : RefreshIndicator(
              color: AppTheme.positiveGreen,
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_profile != null) ...[
                      _buildProfileCard(_profile!),
                      const SizedBox(height: 24),
                    ],
                    _buildSectionTitle('Configuración'),
                    _buildSettingsItem(
                      icon: Icons.person,
                      title: 'Editar Perfil',
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const UserProfileScreen()),
                        );
                        _loadProfile();
                      },
                    ),
                    _buildSettingsItem(
                      icon: Icons.palette,
                      title: 'Tema',
                      subtitle: 'Oscuro',
                      onTap: () {
                        // TODO: Implement theme switching
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Datos'),
                    _buildSettingsItem(
                      icon: Icons.file_download,
                      title: 'Exportar Datos',
                      subtitle: 'CSV / PDF',
                      onTap: () {
                        // TODO: Implement export
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Exportación de datos próximamente'),
                            backgroundColor: AppTheme.surfaceColor,
                          ),
                        );
                      },
                    ),
                    _buildSettingsItem(
                      icon: Icons.backup,
                      title: 'Respaldo',
                      subtitle: 'Crear respaldo local',
                      onTap: () {
                        // TODO: Implement backup
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Respaldos próximamente'),
                            backgroundColor: AppTheme.surfaceColor,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Soporte'),
                    _buildSettingsItem(
                      icon: Icons.help_outline,
                      title: 'Ayuda',
                      onTap: () {
                        // TODO: Implement help
                      },
                    ),
                    _buildSettingsItem(
                      icon: Icons.info_outline,
                      title: 'Acerca de',
                      subtitle: 'Versión 1.0.0',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Kontuo',
                          applicationVersion: '1.0.0',
                          applicationIcon: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppTheme.positiveGreen,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                'K',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.primaryBlack,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    _buildDangerZone(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileCard(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.positiveGreen,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Center(
                  child: Text(
                    profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryBlack,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.currency,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Objetivo',
                  AppConstants.financialGoalLabels[profile.financialGoal] ?? profile.financialGoal,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Nivel',
                  AppConstants.knowledgeLevelLabels[profile.knowledgeLevel] ?? profile.knowledgeLevel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.textTertiary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.textPrimary),
        title: Text(
          title,
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(color: AppTheme.textSecondary),
              )
            : null,
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textTertiary),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.negativeRed.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zona de Peligro',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.negativeRed,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppTheme.cardBackground,
                    title: const Text('Eliminar Todos los Datos'),
                    content: const Text(
                      'Esta acción no se puede deshacer. Se eliminarán todos tus datos: transacciones, metas, deudas y configuración.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(foregroundColor: AppTheme.negativeRed),
                        child: const Text('Eliminar Todo'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await _storageService.clearAll();
                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.negativeRed,
                side: const BorderSide(color: AppTheme.negativeRed),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Eliminar Todos los Datos'),
            ),
          ),
        ],
      ),
    );
  }
}


