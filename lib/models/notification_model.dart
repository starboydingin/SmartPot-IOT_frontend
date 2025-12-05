class NotificationModel {
  final String id;
  final String deviceId;
  final String? deviceName;
  final String type;
  final String message;
  final double? value;
  final double? threshold;
  final String mode;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.deviceId,
    required this.type,
    required this.message,
    required this.mode,
    required this.createdAt,
    this.deviceName,
    this.value,
    this.threshold,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final created = json['created_at'] ?? json['createdAt'];
    return NotificationModel(
      id: json['id'] as String,
      deviceId: json['device_id'] ?? json['deviceId'] ?? '',
      deviceName: json['device_name'] ?? json['deviceName'],
      type: json['type'] ?? 'UNKNOWN',
      message: json['message'] ?? '',
      value: (json['value'] is num) ? (json['value'] as num).toDouble() : double.tryParse('${json['value']}'),
      threshold: (json['threshold'] is num) ? (json['threshold'] as num).toDouble() : double.tryParse('${json['threshold']}'),
      mode: (json['mode'] ?? 'AUTO').toString(),
      createdAt: created != null ? DateTime.parse(created) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'device_name': deviceName,
      'type': type,
      'message': message,
      'value': value,
      'threshold': threshold,
      'mode': mode,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
