// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Thrown when the backend returns a non-2xx response.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Centralised HTTP client that automatically attaches the Firebase ID token
/// to every request and points at the deployed Django backend.
///
/// Usage:
///   final data = await ApiClient.instance.get('/api/users/me/');
///   await ApiClient.instance.patch('/api/users/me/', {'full_name': 'Herman'});
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const String _compileTimeBaseUrl =
      String.fromEnvironment('BACKEND_URL');

  // ── Base URL from --dart-define or .env ──────────────────────────────────
  String get _baseUrl {
    final url = _compileTimeBaseUrl.isNotEmpty
        ? _compileTimeBaseUrl
        : (dotenv.env['BACKEND_URL'] ?? '');
    // Strip a trailing slash so we never double-up
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // ── Build headers with fresh Firebase token ───────────────────────────────
  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // forceRefresh=false uses cached token (refreshes automatically when expired)
          final token = await user.getIdToken(false);
          if (token != null) headers['Authorization'] = 'Bearer $token';
        }
      } catch (e) {
        print('[ApiClient] Could not get Firebase token: $e');
      }
    }
    return headers;
  }

  // ── HTTP verbs ────────────────────────────────────────────────────────────

  Future<dynamic> get(String path, {bool auth = true}) async {
    _assertConfigured();
    final response = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(auth: auth),
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    _assertConfigured();
    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    _assertConfigured();
    final response = await http.patch(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path, {bool auth = true}) async {
    _assertConfigured();
    final response = await http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(auth: auth),
    );
    return _handleResponse(response);
  }

  // ── Response handler ──────────────────────────────────────────────────────

  void _assertConfigured() {
    if (_baseUrl.isEmpty) {
      throw const ApiException(
        500,
        'Missing BACKEND_URL configuration. Set it in .env or pass --dart-define=BACKEND_URL=https://your-render-service.onrender.com.',
      );
    }
  }

  dynamic _handleResponse(http.Response response) {
    final body = utf8.decode(response.bodyBytes);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body.isEmpty) return null;
      return jsonDecode(body);
    }

    // Try to extract a readable error message from the response body
    String message;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        message = (decoded['detail'] ??
                decoded['error'] ??
                decoded['non_field_errors']?.first ??
                decoded.values.first)
            .toString();
      } else {
        message = decoded.toString();
      }
    } catch (_) {
      message = body.isNotEmpty ? body : 'HTTP ${response.statusCode}';
    }

    throw ApiException(response.statusCode, message);
  }
}
