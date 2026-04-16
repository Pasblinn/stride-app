import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/activity_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/activity_model.dart';
import 'activity_detail_page.dart';

// Tela de feed de atividades - exibe todas as atividades do usuário
class ActivityFeedPage extends StatelessWidget {
  const ActivityFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final userName = authController.currentUser?.name ?? 'Atleta';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stride'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho com saudação ao usuário
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Olá, $userName!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Resumo semanal do usuário
          Consumer<ActivityController>(
            builder: (context, controller, _) {
              final weekActivities = controller.weekActivities;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepOrange, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWeekStat(
                      'Atividades',
                      '${controller.totalActivities}',
                      Icons.fitness_center,
                    ),
                    _buildWeekStat(
                      'Distância',
                      '${controller.totalDistance.toStringAsFixed(1)} km',
                      Icons.straighten,
                    ),
                    _buildWeekStat(
                      'Esta Semana',
                      '${weekActivities.length}',
                      Icons.calendar_today,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Título da seção de atividades recentes
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Atividades Recentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),

          // Lista de atividades usando Consumer para reagir a mudanças
          Expanded(
            child: Consumer<ActivityController>(
              builder: (context, controller, _) {
                if (controller.activities.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_run,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma atividade registrada',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        Text(
                          'Toque em + para adicionar',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.activities.length,
                  itemBuilder: (context, index) {
                    final activity = controller.activities[index];
                    return _ActivityCard(activity: activity);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para exibir estatísticas semanais
  Widget _buildWeekStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

// Card que exibe o resumo de uma atividade na lista
class _ActivityCard extends StatelessWidget {
  final ActivityModel activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navega para a página de detalhes da atividade
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ActivityDetailPage(activity: activity),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tipo e data da atividade
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        activity.type.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        activity.type.displayName,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(activity.date),
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Título da atividade
              Text(
                activity.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Métricas: distância, duração e pace
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetric(
                    'Distância',
                    '${activity.distance.toStringAsFixed(1)} km',
                  ),
                  _buildMetric('Duração', activity.formattedDuration),
                  _buildMetric('Pace', activity.formattedPace),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}
