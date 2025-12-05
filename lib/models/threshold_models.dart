double _asDouble(dynamic value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

class DeviceSummary {
  final String id;
  final String deviceName;
  final String potName;

  const DeviceSummary({
    required this.id,
    required this.deviceName,
    required this.potName,
  });

  factory DeviceSummary.fromJson(Map<String, dynamic> json) {
    return DeviceSummary(
      id: (json['id'] ?? '').toString(),
      deviceName: (json['device_name'] ?? json['deviceName'] ?? '').toString(),
      potName: (json['pot_name'] ?? json['potName'] ?? '').toString(),
    );
  }
}

class SoilThresholds {
  final double soilDry;
  final double soilWet;
  final double wateringDelay;
  final double maxPumpDuration;

  const SoilThresholds({
    required this.soilDry,
    required this.soilWet,
    required this.wateringDelay,
    required this.maxPumpDuration,
  });

  factory SoilThresholds.fromJson(Map<String, dynamic> json) {
    return SoilThresholds(
      soilDry: _asDouble(json['soil_dry'], fallback: 30),
      soilWet: _asDouble(json['soil_wet'], fallback: 60),
      wateringDelay: _asDouble(json['watering_delay'], fallback: 60),
      maxPumpDuration: _asDouble(json['max_pump_duration'], fallback: 20),
    );
  }

  SoilThresholds copyWith({
    double? soilDry,
    double? soilWet,
    double? wateringDelay,
    double? maxPumpDuration,
  }) {
    return SoilThresholds(
      soilDry: soilDry ?? this.soilDry,
      soilWet: soilWet ?? this.soilWet,
      wateringDelay: wateringDelay ?? this.wateringDelay,
      maxPumpDuration: maxPumpDuration ?? this.maxPumpDuration,
    );
  }

  Map<String, num> toMap() {
    return {
      'soil_dry': soilDry,
      'soil_wet': soilWet,
      'watering_delay': wateringDelay,
      'max_pump_duration': maxPumpDuration,
    };
  }
}

class SoilThresholdSnapshot {
  final DeviceSummary device;
  final SoilThresholds soil;

  const SoilThresholdSnapshot({
    required this.device,
    required this.soil,
  });

  factory SoilThresholdSnapshot.fromJson(Map<String, dynamic> json) {
    return SoilThresholdSnapshot(
      device: DeviceSummary.fromJson(_asMap(json['device'])),
      soil: SoilThresholds.fromJson(_asMap(json['soil'])),
    );
  }
}

class Bh1750Threshold {
  final double lightLowThreshold;

  const Bh1750Threshold({required this.lightLowThreshold});

  factory Bh1750Threshold.fromJson(Map<String, dynamic> json) {
    return Bh1750Threshold(
      lightLowThreshold: _asDouble(json['light_low_threshold'], fallback: 1000),
    );
  }

  Bh1750Threshold copyWith({double? lightLowThreshold}) {
    return Bh1750Threshold(
      lightLowThreshold: lightLowThreshold ?? this.lightLowThreshold,
    );
  }

  Map<String, num> toMap() => {'light_low_threshold': lightLowThreshold};
}

class Bh1750ThresholdSnapshot {
  final DeviceSummary device;
  final Bh1750Threshold bh1750;

  const Bh1750ThresholdSnapshot({
    required this.device,
    required this.bh1750,
  });

  factory Bh1750ThresholdSnapshot.fromJson(Map<String, dynamic> json) {
    return Bh1750ThresholdSnapshot(
      device: DeviceSummary.fromJson(_asMap(json['device'])),
      bh1750: Bh1750Threshold.fromJson(_asMap(json['bh1750'])),
    );
  }
}

class Dht22Threshold {
  final double tempHot;
  final double tempExtreme;
  final double humLow;

  const Dht22Threshold({
    required this.tempHot,
    required this.tempExtreme,
    required this.humLow,
  });

  factory Dht22Threshold.fromJson(Map<String, dynamic> json) {
    return Dht22Threshold(
      tempHot: _asDouble(json['temp_hot'], fallback: 30),
      tempExtreme: _asDouble(json['temp_extreme'], fallback: 38),
      humLow: _asDouble(json['hum_low'], fallback: 30),
    );
  }

  Dht22Threshold copyWith({
    double? tempHot,
    double? tempExtreme,
    double? humLow,
  }) {
    return Dht22Threshold(
      tempHot: tempHot ?? this.tempHot,
      tempExtreme: tempExtreme ?? this.tempExtreme,
      humLow: humLow ?? this.humLow,
    );
  }

  Map<String, num> toMap() {
    return {
      'temp_hot': tempHot,
      'temp_extreme': tempExtreme,
      'hum_low': humLow,
    };
  }
}

class Dht22ThresholdSnapshot {
  final DeviceSummary device;
  final Dht22Threshold dht22;

  const Dht22ThresholdSnapshot({
    required this.device,
    required this.dht22,
  });

  factory Dht22ThresholdSnapshot.fromJson(Map<String, dynamic> json) {
    return Dht22ThresholdSnapshot(
      device: DeviceSummary.fromJson(_asMap(json['device'])),
      dht22: Dht22Threshold.fromJson(_asMap(json['dht22'])),
    );
  }
}
