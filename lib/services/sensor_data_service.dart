import '../models/device_model.dart';
import '../models/sensor_data_model.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class SensorDataService {
  final ApiService _apiService = ApiService();

  Future<List<DeviceSensorSnapshot>> listLatestForUser() async {
    try {
      final response = await _apiService.get(ApiConfig.sensorData);
      final payload = _apiService.parseResponse(response);
      final List<dynamic> data = payload['data'] as List<dynamic>? ?? [];
      return data
          .map((item) => DeviceSensorSnapshot.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Get latest sensor data error: $e');
    }
  }

  Future<SensorData?> getLatestSensorData(String deviceId) async {
    try {
      final response = await _apiService.get('${ApiConfig.sensorData}/$deviceId/latest');
      final payload = _apiService.parseResponse(response);
      final data = payload['data'] as Map<String, dynamic>?;
      if (data == null || data['latest_sensor'] == null) {
        return null;
      }
      return SensorData.fromJson(data['latest_sensor'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Get latest sensor data error: $e');
    }
  }

  Future<List<SensorData>> getHistory(
    String deviceId, {
    String range = '24h',
  }) async {
    try {
      final query = Uri(queryParameters: {'range': range}).query;
      final endpoint = '${ApiConfig.sensorData}/$deviceId/history?$query';
      final response = await _apiService.get(endpoint);
      final payload = _apiService.parseResponse(response);
      final history = (payload['data'] as Map<String, dynamic>? ?? {})['data'] as List<dynamic>? ?? [];
      return history.map((item) => SensorData.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Get sensor history error: $e');
    }
  }
}

class DeviceSensorSnapshot {
  final Device device;
  final SensorData? latestSensor;

  DeviceSensorSnapshot({
    required this.device,
    required this.latestSensor,
  });

  factory DeviceSensorSnapshot.fromJson(Map<String, dynamic> json) {
    return DeviceSensorSnapshot(
      device: Device.fromJson(json['device'] as Map<String, dynamic>),
      latestSensor: json['latest_sensor'] != null
          ? SensorData.fromJson(json['latest_sensor'] as Map<String, dynamic>)
          : null,
    );
  }
}
