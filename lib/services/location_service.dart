import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

// Serviço que abstrai o acesso à localização do dispositivo.
// Fornece um stream real (GPS via geolocator) e um stream simulado,
// usado para demonstrar o tracking no navegador desktop, onde a
// posição não se move.
class LocationService {
  // Garante que o serviço de localização está ativo e que a permissão
  // foi concedida. Retorna false se não for possível usar o GPS.
  Future<bool> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  // Posição atual única (usada como ponto de partida).
  Future<LatLng> currentLatLng() async {
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    return LatLng(pos.latitude, pos.longitude);
  }

  // Stream real de posições do GPS. Emite um novo ponto a cada ~5 metros.
  Stream<LatLng> positionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).map((pos) => LatLng(pos.latitude, pos.longitude));
  }

  // Stream simulado: gera um trajeto sintético a partir de um ponto base,
  // emitindo um novo ponto por segundo. Serve para demonstração no Chrome.
  Stream<LatLng> simulatedStream({LatLng? start}) {
    // Ponto de partida padrão: UTFPR Campus Curitiba (Sede Centro).
    var current = start ?? const LatLng(-25.4390, -49.2697);
    final random = Random();
    // Direção inicial em radianos; varia levemente a cada passo para
    // produzir uma curva orgânica em vez de uma linha reta.
    var heading = random.nextDouble() * 2 * pi;

    return Stream.periodic(const Duration(seconds: 1), (_) {
      heading += (random.nextDouble() - 0.5) * 0.6;
      // ~0.00012 grau ≈ 13 m por passo (ritmo de corrida leve).
      const step = 0.00012;
      current = LatLng(
        current.latitude + step * cos(heading),
        current.longitude + step * sin(heading),
      );
      return current;
    });
  }
}
