import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CloudinaryUploadService {
  static Future<String> uploadFile({
    required String filePath,
    String resourceType = 'auto',
    String? folder,
    String? uploadPreset,
  }) async {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME']?.trim() ?? '';
    final defaultPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET']?.trim() ?? '';
    final resumePreset =
        dotenv.env['CLOUDINARY_RESUME_UPLOAD_PRESET']?.trim() ?? '';
    final effectivePreset = uploadPreset?.trim().isNotEmpty == true
        ? uploadPreset!.trim()
        : (folder?.trim().toLowerCase() == 'resumes' && resumePreset.isNotEmpty
            ? resumePreset
            : defaultPreset);

    if (cloudName.isEmpty || effectivePreset.isEmpty) {
      throw Exception(
        'Missing Cloudinary configuration. Set CLOUDINARY_CLOUD_NAME and CLOUDINARY_UPLOAD_PRESET in .env (or CLOUDINARY_RESUME_UPLOAD_PRESET for resume uploads).',
      );
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = effectivePreset
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    if (folder != null && folder.trim().isNotEmpty) {
      request.fields['folder'] = folder.trim();
    }

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw Exception(
          'Cloudinary upload failed (${streamed.statusCode}): $body');
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic> || decoded['secure_url'] == null) {
      throw Exception('Cloudinary response missing secure_url.');
    }

    return decoded['secure_url'] as String;
  }
}
