import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/activity_controller.dart';
import 'edit_profile_page.dart';
import 'login_page.dart';

// Tela de perfil do usuário com informações e opção de logout
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Consumer2<AuthController, ActivityController>(
        builder: (context, authController, activityController, _) {
          final user = authController.currentUser;
          if (user == null) return const SizedBox.shrink();

          final totalDuration = activityController.totalDuration;
          final hours = totalDuration.inHours;
          final minutes = totalDuration.inMinutes.remainder(60);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Avatar do usuário
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.deepOrange,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                // Estatísticas do perfil
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProfileStat(
                        'Atividades',
                        '${activityController.totalActivities}',
                        Icons.fitness_center,
                      ),
                      Container(
                        height: 50,
                        width: 1,
                        color: Colors.grey[300],
                      ),
                      _buildProfileStat(
                        'Distância',
                        '${activityController.totalDistance.toStringAsFixed(1)} km',
                        Icons.straighten,
                      ),
                      Container(
                        height: 50,
                        width: 1,
                        color: Colors.grey[300],
                      ),
                      _buildProfileStat(
                        'Tempo',
                        '${hours}h ${minutes}m',
                        Icons.timer,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Opções do perfil
                _buildOptionTile(
                  icon: Icons.settings,
                  title: 'Configurações',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Disponível na próxima versão'),
                      ),
                    );
                  },
                ),
                _buildOptionTile(
                  icon: Icons.info_outline,
                  title: 'Sobre o App',
                  onTap: () => _showAboutDialog(context),
                ),
                const SizedBox(height: 16),

                // Botão de logout com confirmação
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Sair da conta',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepOrange),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepOrange),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sobre o Stride'),
        content: const Text(
          'Stride é um aplicativo de registro de atividades físicas '
          'inspirado no Strava.\n\n'
          'Versão 1.0.0\n'
          'Projeto de Dispositivos Móveis',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final dialogNavigator = Navigator.of(ctx);
              final authController = Provider.of<AuthController>(context, listen: false);
              await authController.logout();
              dialogNavigator.pop();
              navigator.pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
