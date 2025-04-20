import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/api_config.dart';

class S3Service {
  static const String baseUrl = "${ApiConfig.baseUrl}s3/presigned-request";

  /// Gửi request để lấy presigned URL
  static Future<Map<String, dynamic>?> getPresignedUrl({
    required String contentType,
    required String acl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final uri = Uri.parse('$baseUrl?contentType=$contentType&acl=$acl');

    final response = await http.post(
      uri,
      headers: {
        'Accept': '*/*',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('❌ Failed to get presigned URL: ${response.statusCode}');
      return null;
    }
  }

  /// Upload ảnh tới URL đã ký và trả về URL ảnh sau khi upload thành công
  static Future<String?> uploadImage({
    required File imageFile,
    required String contentType,
    required String acl,
  }) async {
    final presignedData = await getPresignedUrl(contentType: contentType, acl: acl);
    if (presignedData == null) return null;

    final url = presignedData['url'];

    // Chuyển đổi signedHeaders từ Map<String, dynamic> sang Map<String, String>
    final signedHeaders = Map<String, String>.from(presignedData['signedHeaders'] ?? {});

    final headers = {
      'Content-Type': contentType,
      'x-amz-acl': signedHeaders['x-amz-acl'] ?? acl,
    };

    final uploadResponse = await http.put(
      Uri.parse(url),
      headers: headers,
      body: await imageFile.readAsBytes(),
    );

    if (uploadResponse.statusCode == 200) {
      // Lấy link ảnh (phần trước dấu `?`)
      final imageUrl = url.split('?').first;
      return imageUrl;
    } else {
      print('Failed to upload image: ${uploadResponse.statusCode}');
      return null;
    }
  }
}
