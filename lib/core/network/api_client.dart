import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/env.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String?>? query,
    Map<String, String>? headers,
  }) =>
      _send('GET', path, query: query, headers: headers);

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) =>
      _send('POST', path, body: body);

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body}) =>
      _send('PUT', path, body: body);

  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? body}) =>
      _send('PATCH', path, body: body);

  Future<Map<String, dynamic>> delete(String path) => _send('DELETE', path);

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String?>? query,
    Map<String, String>? headers,
  }) async {
    const base = Env.apiBaseUrl;

    final params = <String, String>{
      for (final entry in (query ?? const <String, String?>{}).entries)
        if (entry.value != null && entry.value!.isNotEmpty) entry.key: entry.value!,
    };
    final uri = Uri.parse('$base$path')
        .replace(queryParameters: params.isEmpty ? null : params);

    final request = http.Request(method, uri)
      ..headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        ...?headers,
      });
    if (body != null) request.body = jsonEncode(body);

    try {
      final streamed = await _http.send(request).timeout(Env.requestTimeout);
      final response = await http.Response.fromStream(streamed);
      return _decode(response);
    } on TimeoutException {
      throw const ApiException('The server took too long to respond');
    } on SocketException {
      throw const ApiException('No internet connection');
    } on http.ClientException {
      throw const ApiException('Could not reach the server');
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    final ok = response.statusCode >= 200 && response.statusCode < 300;
    var json = <String, dynamic>{};

    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        json = decoded is Map<String, dynamic> ? decoded : {'data': decoded};
      } on FormatException {
        if (ok) throw const ApiException('Unexpected response from the server');
      }
    }

    if (ok) return json;

    final message = json['error'] ?? json['message'];
    throw ApiException(
      message?.toString() ?? 'Request failed (${response.statusCode})',
      statusCode: response.statusCode,
    );
  }
}
