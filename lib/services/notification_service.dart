import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/notification_model.dart';
import 'api_service.dart';

class NotificationService {
  final ApiService _apiService = ApiService();

  Future<List<NotificationModel>> fetchActiveNotifications() async {
    final http.Response response = await _apiService.get(ApiConfig.notifications);
    final Map<String, dynamic> body = _apiService.parseResponse(response);
    final dynamic data = body['data'];

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(NotificationModel.fromJson)
          .toList();
    }

    return const <NotificationModel>[];
  }

  Future<void> clearNotifications() async {
    final http.Response response = await _apiService.delete(ApiConfig.notifications);
    _apiService.parseResponse(response);
  }
}
