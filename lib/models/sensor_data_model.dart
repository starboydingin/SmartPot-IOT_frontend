double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _asInt(dynamic value) {
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

class SensorData {
  final String id;
  final String deviceId;
  final double soilPercent;
  final int soilAnalog;
  final double temperature;
  final double humidity;
  final double lux;
  final String pumpStatus;
  final String mode;
  final DateTime recordedAt;

  SensorData({
    required this.id,
    required this.deviceId,
    required this.soilPercent,
    required this.soilAnalog,
    required this.temperature,
    required this.humidity,
    required this.lux,
    required this.pumpStatus,
    required this.mode,
    required this.recordedAt,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    final created = json['created_at'] ?? json['timestamp'] ?? json['recordedAt'];
    return SensorData(
      id: json['id'] as String,
      deviceId: json['device_id'] ?? json['deviceId'] ?? '',
      soilPercent: _asDouble(json['soil_percent'] ?? json['soilPercent'] ?? 0),
      soilAnalog: _asInt(json['soil_analog'] ?? json['soilAnalog'] ?? 0),
      temperature: _asDouble(json['temperature'] ?? 0),
      humidity: _asDouble(json['humidity'] ?? 0),
      lux: _asDouble(json['lux'] ?? json['lightIntensity'] ?? 0),
      pumpStatus: (json['pump_status'] ?? json['pumpStatus'] ?? 'OFF').toString(),
      mode: (json['mode'] ?? 'AUTO').toString(),
      recordedAt: created != null ? DateTime.parse(created) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'soil_percent': soilPercent,
      'soil_analog': soilAnalog,
      'temperature': temperature,
      'humidity': humidity,
      'lux': lux,
      'pump_status': pumpStatus,
      'mode': mode,
      'created_at': recordedAt.toIso8601String(),
    };
  }
}
