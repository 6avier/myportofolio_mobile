import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/project.dart';

/// Exception thrown when an API request returns a non-2xx status code.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;

  /// Raw response body, kept for debugging. Show [userMessage] in the UI.
  final String message;

  /// A short message that is safe to show to the user. The raw body can be a
  /// Django HTML error page when DEBUG is on, so it is never shown directly.
  String get userMessage {
    switch (statusCode) {
      case 400:
        return 'Data tidak valid ($statusCode).';
      case 401:
        return 'Sesi login berakhir, silakan login lagi ($statusCode).';
      case 403:
        return 'Akun ini tidak punya izin untuk aksi ini ($statusCode).';
      case 404:
        return 'Data tidak ditemukan ($statusCode).';
      default:
        return statusCode >= 500
            ? 'Server sedang bermasalah ($statusCode).'
            : 'Permintaan gagal ($statusCode).';
    }
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// HTTP client for the MyPortfolio Django REST Framework backend.
///
/// Header keys are plain strings instead of `HttpHeaders` from `dart:io`, so
/// the client also builds for Flutter Web.
class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  static const _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<List<Project>> getProjects() async {
    final response = await _client.get(
      _uri('/api/v1/projects/'),
      headers: const {'Accept': 'application/json'},
    );
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => Project.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Project> createProject(
    Project project, {
    required String token,
  }) async {
    final response = await _client.post(
      _uri('/api/v1/projects/'),
      headers: {..._jsonHeaders, 'Authorization': 'Token $token'},
      body: jsonEncode(project.toJson()),
    );
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return Project.fromJson(decoded);
  }

  Future<String> obtainToken(String username, String password) async {
    final response = await _client.post(
      _uri('/api/v1/auth/token/'),
      headers: _jsonHeaders,
      body: jsonEncode({'username': username, 'password': password}),
    );
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['token'] as String;
  }

  Future<void> logout({required String token}) async {
    final response = await _client.post(
      _uri('/api/v1/auth/logout/'),
      headers: {'Accept': 'application/json', 'Authorization': 'Token $token'},
    );
    _ensureSuccess(response);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw ApiException(response.statusCode, response.body);
  }
}
