import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ResumeUploadService {
  static const String _defaultBaseUrl =
      'https://campus-job-board-project.onrender.com';

  static String get _baseUrl {
    final envUrl = dotenv.env['BACKEND_URL'] ?? '';
    final url = envUrl.isNotEmpty ? envUrl : _defaultBaseUrl;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// Uploads [filePath] to the Django backend which stores it in Firebase
  /// Storage using the server-side admin SDK (no client-side rules apply).
  /// Returns the public download URL.
  static Future<String> uploadResume({required String filePath}) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('Selected file does not exist at path: $filePath');
    }

    // Get Firebase auth token
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated. Please sign in.');
    final token = await user.getIdToken();

    final uri = Uri.parse('$_baseUrl/api/users/upload-resume/');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      String errorMsg = 'Upload failed (${streamed.statusCode})';
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map && decoded['error'] != null) {
          errorMsg = decoded['error'].toString();
        }
      } catch (_) {}
      throw Exception(errorMsg);
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map || decoded['url'] == null) {
      throw Exception('Backend response missing "url" field.');
    }

    return decoded['url'] as String;
  }
}
