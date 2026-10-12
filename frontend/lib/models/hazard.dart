enum HazardType { gas, water, heat, uv, electrical, smoke, other }
enum RiskLevel { safe, warning, high, critical }

extension HazardTypeExtension on HazardType {
  String get label {
    switch (this) {
      case HazardType.gas:
        return 'Gas';
      case HazardType.water:
        return 'Water';
      case HazardType.heat:
        return 'Heat';
      case HazardType.uv:
        return 'UV';
      case HazardType.electrical:
        return 'Electrical';
      case HazardType.smoke:
        return 'Smoke';
      case HazardType.other:
        return 'Other';
    }
  }
}

extension RiskLevelExtension on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.safe:
        return 'SAFE';
      case RiskLevel.warning:
        return 'WARNING';
      case RiskLevel.high:
        return 'HIGH';
      case RiskLevel.critical:
        return 'CRITICAL';
    }
  }
}

class HazardEvent {
  final String id;
  final HazardType type;
  final RiskLevel riskLevel;
  final double confidencePercent;
  final double sensorValue;
  final String sensorUnit;
  final double latitude;
  final double longitude;
  final String zone;
  final DateTime detectedAt;
  final String droneId;
  final String sessionId;
  bool acknowledged;
  bool marked;
  String responseStatus;

  HazardEvent({
    required this.id,
    required this.type,
    required this.riskLevel,
    required this.confidencePercent,
    required this.sensorValue,
    required this.sensorUnit,
    required this.latitude,
    required this.longitude,
    required this.zone,
    required this.detectedAt,
    required this.droneId,
    required this.sessionId,
    this.acknowledged = false,
    this.marked = false,
    this.responseStatus = 'Pending',
  });
}
