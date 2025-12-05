import '../models/device_model.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class DeviceService {
  final ApiService _apiService = ApiService();

  Future<List<Device>> getAllDevices() async {
    try {
      final response = await _apiService.get(ApiConfig.devices);
      final payload = _apiService.parseResponse(response);
      final List<dynamic> data = (payload['data'] as List<dynamic>? ?? []);
      return data.map((json) => Device.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Get devices error: $e');
    }
  }

  Future<Device> getDeviceById(String id) async {
    try {
      final response = await _apiService.get('${ApiConfig.devices}/$id');
      final payload = _apiService.parseResponse(response);
      return Device.fromJson(payload['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Get device error: $e');
    }
  }

  Future<Device> createDevice({
    required String deviceName,
    required String potName,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.devices,
        {
          'device_name': deviceName,
          'pot_name': potName,
        },
      );

      final payload = _apiService.parseResponse(response);
      return Device.fromJson(payload['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Create device error: $e');
    }
  }

  Future<bool> updateDevice(
    String id, {
    String? deviceName,
    String? potName,
  }) async {
    try {
      final response = await _apiService.put(
        '${ApiConfig.devices}/$id',
        {
          if (deviceName != null) 'device_name': deviceName,
          if (potName != null) 'pot_name': potName,
        },
      );

      final payload = _apiService.parseResponse(response);
      final data = payload['data'] as Map<String, dynamic>?;
      if (data == null) return true;
      if (data['updated'] == true) return true;
      if (data['success'] == true) return true;
      return false;
    } catch (e) {
      throw Exception('Update device error: $e');
    }
  }

  Future<bool> deleteDevice(String id) async {
    try {
      final response = await _apiService.delete('${ApiConfig.devices}/$id');
      final payload = _apiService.parseResponse(response);
      final data = payload['data'] as Map<String, dynamic>?;
      if (data == null) return true;
      if (data['deleted'] == true) return true;
      if (data['success'] == true) return true;
      return false;
    } catch (e) {
      throw Exception('Delete device error: $e');
    }
  }
}
