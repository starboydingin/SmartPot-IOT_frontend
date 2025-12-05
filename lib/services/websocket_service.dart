import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  final Map<String, WebSocketChannel> _channels = {};
  final Map<String, StreamController<Map<String, dynamic>>> _controllers = {};

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Stream<Map<String, dynamic>>> connectToSensorData() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token available');
    }

    final uri = Uri.parse('${ApiConfig.wsUrl}${ApiConfig.wsSensorData}')
        .replace(queryParameters: {'token': token});

    return _connect('sensor-data', uri);
  }

  Future<Stream<Map<String, dynamic>>> connectToNotifications() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token available');
    }

    final uri = Uri.parse('${ApiConfig.wsUrl}${ApiConfig.wsNotifications}')
        .replace(queryParameters: {'token': token});

    return _connect('notifications', uri);
  }

  Future<Stream<Map<String, dynamic>>> connectToControl() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token available');
    }

    final uri = Uri.parse('${ApiConfig.wsUrl}${ApiConfig.wsControl}')
        .replace(queryParameters: {'token': token});

    return _connect('control', uri);
  }

  Future<void> sendControlMessage(Map<String, dynamic> message) async {
    await _send('control', message);
  }

  Future<Stream<Map<String, dynamic>>> connectToThresholds() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token available');
    }

    final uri = Uri.parse('${ApiConfig.wsUrl}${ApiConfig.wsThresholds}')
        .replace(queryParameters: {'token': token});

    return _connect('thresholds', uri);
  }

  Future<void> sendThresholdMessage(Map<String, dynamic> message) async {
    await _send('thresholds', message);
  }

  Future<void> requestSoilThreshold(String deviceId) async {
    await sendThresholdMessage({
      'type': 'threshold:soil:get',
      'payload': {'deviceId': deviceId},
    });
  }

  Future<void> updateSoilThreshold(String deviceId, Map<String, num> values) async {
    await sendThresholdMessage({
      'type': 'threshold:soil:update',
      'payload': {
        'deviceId': deviceId,
        ...values,
      },
    });
  }

  Future<void> requestBh1750Threshold(String deviceId) async {
    await sendThresholdMessage({
      'type': 'threshold:bh1750:get',
      'payload': {'deviceId': deviceId},
    });
  }

  Future<void> updateBh1750Threshold(String deviceId, Map<String, num> values) async {
    await sendThresholdMessage({
      'type': 'threshold:bh1750:update',
      'payload': {
        'deviceId': deviceId,
        ...values,
      },
    });
  }

  Future<void> requestDht22Threshold(String deviceId) async {
    await sendThresholdMessage({
      'type': 'threshold:dht22:get',
      'payload': {'deviceId': deviceId},
    });
  }

  Future<void> updateDht22Threshold(String deviceId, Map<String, num> values) async {
    await sendThresholdMessage({
      'type': 'threshold:dht22:update',
      'payload': {
        'deviceId': deviceId,
        ...values,
      },
    });
  }

  Future<void> requestSensorLatest(String deviceId) async {
    await _send('sensor-data', {
      'type': 'sensor-data:latest:request',
      'deviceId': deviceId,
    });
  }

  Future<void> requestSensorHistory(String deviceId, {String range = '24h'}) async {
    await _send('sensor-data', {
      'type': 'sensor-data:history:request',
      'deviceId': deviceId,
      'range': range,
    });
  }

  Future<Stream<Map<String, dynamic>>> _connect(String key, Uri uri) async {
    final existingChannel = _channels[key];
    final existingController = _controllers[key];
    if (existingChannel != null && existingController != null && !existingController.isClosed) {
      return existingController.stream;
    }

    await _disconnectChannel(key);

    final controller = StreamController<Map<String, dynamic>>.broadcast();
    final channel = WebSocketChannel.connect(uri);

    _channels[key] = channel;
    _controllers[key] = controller;

    channel.stream.listen(
      (data) {
        try {
          final raw = data is String ? data : utf8.decode(data as List<int>);
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            controller.add(decoded);
          } else {
            controller.add({'payload': decoded});
          }
        } catch (_) {
          controller.addError(Exception('Malformed WebSocket payload'));
        }
      },
      onError: controller.addError,
      onDone: () {
        _channels.remove(key);
        final existing = _controllers.remove(key);
        if (existing != null && !existing.isClosed) {
          existing.close();
        }
      },
    );

    return controller.stream;
  }

  Future<void> _send(String key, Map<String, dynamic> message) async {
    final channel = _channels[key];
    if (channel == null) {
      throw Exception('WebSocket channel not connected: $key');
    }
    channel.sink.add(jsonEncode(message));
  }

  Future<void> _disconnectChannel(String key) async {
    final channel = _channels.remove(key);
    final controller = _controllers.remove(key);

    await channel?.sink.close();
    if (controller != null && !controller.isClosed) {
      controller.close();
    }
  }

  Future<void> disconnectAll() async {
    final keys = _channels.keys.toList();
    for (final key in keys) {
      await _disconnectChannel(key);
    }
  }

  Future<void> disconnect({String? key}) async {
    if (key != null) {
      await _disconnectChannel(key);
    } else {
      await disconnectAll();
    }
  }
}
