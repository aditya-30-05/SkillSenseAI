import 'package:flutter/foundation.dart';

enum DroneStatus { connected, disconnected, flying, idle, charging, error }
enum DroneMode { idle, manual, autonomous, returning, inspection }

extension DroneModeExtension on DroneMode {
  String get label {
    switch (this) {
      case DroneMode.idle:
        return 'Idle';
      case DroneMode.manual:
        return 'Manual';
      case DroneMode.autonomous:
        return 'Autonomous';
      case DroneMode.returning:
        return 'Returning';
      case DroneMode.inspection:
        return 'Inspection';
    }
  }
}

extension DroneStatusExtension on DroneStatus {
  String get label {
    switch (this) {
      case DroneStatus.connected:
        return 'Connected';
      case DroneStatus.disconnected:
        return 'Disconnected';
      case DroneStatus.flying:
        return 'Flying';
      case DroneStatus.idle:
        return 'Idle';
      case DroneStatus.charging:
        return 'Charging';
      case DroneStatus.error:
        return 'Error';
    }
  }
}

@immutable
class Drone {
  final String id;
  final String name;
  final DroneStatus status;
  final DroneMode mode;
  final int batteryPercent;
  final int signalStrength;
  final bool gpsLocked;
  final double latitude;
  final double longitude;
  final double altitudeM;
  final int flightTimeSec;
  final String currentZone;

  const Drone({
    required this.id,
    required this.name,
    required this.status,
    required this.mode,
    required this.batteryPercent,
    required this.signalStrength,
    required this.gpsLocked,
    required this.latitude,
    required this.longitude,
    required this.altitudeM,
    required this.flightTimeSec,
    required this.currentZone,
  });

  Drone copyWith({
    DroneStatus? status,
    DroneMode? mode,
    int? batteryPercent,
    int? signalStrength,
    bool? gpsLocked,
    double? latitude,
    double? longitude,
    double? altitudeM,
    int? flightTimeSec,
    String? currentZone,
  }) {
    return Drone(
      id: id,
      name: name,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      signalStrength: signalStrength ?? this.signalStrength,
      gpsLocked: gpsLocked ?? this.gpsLocked,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitudeM: altitudeM ?? this.altitudeM,
      flightTimeSec: flightTimeSec ?? this.flightTimeSec,
      currentZone: currentZone ?? this.currentZone,
    );
  }
}
