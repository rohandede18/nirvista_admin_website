import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/storage_service.dart';

class AdminApiService {
  static String? _token;

  static Future<String?> token() async {
    if (_token != null && _token!.isNotEmpty) {
      return _token;
    }
    _token = await StorageService.getAdminToken();
    return _token;
  }

  static Future<void> clearToken() async {
    _token = null;
    await StorageService.clearAdminToken();
  }

  static Future<Map<String, String>> _headers({required bool auth}) async {
    final saved = auth ? await token() : null;
    return {
      'Content-Type': 'application/json',
      if (auth && saved != null && saved.isNotEmpty) 'Authorization': 'Bearer $saved',
    };
  }

  static Uri _buildUri(String url, Map<String, dynamic>? query) {
    if (query == null || query.isEmpty) {
      return Uri.parse(url);
    }

    final parsed = Uri.parse(url);
    final q = <String, String>{...parsed.queryParameters};
    for (final entry in query.entries) {
      final value = entry.value;
      if (value == null) {
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        q[entry.key] = text;
      }
    }
    return parsed.replace(queryParameters: q);
  }

  static String? _extractToken(Map<String, dynamic> map) {
    const tokenKeys = ['token', 'accessToken', 'adminToken'];

    for (final key in tokenKeys) {
      final value = map[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    final data = map['data'];
    if (data is Map<String, dynamic>) {
      return _extractToken(data);
    }
    return null;
  }

  static Map<String, dynamic> _decode(http.Response response) {
    final success = response.statusCode >= 200 && response.statusCode < 300;
    if (response.body.isEmpty) {
      return {'success': success, 'statusCode': response.statusCode};
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return {
          ...decoded,
          'success': decoded['success'] ?? success,
          'statusCode': response.statusCode,
        };
      }
      return {
        'success': success,
        'statusCode': response.statusCode,
        'data': decoded,
      };
    } catch (_) {
      return {
        'success': success,
        'statusCode': response.statusCode,
        'message': response.body,
      };
    }
  }

  static Future<Map<String, dynamic>> request({
    required String method,
    required String url,
    bool requiresAuth = true,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
  }) async {
    final headers = await _headers(auth: requiresAuth);
    final uri = _buildUri(url, query);

    late http.Response response;
    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
        break;
      case 'PATCH':
        response = await http.patch(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
        break;
      case 'PUT':
        response = await http.put(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
        break;
      case 'DELETE':
        response = await http.delete(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
        break;
      default:
        return {'success': false, 'message': 'Unsupported HTTP method: $method'};
    }

    final result = _decode(response);
    if (result['success'] == true) {
      final extracted = _extractToken(result);
      if (extracted != null && extracted.isNotEmpty) {
        _token = extracted;
        await StorageService.saveAdminToken(extracted);
      }
    }
    return result;
  }
}
