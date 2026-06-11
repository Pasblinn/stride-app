import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../controllers/tracking_controller.dart';
import 'save_tracked_activity_page.dart';

// Tela de gravação de atividade por GPS, com o trajeto sendo desenhado
// no mapa em tempo real (estilo Strava).
class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final MapController _mapController = MapController();
  static const LatLng _initialCenter = LatLng(-25.4390, -49.2697); // UTFPR Curitiba

  @override
  void initState() {
    super.initState();
    // Garante uma sessão limpa ao abrir a tela.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrackingController>().reset();
    });
  }

  void _centerOnLastPoint(TrackingController controller) {
    final last = controller.lastPoint;
    if (last != null) {
      _mapController.move(last, _mapController.camera.zoom);
    }
  }

  Future<void> _handleStart(TrackingController controller) async {
    final started = await controller.start();
    if (!started && mounted && controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleStop(TrackingController controller) {
    controller.stop();
    if (controller.points.length < 2) {
      // Trajeto muito curto para virar atividade.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trajeto muito curto para salvar. Grave um pouco mais.'),
          backgroundColor: Colors.orange,
        ),
      );
      controller.reset();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SaveTrackedActivityPage(
          route: controller.routePoints,
          distanceKm: controller.distanceKm,
          duration: controller.elapsed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gravar atividade'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TrackingController>(
        builder: (context, controller, _) {
          // Recentraliza o mapa quando chega um ponto novo durante a gravação.
          if (controller.status == TrackingStatus.tracking) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _centerOnLastPoint(controller);
            });
          }

          final points = controller.points;

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter:
                      points.isNotEmpty ? points.first : _initialCenter,
                  initialZoom: 16,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.stride.app',
                  ),
                  if (points.length >= 2)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: points,
                          strokeWidth: 5,
                          color: Colors.deepOrange,
                        ),
                      ],
                    ),
                  if (points.isNotEmpty)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: points.last,
                          width: 24,
                          height: 24,
                          child: const _CurrentLocationDot(),
                        ),
                      ],
                    ),
                ],
              ),

              // Painel de métricas ao vivo no topo.
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: _StatsPanel(controller: controller),
              ),

              // Controles na parte inferior.
              Positioned(
                bottom: 24,
                left: 12,
                right: 12,
                child: _Controls(
                  controller: controller,
                  onStart: () => _handleStart(controller),
                  onStop: () => _handleStop(controller),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Marcador pulsante simples da posição atual.
class _CurrentLocationDot extends StatelessWidget {
  const _CurrentLocationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

// Painel com tempo, distância e pace.
class _StatsPanel extends StatelessWidget {
  final TrackingController controller;
  const _StatsPanel({required this.controller});

  String _fmtDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  String _fmtPace(double pace) {
    if (pace <= 0) return '--';
    final min = pace.floor();
    final sec = ((pace - min) * 60).round();
    return '$min:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _stat('Tempo', _fmtDuration(controller.elapsed)),
            _stat('Distância', '${controller.distanceKm.toStringAsFixed(2)} km'),
            _stat('Pace', '${_fmtPace(controller.paceMinPerKm)} /km'),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}

// Botões de controle + switch de simulação.
class _Controls extends StatelessWidget {
  final TrackingController controller;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const _Controls({
    required this.controller,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final status = controller.status;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == TrackingStatus.idle)
          Card(
            elevation: 2,
            child: SwitchListTile(
              value: controller.simulate,
              onChanged: controller.setSimulate,
              activeThumbColor: Colors.deepOrange,
              title: const Text('Simular percurso'),
              subtitle: Text(
                kIsWeb
                    ? 'No navegador a posição é fixa; a simulação gera um trajeto de exemplo.'
                    : 'Use para testar sem sair andando.',
                style: const TextStyle(fontSize: 12),
              ),
              secondary: const Icon(Icons.auto_mode, color: Colors.deepOrange),
            ),
          ),
        const SizedBox(height: 12),
        if (status == TrackingStatus.idle)
          _bigButton(
            label: 'Iniciar',
            icon: Icons.play_arrow,
            color: Colors.green,
            onTap: onStart,
          )
        else
          Row(
            children: [
              Expanded(
                child: status == TrackingStatus.tracking
                    ? _bigButton(
                        label: 'Pausar',
                        icon: Icons.pause,
                        color: Colors.orange,
                        onTap: controller.pause,
                      )
                    : _bigButton(
                        label: 'Retomar',
                        icon: Icons.play_arrow,
                        color: Colors.green,
                        onTap: controller.resume,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _bigButton(
                  label: 'Parar',
                  icon: Icons.stop,
                  color: Colors.red,
                  onTap: onStop,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _bigButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
