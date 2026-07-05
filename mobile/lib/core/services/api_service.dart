import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart';
import 'app_logger.dart';
import 'storage_service.dart';

/// Cliente HTTP con cola secuencial para evitar solapamiento de requests.
abstract final class ApiService {
  static bool _isFetchingData = false;
  static final List<Future<void> Function()> _requestQueue =
      <Future<void> Function()>[];

  static Future<Map<String, dynamic>> fetchData(
    String endpoint, {
    bool authRequired = true,
    String? tokenOverride,
  }) {
    return _queueRequest(
      () => _requestWithOptions(
        endpoint,
        method: 'GET',
        authRequired: authRequired,
        tokenOverride: tokenOverride,
      ),
    );
  }

  static Future<Map<String, dynamic>> sendData(
    String endpoint,
    String method,
    Map<String, dynamic>? formData, {
    bool authRequired = true,
    String? tokenOverride,
  }) {
    return _queueRequest(
      () => _requestWithOptions(
        endpoint,
        method: method,
        authRequired: authRequired,
        tokenOverride: tokenOverride,
        body: formData,
      ),
    );
  }

  static Future<Map<String, dynamic>> deleteData(
    String endpoint, {
    bool authRequired = true,
    String? tokenOverride,
  }) {
    return _queueRequest(
      () => _requestWithOptions(
        endpoint,
        method: 'DELETE',
        authRequired: authRequired,
        tokenOverride: tokenOverride,
      ),
    );
  }

  /// POST multipart/form-data (p. ej. emergencias contextuales con imagenes).
  static Future<Map<String, dynamic>> sendMultipart(
    String endpoint, {
    required Map<String, String> fields,
    required List<ApiMultipartFile> files,
    bool authRequired = true,
    String? tokenOverride,
  }) {
    return _queueRequest(
      () => _multipartRequest(
        endpoint,
        fields: fields,
        files: files,
        authRequired: authRequired,
        tokenOverride: tokenOverride,
      ),
    );
  }

  static Future<Map<String, dynamic>> _queueRequest(
    Future<Map<String, dynamic>> Function() request,
  ) async {
    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    _requestQueue.add(() async {
      try {
        final Map<String, dynamic> result = await request();
        completer.complete(result);
      } catch (error) {
        completer.complete(<String, dynamic>{
          'ok': false,
          'statusCode': 0,
          'error': error.toString(),
        });
      }
    });

    if (!_isFetchingData) {
      unawaited(_processQueue());
    }
    return completer.future;
  }

  static Future<void> _processQueue() async {
    if (_requestQueue.isEmpty) return;
    _isFetchingData = true;

    final Future<void> Function() current = _requestQueue.removeAt(0);
    await current();

    _isFetchingData = false;
    if (_requestQueue.isNotEmpty) {
      await _processQueue();
    }
  }

  static Future<Map<String, dynamic>> _requestWithOptions(
    String endpoint, {
    required String method,
    required bool authRequired,
    String? tokenOverride,
    Map<String, dynamic>? body,
  }) async {
    try {
      final Uri uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final String? token = tokenOverride ?? await StorageService.getToken();
      final Map<String, String> headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (authRequired && token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      AppLogger.info(
        '[API] $method $endpoint | auth:$authRequired | '
        'payload:${body == null ? 'none' : 'yes'}',
      );

      final http.Response response = await _makeRequest(
        uri,
        method: method,
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      );

      final Map<String, dynamic> handled = _handleResponse(response);
      if (handled['ok'] != true) {
        AppLogger.warning(
          '[API] $method $endpoint fallo | status:${handled['statusCode']} '
          '| body:${handled['body']}',
        );
      }
      return handled;
    } catch (error) {
      AppLogger.error(
        '[API] $method $endpoint exception',
        error: error,
      );
      return <String, dynamic>{
        'ok': false,
        'statusCode': 0,
        'error': error.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> _multipartRequest(
    String endpoint, {
    required Map<String, String> fields,
    required List<ApiMultipartFile> files,
    required bool authRequired,
    String? tokenOverride,
  }) async {
    try {
      final Uri uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final String? token = tokenOverride ?? await StorageService.getToken();
      final http.MultipartRequest request = http.MultipartRequest('POST', uri);

      if (authRequired && token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields.addAll(fields);

      for (final ApiMultipartFile file in files) {
        request.files.add(
          await http.MultipartFile.fromPath(
            file.field,
            file.path,
            filename: file.filename,
          ),
        );
      }

      AppLogger.info(
        '[API] POST $endpoint | auth:$authRequired | multipart:${files.length}',
      );

      final http.StreamedResponse streamed = await request.send();
      final http.Response response = await http.Response.fromStream(streamed);
      final Map<String, dynamic> handled = _handleResponse(response);
      if (handled['ok'] != true) {
        AppLogger.warning(
          '[API] POST $endpoint fallo | status:${handled['statusCode']} '
          '| body:${handled['body']}',
        );
      }
      return handled;
    } catch (error) {
      AppLogger.error(
        '[API] POST $endpoint multipart exception',
        error: error,
      );
      return <String, dynamic>{
        'ok': false,
        'statusCode': 0,
        'error': error.toString(),
      };
    }
  }

  static Future<http.Response> _makeRequest(
    Uri uri, {
    required String method,
    required Map<String, String> headers,
    String? body,
  }) {
    switch (method.toUpperCase()) {
      case 'POST':
        return http.post(uri, headers: headers, body: body);
      case 'PUT':
        return http.put(uri, headers: headers, body: body);
      case 'PATCH':
        return http.patch(uri, headers: headers, body: body);
      case 'DELETE':
        return http.delete(uri, headers: headers);
      case 'GET':
      default:
        return http.get(uri, headers: headers);
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final int statusCode = response.statusCode;
    final bool ok = statusCode >= 200 && statusCode < 300;

    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = response.body;
    }

    return <String, dynamic>{
      'ok': ok,
      'statusCode': statusCode,
      'body': body,
    };
  }
}

/// Archivo adjunto para requests multipart.
class ApiMultipartFile {
  const ApiMultipartFile({
    required this.field,
    required this.path,
    this.filename,
  });

  final String field;
  final String path;
  final String? filename;

  static ApiMultipartFile fromPath({
    required String field,
    required String path,
  }) {
    final String name = path.split('/').last;
    return ApiMultipartFile(
      field: field,
      path: path,
      filename: name,
    );
  }
}
