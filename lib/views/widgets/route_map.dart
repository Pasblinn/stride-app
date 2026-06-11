import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/activity_model.dart';

// Mapa estático (não interativo) que enquadra e desenha um trajeto gravado,
// com marcadores de início (verde) e fim (vermelho).
// Reutilizado na tela de salvar e na de detalhes da atividade.
class RouteMap extends StatelessWidget {
  final List<RoutePoint> route;

  const RouteMap({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    final points = route.map((p) => LatLng(p.lat, p.lng)).toList();

    if (points.length < 2) {
      return Container(
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: const Text('Sem trajeto'),
      );
    }

    return FlutterMap(
      options: MapOptions(
        initialCameraFit: CameraFit.coordinates(
          coordinates: points,
          padding: const EdgeInsets.all(32),
        ),
        interactionOptions:
            const InteractionOptions(flags: InteractiveFlag.none),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.stride.app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(points: points, strokeWidth: 5, color: Colors.deepOrange),
          ],
        ),
        MarkerLayer(
          markers: [
            _endpoint(points.first, Colors.green),
            _endpoint(points.last, Colors.red),
          ],
        ),
      ],
    );
  }

  Marker _endpoint(LatLng point, Color color) {
    return Marker(
      point: point,
      width: 18,
      height: 18,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}
