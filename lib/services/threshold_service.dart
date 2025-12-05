import '../config/api_config.dart';
import '../models/threshold_models.dart';
import 'api_service.dart';

class ThresholdService {
  final ApiService _apiService = ApiService();

  Future<SoilThresholdSnapshot> fetchSoil(String deviceId) async {
    final response = await _apiService.get('${ApiConfig.thresholds}/$deviceId/soil');
    final payload = _apiService.parseResponse(response);
    final data = payload['data'] as Map<String, dynamic>? ?? const {};
    return SoilThresholdSnapshot.fromJson(data);
  }

  Future<Bh1750ThresholdSnapshot> fetchBh1750(String deviceId) async {
    final response = await _apiService.get('${ApiConfig.thresholds}/$deviceId/bh1750');
    final payload = _apiService.parseResponse(response);
    final data = payload['data'] as Map<String, dynamic>? ?? const {};
    return Bh1750ThresholdSnapshot.fromJson(data);
  }

  Future<Dht22ThresholdSnapshot> fetchDht22(String deviceId) async {
    final response = await _apiService.get('${ApiConfig.thresholds}/$deviceId/dht22');
    final payload = _apiService.parseResponse(response);
    final data = payload['data'] as Map<String, dynamic>? ?? const {};
    return Dht22ThresholdSnapshot.fromJson(data);
  }
}
