import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/activity_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/tracking_controller.dart';
import '../models/activity_model.dart';
import 'widgets/route_map.dart';

// Formulário de finalização de uma atividade gravada por GPS.
// Distância e duração vêm prontas do tracking (somente leitura);
// o usuário define título, tipo e calorias (opcional).
class SaveTrackedActivityPage extends StatefulWidget {
  final List<RoutePoint> route;
  final double distanceKm;
  final Duration duration;

  const SaveTrackedActivityPage({
    super.key,
    required this.route,
    required this.distanceKm,
    required this.duration,
  });

  @override
  State<SaveTrackedActivityPage> createState() =>
      _SaveTrackedActivityPageState();
}

class _SaveTrackedActivityPageState extends State<SaveTrackedActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _caloriesController = TextEditingController();

  ActivityType _selectedType = ActivityType.running;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  String get _formattedDuration {
    final h = widget.duration.inHours;
    final m = widget.duration.inMinutes.remainder(60);
    final s = widget.duration.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}min';
    return '${m}min ${s}s';
  }

  double get _pace {
    if (widget.distanceKm < 0.01) return 0;
    return widget.duration.inSeconds / 60 / widget.distanceKm;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final authController = Provider.of<AuthController>(context, listen: false);
    final activityController =
        Provider.of<ActivityController>(context, listen: false);

    final success = await activityController.addActivity(
      token: authController.token!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      type: _selectedType,
      distance: double.parse(widget.distanceKm.toStringAsFixed(2)),
      duration: widget.duration,
      date: DateTime.now(),
      averagePace: _pace > 0 ? double.parse(_pace.toStringAsFixed(2)) : null,
      calories: _caloriesController.text.isNotEmpty
          ? double.tryParse(_caloriesController.text.replaceAll(',', '.'))
          : null,
      route: widget.route,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      // Limpa a sessão de tracking e volta para a home.
      context.read<TrackingController>().reset();
      Navigator.of(context).popUntil((r) => r.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atividade registrada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(activityController.errorMessage ?? 'Erro ao salvar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salvar atividade'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pré-visualização do trajeto gravado.
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 200,
                  child: RouteMap(route: widget.route),
                ),
              ),
              const SizedBox(height: 16),

              // Métricas calculadas (somente leitura).
              Row(
                children: [
                  Expanded(
                    child: _readOnlyMetric(
                      'Distância',
                      '${widget.distanceKm.toStringAsFixed(2)} km',
                      Icons.straighten,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _readOnlyMetric(
                      'Duração',
                      _formattedDuration,
                      Icons.timer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<ActivityType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de atividade',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: ActivityType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text('${type.icon} ${type.displayName}'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedType = value);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título da atividade',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Corrida matinal no parque',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o título da atividade';
                  }
                  if (value.trim().length < 3) {
                    return 'O título deve ter pelo menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                  hintText: 'Detalhes sobre a atividade...',
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _caloriesController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Calorias (opcional)',
                  prefixIcon: Icon(Icons.local_fire_department),
                  border: OutlineInputBorder(),
                  hintText: 'Ex: 350',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final cal = double.tryParse(value.replaceAll(',', '.'));
                    if (cal == null || cal < 0) return 'Valor inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _saving ? null : _handleSave,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: const Text('Salvar Atividade',
                    style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _readOnlyMetric(String label, String value, IconData icon) {
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
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
