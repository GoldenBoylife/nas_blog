/*call "/api/upload" -> insert markdown common logic */
// lib/utils/markdown/markdown_upload_service.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nas_blog1/config/config.dart';

class MarkdownUploadService {
  /// NAS에 bytes 업로드 -> "/assets/xxx.png" 같은 relative URL 리턴
  static Future<String> uploadBytes({
    required Uint8List bytes,
    required String filename,
  }) async {
    final uri = Uri.parse('$NAS_BASE_URL/api/upload');

    final req = http.MultipartRequest('POST', uri)
      ..headers['X-ADMIN-TOKEN'] = NAS_ADMIN_
      ..files.add(
        http.MultipartFile.fromBytes(
          'file', // server.js의 upload.single("file")와 동일해야 함
          bytes,
          filename: filename,
        ),
      );

    final res = await req.send();
    final body = await res.stream.bytesToString();

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode} $body');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    // server.js: { ok:true, url:"/assets/..." }
    return json['url'] as String;
  }

  /// TextEditingController에 마크다운 이미지 문법 삽입
  static void insertImageMarkdown({
    required TextEditingController controller,
    required String fullUrl,   // 예: http://192.168.0.4:5050/assets/uuid.png
    String? alt,
  }) {
    final altText = alt ?? 'image';

    final insertText = '\n![${altText}]($fullUrl)\n';

    final text = controller.text;
    final selection = controller.selection;

    if (!selection.isValid) {
      controller.text = text + insertText;
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    } else {
      final start = selection.start;
      final end = selection.end;
      final newText = text.replaceRange(start, end, insertText);
      controller.text = newText;
      controller.selection = TextSelection.collapsed(
        offset: start + insertText.length,
      );
    }
  }
}
