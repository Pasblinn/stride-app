import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/activity_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/activity_model.dart';
import 'edit_activity_page.dart';
import 'widgets/route_map.dart';

// Tela de detalhes de uma atividade específica
class ActivityDetailPage extends StatelessWidget {
  // Snapshot recebido na navegação, usado como fallback. A tela observa o
  // ActivityController e sempre exibe a versão mais recente desta atividade,
  // para refletir edições imediatamente após salvar.
  final ActivityModel initialActivity;

  const ActivityDetailPage({super.key, required ActivityModel activity})
      : initialActivity = activity;

  @override
  Widget build(BuildContext context) {
    final activities = context.watch<ActivityController>().activities;
    final activity = activities.firstWhere(
      (a) => a.id == initialActivity.id,
      orElse: () => initialActivity,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(activity.type.displayName),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          // Botão de editar atividade
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditActivityPage(activity: activity),
                ),
              );
            },
          ),
          // Botão de deletar com confirmação via Dialog
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, activity),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com ícone e título
            Row(
              children: [
                Text(activity.type.icon, style: const TextStyle(fontSize: 41)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, dd/MM/yyyy - HH:mm', 'pt_BR')
                            .format(activity.date),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Cards com métricas detalhadas
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Distância',
                    '${activity.distance.toStringAsFixed(2)} km',
                    Icons.straighten,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Duração',
                    activity.formattedDuration,
                    Icons.timer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Pace Médio',
                    activity.formattedPace,
                    Icons.speed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Calorias',
                    activity.calories != null
                        ? '${activity.calories!.toStringAsFixed(0)} kcal'
                        : '--',
                    Icons.local_fire_department,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Trajeto percorrido no mapa (se a atividade tiver rota gravada)
            if (activity.hasRoute) ...[
              const Text(
                'Trajeto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 250,
                  child: RouteMap(route: activity.route!),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Descrição da atividade (se houver)
            if (activity.description != null &&
                activity.description!.isNotEmpty) ...[
              const Text(
                'Descrição',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  activity.description!,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Card que exibe uma métrica com ícone
  Widget _buildMetricCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.deepOrange, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  // Exibe um diálogo de confirmação antes de deletar
  void _confirmDelete(BuildContext context, ActivityModel activity) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir atividade'),
        content: const Text('Tem certeza que deseja excluir esta atividade?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final authController =
                  Provider.of<AuthController>(context, listen: false);
              final success = await Provider.of<ActivityController>(context, listen: false)
                  .deleteActivity(
                token: authController.token!,
                activityId: activity.id,
              );
              if (!context.mounted) return;
              Navigator.pop(ctx);
              Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Atividade excluída com sucesso'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
