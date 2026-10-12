class TelemetryReading {
  final String droneId;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double altitudeM;
  final double gasPpm;
  final double temperatureC;
  final double humidityPercent;
  final int batteryPercent;
  final int signalStrength;
  final bool hazardDetected;
  final String hazardType;
  final double confidence;
  final String riskLevel;
  final double airQualityIndex;

  const TelemetryReading({
    required this.droneId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.altitudeM,
    required this.gasPpm,
    required this.temperatureC,
    required this.humidityPercent,
    required this.batteryPercent,
    required this.signalStrength,
    required this.hazardDetected,
    required this.hazardType,
    required this.confidence,
    required this.riskLevel,
    required this.airQualityIndex,
  });

  factory TelemetryReading.fromJson(Map<String, dynamic> json) {
    return TelemetryReading(
      droneId: json['droneId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitudeM: (json['altitude'] as num).toDouble(),
      gasPpm: (json['gasPpm'] as num).toDouble(),
      temperatureC: (json['temperature'] as num).toDouble(),
      humidityPercent: (json['humidity'] as num).toDouble(),
      batteryPercent: json['battery'] as int,
      signalStrength: json['signal'] as int,
      hazardDetected: json['hazardDetected'] as bool,
      hazardType: json['hazardType'] as String? ?? 'none',
      confidence: (json['confidence'] as num).toDouble(),
      riskLevel: json['riskLevel'] as String? ?? 'safe',
      airQualityIndex: (json['airQualityIndex'] as num?)?.toDouble() ?? 50.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'droneId': droneId,
        'timestamp': timestamp.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitudeM,
        'gasPpm': gasPpm,
        'temperature': temperatureC,
        'humidity': humidityPercent,
        'battery': batteryPercent,
        'signal': signalStrength,
        'hazardDetected': hazardDetected,
        'hazardType': hazardType,
        'confidence': confidence,
        'riskLevel': riskLevel,
        'airQualityIndex': airQualityIndex,
      };
}
