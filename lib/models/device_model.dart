class Device {
  final String id;
  final String deviceName;
  final String potName;
  final String mode;
  final String pumpStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  Device({
    required this.id,
    required this.deviceName,
    required this.potName,
    required this.mode,
    required this.pumpStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayName => potName.isNotEmpty ? potName : deviceName;

  factory Device.fromJson(Map<String, dynamic> json) {
    final created = json['created_at'] ?? json['createdAt'];
    final updated = json['updated_at'] ?? json['updatedAt'];

    return Device(
      id: json['id'] as String,
      deviceName: json['device_name'] ?? json['deviceName'] ?? '',
      potName: json['pot_name'] ?? json['potName'] ?? json['device_name'] ?? '',
      mode: (json['mode'] ?? 'AUTO').toString(),
      pumpStatus: (json['pump_status'] ?? 'OFF').toString(),
      createdAt: created != null ? DateTime.parse(created) : DateTime.now(),
      updatedAt: updated != null ? DateTime.parse(updated) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_name': deviceName,
      'pot_name': potName,
      'mode': mode,
      'pump_status': pumpStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
