import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/activity_controller.dart';
import '../models/activity_model.dart';

// Tela de edição de uma atividade existente
// Reutiliza a mesma estrutura de formulário da tela de adicionar
class EditActivityPage extends StatefulWidget {
  final ActivityModel activity;

  const EditActivityPage({super.key, required this.activity});

  @override
  State<EditActivityPage> createState() => _EditActivityPageState();
}

class _EditActivityPageState extends State<EditActivityPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _distanceController;
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;
  late TextEditingController _secondsController;
  late TextEditingController _caloriesController;
  late ActivityType _selectedType;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    // Preenche os controllers com os dados atuais da atividade
    _titleController = TextEditingController(text: widget.activity.title);
    _descriptionController =
        TextEditingController(text: widget.activity.description ?? '');
    _distanceController =
        TextEditingController(text: widget.activity.distance.toString());
    _hoursController = TextEditingController(
        text: widget.activity.duration.inHours.toString());
    _minutesController = TextEditingController(
        text: widget.activity.duration.inMinutes.remainder(60).toString());
    _secondsController = TextEditingController(
        text: widget.activity.duration.inSeconds.remainder(60).toString());
    _caloriesController = TextEditingController(
        text: widget.activity.calories?.toString() ?? '');
    _selectedType = widget.activity.type;
    _selectedDate = widget.activity.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _distanceController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _handleUpdate() {
    if (_formKey.currentState!.validate()) {
      final controller =
          Provider.of<ActivityController>(context, listen: false);

      final hours = int.tryParse(_hoursController.text) ?? 0;
      final minutes = int.tryParse(_minutesController.text) ?? 0;
      final seconds = int.tryParse(_secondsController.text) ?? 0;

      final updatedActivity = widget.activity.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        type: _selectedType,
        distance:
            double.parse(_distanceController.text.replaceAll(',', '.')),
        duration:
            Duration(hours: hours, minutes: minutes, seconds: seconds),
        date: _selectedDate,
        calories: _caloriesController.text.isNotEmpty
            ? double.tryParse(
                _caloriesController.text.replaceAll(',', '.'))
            : null,
      );

      // Valida que a duração total é maior que zero
      if (hours == 0 && minutes == 0 && seconds == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A duração deve ser maior que zero'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = controller.updateActivity(updatedActivity);

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Atividade atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Atividade'),
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
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o título';
                  }
                  if (value.trim().length < 3) {
                    return 'Mínimo 3 caracteres';
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
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _distanceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Distância (km)',
                  prefixIcon: Icon(Icons.straighten),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a distância';
                  }
                  final d = double.tryParse(value.replaceAll(',', '.'));
                  if (d == null || d <= 0) return 'Distância inválida';
                  if (d > 500) return 'Máximo: 500 km';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Duração',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hoursController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Horas',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Obrigatório';
                        }
                        final h = int.tryParse(value);
                        if (h == null || h < 0 || h > 23) {
                          return 'Inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _minutesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Minutos',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Obrigatório';
                        }
                        final m = int.tryParse(value);
                        if (m == null || m < 0 || m > 59) {
                          return 'Inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _secondsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Segundos',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Obrigatório';
                        }
                        final s = int.tryParse(value);
                        if (s == null || s < 0 || s > 59) {
                          return 'Inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
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
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _handleUpdate,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Alterações',
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
}
