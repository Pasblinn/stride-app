import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/activity_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/activity_model.dart';

// Tela de formulário para adicionar uma nova atividade
class AddActivityPage extends StatefulWidget {
  const AddActivityPage({super.key});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _distanceController = TextEditingController();
  final _hoursController = TextEditingController(text: '0');
  final _minutesController = TextEditingController();
  final _secondsController = TextEditingController(text: '0');
  final _caloriesController = TextEditingController();

  ActivityType _selectedType = ActivityType.running;
  DateTime _selectedDate = DateTime.now();

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

  // Abre o DatePicker para selecionar a data da atividade
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

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final authController =
          Provider.of<AuthController>(context, listen: false);
      final activityController =
          Provider.of<ActivityController>(context, listen: false);

      final hours = int.tryParse(_hoursController.text) ?? 0;
      final minutes = int.tryParse(_minutesController.text) ?? 0;
      final seconds = int.tryParse(_secondsController.text) ?? 0;

      final success = activityController.addActivity(
        userId: authController.currentUser!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        type: _selectedType,
        distance: double.parse(_distanceController.text.replaceAll(',', '.')),
        duration: Duration(hours: hours, minutes: minutes, seconds: seconds),
        date: _selectedDate,
        calories: _caloriesController.text.isNotEmpty
            ? double.tryParse(_caloriesController.text.replaceAll(',', '.'))
            : null,
      );

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Atividade registrada com sucesso!'),
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
        title: const Text('Nova Atividade'),
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
              // Seletor de tipo de atividade com DropdownButtonFormField
              DropdownButtonFormField<ActivityType>(
                value: _selectedType,
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
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Campo título com validação
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

              // Campo descrição (opcional)
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

              // Seletor de data
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Campo distância com validação numérica
              TextFormField(
                controller: _distanceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Distância (km)',
                  prefixIcon: Icon(Icons.straighten),
                  border: OutlineInputBorder(),
                  hintText: 'Ex: 5.2',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a distância';
                  }
                  final distance =
                      double.tryParse(value.replaceAll(',', '.'));
                  if (distance == null || distance <= 0) {
                    return 'Informe uma distância válida';
                  }
                  if (distance > 500) {
                    return 'Distância máxima: 500 km';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campos de duração (horas, minutos, segundos)
              const Text(
                'Duração',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
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
                        if (value != null && value.isNotEmpty) {
                          final h = int.tryParse(value);
                          if (h == null || h < 0 || h > 23) {
                            return 'Inválido';
                          }
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
                        // Valida que a duração total é maior que zero
                        final h =
                            int.tryParse(_hoursController.text) ?? 0;
                        final s =
                            int.tryParse(_secondsController.text) ?? 0;
                        if (h == 0 && m == 0 && s == 0) {
                          return 'Duração > 0';
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
                        if (value != null && value.isNotEmpty) {
                          final s = int.tryParse(value);
                          if (s == null || s < 0 || s > 59) {
                            return 'Inválido';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Campo calorias (opcional)
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
                    final cal =
                        double.tryParse(value.replaceAll(',', '.'));
                    if (cal == null || cal < 0) {
                      return 'Valor inválido';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botão de salvar
              ElevatedButton.icon(
                onPressed: _handleSubmit,
                icon: const Icon(Icons.save),
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
}
