int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.round();
  return int.tryParse(value.toString());
}

class ControlState {
  final String deviceId;
  final String deviceName;
  final String potName;
  final String mode;
  final String pumpStatus;
  final int? interval; // milliseconds

  const ControlState({
    required this.deviceId,
    required this.deviceName,
    required this.potName,
    required this.mode,
    required this.pumpStatus,
    this.interval,
  });

  String get displayName => potName.isNotEmpty ? potName : deviceName;

  factory ControlState.fromJson(Map<String, dynamic> json) {
    final device = Map<String, dynamic>.from(json['device'] as Map? ?? const {});
    final control = json['control'] is Map
        ? Map<String, dynamic>.from(json['control'] as Map)
        : const <String, dynamic>{};

    return ControlState(
      deviceId: (device['id'] ?? '').toString(),
      deviceName: (device['device_name'] ?? device['deviceName'] ?? '').toString(),
      potName: (device['pot_name'] ?? device['potName'] ?? device['device_name'] ?? '').toString(),
      mode: (device['mode'] ?? 'AUTO').toString().toUpperCase(),
      pumpStatus: (device['pump_status'] ?? device['pumpStatus'] ?? 'OFF').toString().toUpperCase(),
      interval: _asInt(control['interval']),
    );
  }
}
