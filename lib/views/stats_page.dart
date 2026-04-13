import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/activity_controller.dart';
import '../models/activity_model.dart';

// Tela de estatísticas com resumo geral e por tipo de atividade
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<ActivityController>(
        builder: (context, controller, _) {
          if (controller.activities.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Sem dados para exibir.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final totalDuration = controller.totalDuration;
          final hours = totalDuration.inHours;
          final minutes = totalDuration.inMinutes.remainder(60);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card de resumo geral
                const Text(
                  'Resumo Geral.',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total de\nAtividades',
                        '${controller.totalActivities}',
                        Icons.fitness_center,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Distância\nTotal',
                        '${controller.totalDistance.toStringAsFixed(1)} km',
                        Icons.straighten,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Tempo\nTotal',
                        '${hours}h ${minutes}min',
                        Icons.timer,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Esta\nSemana',
                        '${controller.weekActivities.length} ativ.',
                        Icons.calendar_today,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Estatísticas por tipo de atividade
                const Text(
                  'Por Tipo de Atividade.',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...ActivityType.values.map((type) {
                  final typeActivities =
                      controller.getActivitiesByType(type);
                  if (typeActivities.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final typeDistance = typeActivities.fold<double>(
                    0.0,
                    (sum, a) => sum + a.distance,
                  );
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Text(type.icon,
                          style: const TextStyle(fontSize: 28)),
                      title: Text(
                        type.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${typeActivities.length} atividades - ${typeDistance.toStringAsFixed(1)} km',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(75)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
