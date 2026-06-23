import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aeronet_app_flutter/data/services/storage_service.dart';
import 'package:aeronet_app_flutter/core/constants/app_constants.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String get _baseUrl {
    final fallbackUrl = dotenv.env['API_BASE_URL'] ?? AppConstants.defaultApiUrl;
    return StorageService.instance.getApiBaseUrl(fallbackUrl);
  }

  Uri _uri(String path) {
    final cleanBase = _baseUrl.replaceAll(RegExp(r'/+$'), '');
    final cleanPath = path.replaceFirst(RegExp(r'^/+'), '');
    return Uri.parse('$cleanBase/$cleanPath');
  }

  Map<String, String> get _headers {
    final token = StorageService.instance.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path) async {
    return _send(() => http.get(_uri(path), headers: _headers));
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    return _send(() => http.post(
          _uri(path),
          headers: _headers,
          body: jsonEncode(body),
        ));
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    return _send(() => http.patch(
          _uri(path),
          headers: _headers,
          body: jsonEncode(body),
        ));
  }

  Future<dynamic> delete(String path) async {
    return _send(() => http.delete(_uri(path), headers: _headers));
  }

  Future<dynamic> uploadAvatar(File file) async {
    try {
      final request = http.MultipartRequest('POST', _uri('/customers/me/avatar'));
      final token = StorageService.instance.getToken();
      
      request.headers.addAll({
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      
      request.files.add(await http.MultipartFile.fromPath('avatar', file.path));
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);
      
      return _decodeResponse(response);
    } on SocketException {
      throw ApiException('No se pudo conectar con el backend. Revisa tu conexión.');
    } on TimeoutException {
      throw ApiException('La solicitud de carga del avatar excedió el tiempo límite (60s).');
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(const Duration(seconds: 60));
      return _decodeResponse(response);
    } on SocketException {
      throw ApiException('No se pudo conectar con el backend. Revisa tu conexión.');
    } on TimeoutException {
      throw ApiException('La solicitud excedió el tiempo límite (60 segundos).');
    }
  }

  dynamic _decodeResponse(http.Response response) {
    final bodyText = utf8.decode(response.bodyBytes);
    dynamic body;
    if (bodyText.isNotEmpty) {
      try {
        body = jsonDecode(bodyText);
      } catch (_) {
        body = bodyText;
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body is Map
          ? '${body['message'] ?? body['error'] ?? 'Error del servidor'}'
          : 'Error HTTP ${response.statusCode}';
      throw ApiException(message);
    }
    return body;
  }
}
