import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/activity_model.dart';
import '../services/location_service.dart';

enum TrackingStatus { idle, tracking, paused }

// Controla uma sessão de gravação de atividade por GPS.
// Acumula os pontos do trajeto, calcula distância e duração ao vivo,
// e expõe o estado para a UI via ChangeNotifier.
class TrackingController extends ChangeNotifier {
  final LocationService _locationService;

  TrackingController({LocationService? locationService})
      : _locationService = locationService ?? LocationService();

  TrackingStatus _status = TrackingStatus.idle;
  final List<LatLng> _points = [];
  Duration _elapsed = Duration.zero;
  double _distanceKm = 0;
  // No desktop/web a localização é fixa, então a simulação vem ligada por padrão.
  bool _simulate = kIsWeb;
  String? _errorMessage;

  Timer? _timer;
  StreamSubscription<LatLng>? _subscription;

  TrackingStatus get status => _status;
  List<LatLng> get points => List.unmodifiable(_points);
  LatLng? get lastPoint => _points.isNotEmpty ? _points.last : null;
  Duration get elapsed => _elapsed;
  double get distanceKm => _distanceKm;
  bool get simulate => _simulate;
  String? get errorMessage => _errorMessage;
  bool get isActive => _status != TrackingStatus.idle;

  // Pace médio em min/km (0 quando ainda não há distância suficiente).
  double get paceMinPerKm {
    if (_distanceKm < 0.01) return 0;
    return _elapsed.inSeconds / 60 / _distanceKm;
  }

  // Pontos convertidos para o formato persistido na atividade.
  List<RoutePoint> get routePoints =>
      _points.map((p) => RoutePoint(lat: p.latitude, lng: p.longitude)).toList();

  void setSimulate(bool value) {
    if (_status != TrackingStatus.idle) return;
    _simulate = value;
    notifyListeners();
  }

  // Inicia a gravação: garante permissão (no modo real), zera os dados e
  // passa a escutar o stream de posições.
  Future<bool> start() async {
    _errorMessage = null;

    if (!_simulate) {
      final ok = await _locationService.ensurePermission();
      if (!ok) {
        _errorMessage =
            'Permissão de localização negada ou GPS desligado. Ative o "Simular percurso" para testar no navegador.';
        notifyListeners();
        return false;
      }
    }

    _points.clear();
    _elapsed = Duration.zero;
    _distanceKm = 0;
    _status = TrackingStatus.tracking;
    notifyListeners();

    _startTimer();
    _subscribe();
    return true;
  }

  void pause() {
    if (_status != TrackingStatus.tracking) return;
    _status = TrackingStatus.paused;
    _timer?.cancel();
    _subscription?.pause();
    notifyListeners();
  }

  void resume() {
    if (_status != TrackingStatus.paused) return;
    _status = TrackingStatus.tracking;
    _startTimer();
    _subscription?.resume();
    notifyListeners();
  }

  // Encerra a gravação e devolve uma "foto" do resultado. Mantém os dados
  // disponíveis para a tela de salvar; chame reset() depois de salvar/descartar.
  void stop() {
    _status = TrackingStatus.idle;
    _timer?.cancel();
    _subscription?.cancel();
    _subscription = null;
    notifyListeners();
  }

  // Limpa todos os dados para uma nova sessão.
  void reset() {
    _points.clear();
    _elapsed = Duration.zero;
    _distanceKm = 0;
    _status = TrackingStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void _subscribe() {
    final stream =
        _simulate ? _locationService.simulatedStream() : _locationService.positionStream();
    _subscription = stream.listen(_onPoint);
  }

  void _onPoint(LatLng point) {
    if (_points.isNotEmpty) {
      final last = _points.last;
      final meters = Geolocator.distanceBetween(
        last.latitude,
        last.longitude,
        point.latitude,
        point.longitude,
      );
      _distanceKm += meters / 1000;
    }
    _points.add(point);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
