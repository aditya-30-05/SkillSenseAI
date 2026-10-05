import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/models/telemetry.dart';
import 'package:trainer_app/models/hazard.dart';

// ── Mission waypoints ────────────────────────────────────────────────────────

class MissionWaypoint {
  final double lat;
  final double lng;
  final String zone;
  final double altitude;
  const MissionWaypoint({
    required this.lat,
    required this.lng,
    required this.zone,
    required this.altitude,
  });
}

// ── Simulation state ─────────────────────────────────────────────────────────

enum SimulationState { idle, running, paused, hazardPhase, completed }

class SimulationData {
  final TelemetryReading telemetry;
  final SimulationState state;
  final int waypointIndex;
  final bool hazardInjected;
  final HazardEvent? activeHazard;
  final List<Map<String, double>> gasHistory;
  final List<Map<String, double>> tempHistory;
  final List<Map<String, double>> humidityHistory;

  const SimulationData({
    required this.telemetry,
    required this.state,
    required this.waypointIndex,
    required this.hazardInjected,
    this.activeHazard,
    required this.gasHistory,
    required this.tempHistory,
    required this.humidityHistory,
  });

  SimulationData copyWith({
    TelemetryReading? telemetry,
    SimulationState? state,
    int? waypointIndex,
    bool? hazardInjected,
    HazardEvent? activeHazard,
    List<Map<String, double>>? gasHistory,
    List<Map<String, double>>? tempHistory,
    List<Map<String, double>>? humidityHistory,
  }) {
    return SimulationData(
      telemetry: telemetry ?? this.telemetry,
      state: state ?? this.state,
      waypointIndex: waypointIndex ?? this.waypointIndex,
      hazardInjected: hazardInjected ?? this.hazardInjected,
      activeHazard: activeHazard ?? this.activeHazard,
      gasHistory: gasHistory ?? this.gasHistory,
      tempHistory: tempHistory ?? this.tempHistory,
      humidityHistory: humidityHistory ?? this.humidityHistory,
    );
  }
}

// ── Simulation notifier ──────────────────────────────────────────────────────

class SimulationNotifier extends StateNotifier<SimulationData> {
  SimulationNotifier()
      : super(SimulationData(
          telemetry: _initialTelemetry(),
          state: SimulationState.idle,
          waypointIndex: 0,
          hazardInjected: false,
          gasHistory: [],
          tempHistory: [],
          humidityHistory: [],
        ));

  Timer? _ticker;
  final Random _rng = Random();
  double _gasPpm = 1.2;
  double _tempC = 30.0;
  double _humidity = 55.0;
  double _altitude = 0.0;
  int _battery = 82;
  int _signal = 91;
  int _flightSec = 0;
  int _waypointIndex = 0;
  bool _hazardActive = false;
  double _hazardGasTarget = 1.2;

  static const _waypoints = [
    MissionWaypoint(lat: 20.5937, lng: 78.9629, zone: 'Base', altitude: 0),
    MissionWaypoint(lat: 20.5940, lng: 78.9631, zone: 'Zone A', altitude: 6),
    MissionWaypoint(lat: 20.5943, lng: 78.9634, zone: 'Zone B', altitude: 8),
    MissionWaypoint(lat: 20.5946, lng: 78.9637, zone: 'Zone C', altitude: 8),
    MissionWaypoint(lat: 20.5942, lng: 78.9641, zone: 'Inspection Area', altitude: 5),
  ];

  void startMission() {
    _waypointIndex = 0;
    _gasPpm = 1.2;
    _tempC = 30.0;
    _humidity = 55.0;
    _altitude = 0.0;
    _battery = 82;
    _signal = 91;
    _flightSec = 0;
    _hazardActive = false;

    state = state.copyWith(
      state: SimulationState.running,
      waypointIndex: 0,
      hazardInjected: false,
      gasHistory: [],
      tempHistory: [],
      humidityHistory: [],
    );

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 1200), _tick);
  }

  void pauseMission() {
    _ticker?.cancel();
    state = state.copyWith(state: SimulationState.paused);
  }

  void resumeMission() {
    if (state.state == SimulationState.paused) {
      state = state.copyWith(state: SimulationState.running);
      _ticker = Timer.periodic(const Duration(milliseconds: 1200), _tick);
    }
  }

  void stopMission() {
    _ticker?.cancel();
    state = state.copyWith(
      state: SimulationState.completed,
      hazardInjected: false,
    );
  }

  void resetMission() {
    _ticker?.cancel();
    _gasPpm = 1.2;
    _hazardActive = false;
    state = SimulationData(
      telemetry: _initialTelemetry(),
      state: SimulationState.idle,
      waypointIndex: 0,
      hazardInjected: false,
      gasHistory: [],
      tempHistory: [],
      humidityHistory: [],
    );
  }

  void injectHazard() {
    _hazardActive = true;
    _hazardGasTarget = 8.5 + _rng.nextDouble() * 2;
    state = state.copyWith(hazardInjected: true, state: SimulationState.hazardPhase);
  }

  void acknowledgeHazard() {
    state = state.copyWith(
      activeHazard: null,
      hazardInjected: false,
    );
    _hazardActive = false;
    _hazardGasTarget = 1.2;
  }

  void _tick(Timer t) {
    _flightSec++;
    if (_battery > 0 && _flightSec % 30 == 0) _battery--;
    _signal = 85 + _rng.nextInt(10);

    // Move waypoints
    if (_flightSec % 10 == 0 && _waypointIndex < _waypoints.length - 1) {
      _waypointIndex++;
    }

    final wp = _waypoints[_waypointIndex];

    // Drift GPS slightly
    final latDrift = ((_rng.nextDouble() - 0.5) * 0.0001);
    final lngDrift = ((_rng.nextDouble() - 0.5) * 0.0001);

    // Altitude lerp
    final targetAlt = wp.altitude;
    _altitude = _lerp(_altitude, targetAlt, 0.1);

    // Gas simulation
    if (_hazardActive) {
      // Gradual rise toward target
      _gasPpm = _lerp(_gasPpm, _hazardGasTarget, 0.08);
    } else {
      // Normal fluctuation
      _gasPpm = _lerp(_gasPpm, 1.2 + _rng.nextDouble() * 0.6, 0.05);
    }
    _gasPpm = max(0.1, _gasPpm);

    // Temp & humidity fluctuation
    _tempC = _lerp(_tempC, 31.0 + _rng.nextDouble() * 2, 0.03);
    _humidity = _lerp(_humidity, 56.0 + _rng.nextDouble() * 4, 0.03);

    // Hazard detection logic
    bool hazardDetected = false;
    String hazardType = 'none';
    double confidence = 0.0;
    String riskLevel = 'safe';

    if (_gasPpm >= 8.0) {
      hazardDetected = true;
      hazardType = 'gas';
      confidence = 0.90 + (_gasPpm - 8.0) * 0.01;
      riskLevel = 'critical';
    } else if (_gasPpm >= 5.0) {
      hazardDetected = true;
      hazardType = 'gas';
      confidence = 0.75 + (_gasPpm - 5.0) * 0.03;
      riskLevel = 'high';
    } else if (_gasPpm >= 3.0) {
      hazardType = 'gas';
      confidence = 0.55 + (_gasPpm - 3.0) * 0.05;
      riskLevel = 'warning';
    }

    final reading = TelemetryReading(
      droneId: 'DRONE-01',
      timestamp: DateTime.now(),
      latitude: wp.lat + latDrift,
      longitude: wp.lng + lngDrift,
      altitudeM: double.parse(_altitude.toStringAsFixed(1)),
      gasPpm: double.parse(_gasPpm.toStringAsFixed(2)),
      temperatureC: double.parse(_tempC.toStringAsFixed(1)),
      humidityPercent: double.parse(_humidity.toStringAsFixed(1)),
      batteryPercent: _battery,
      signalStrength: _signal,
      hazardDetected: hazardDetected,
      hazardType: hazardType,
      confidence: confidence,
      riskLevel: riskLevel,
      airQualityIndex: max(0, 100 - _gasPpm * 5),
    );

    // History (keep last 30 readings)
    final now = DateTime.now().millisecondsSinceEpoch.toDouble();
    final gasH = [...state.gasHistory, {'x': now, 'y': _gasPpm}];
    final tempH = [...state.tempHistory, {'x': now, 'y': _tempC}];
    final humH = [...state.humidityHistory, {'x': now, 'y': _humidity}];

    const maxPts = 30;
    HazardEvent? hazardEvt;
    if (hazardDetected && state.activeHazard == null && _hazardActive) {
      hazardEvt = HazardEvent(
        id: 'H-LIVE-${DateTime.now().millisecondsSinceEpoch}',
        type: HazardType.gas,
        riskLevel: riskLevel == 'critical' ? RiskLevel.critical : RiskLevel.high,
        confidencePercent: confidence * 100,
        sensorValue: _gasPpm,
        sensorUnit: 'ppm',
        latitude: reading.latitude,
        longitude: reading.longitude,
        zone: wp.zone,
        detectedAt: DateTime.now(),
        droneId: 'DRONE-01',
        sessionId: 'LIVE',
      );
    }

    state = state.copyWith(
      telemetry: reading,
      waypointIndex: _waypointIndex,
      gasHistory: gasH.length > maxPts ? gasH.sublist(gasH.length - maxPts) : gasH,
      tempHistory: tempH.length > maxPts ? tempH.sublist(tempH.length - maxPts) : tempH,
      humidityHistory: humH.length > maxPts ? humH.sublist(humH.length - maxPts) : humH,
      activeHazard: hazardEvt ?? state.activeHazard,
    );
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  static TelemetryReading _initialTelemetry() {
    return TelemetryReading(
      droneId: 'DRONE-01',
      timestamp: DateTime.now(),
      latitude: 20.5937,
      longitude: 78.9629,
      altitudeM: 0.0,
      gasPpm: 1.2,
      temperatureC: 30.0,
      humidityPercent: 55.0,
      batteryPercent: 82,
      signalStrength: 91,
      hazardDetected: false,
      hazardType: 'none',
      confidence: 0.0,
      riskLevel: 'safe',
      airQualityIndex: 94.0,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final simulationProvider =
    StateNotifierProvider<SimulationNotifier, SimulationData>(
  (ref) => SimulationNotifier(),
);
