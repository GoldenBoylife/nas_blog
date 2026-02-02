/*MarkdownUploadService.uploadByes와 같은 역할 */
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/config.dart';

/* 
/api/upload 응답JSON을 표현 
server.js:
  res.json({ ok:true, url: publicUrl, filename: finalName, ext })

*/

class UploadResult {
  final String url; // "/media/uuid.png"
  final String filename;
  final String ext; //확장자

  const UploadResult({
    required this.url,
    required this.filename,
    required this.ext
  });

  factory UploadResult.fromJson(Map<String,dynamic> j) {
    return UploadResult(
      url: j['url'] as String, 
      filename: j['filename'] as String, 
      ext: j['ext'] as String
    );
  
  }
  /// NAS_BASE_URL까지 붙인 전체 URL
  String get full_url => '$NAS_BASE_URL$url';
} 

class UploadService{
  const UploadService._(); // 전부 static으로 쓰기위해서 private생성자. 

  /// 바이트 + 파일명 -> NAS /api/uplad ->UploadResult
  static Future<UploadResult> uploadBytes({
    required Uint8List bytes,
    required String filename,
  }) async{
    final uri = Uri.parse('$NAS_BASE_URL/api/upload');

    final req = http.MultipartRequest('POST', uri)
      ..headers['X-ADMIN-TOKEN'] = NAS_ADMIN_
      ..files.add(
        http.MultipartFile.fromBytes(
          'file', // server.js의 upload.single("file")과 동일
          bytes,
          filename: filename,
        )
      );

      final res = await req.send();
      final body = await res.stream.bytesToString();
      
    if(res.statusCode !=200) 
    {
      throw Exception('Upload failed: HTTP ${res.statusCode} $body');

    }

    final Map<String, dynamic> json = 
      jsonDecode(body) as Map<String, dynamic>;
      return UploadResult.fromJson(json);

  }

}