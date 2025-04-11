import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart'; // 👈 THÊM import này

import '../../../core/config/api_config.dart';
import '../../../core/utils/api_headers.dart';

class PresignedUploadResponse {
  final String url;
  final String key; // 👈 Bây giờ là required
  final int expiration;
  final Map<String, dynamic> signedHeaders;

  PresignedUploadResponse({
    required this.url,
    required this.key,
    required this.expiration,
    required this.signedHeaders,
  });

  factory PresignedUploadResponse.fromJson(Map<String, dynamic> json) {
    return PresignedUploadResponse(
      url: json['url'],
      key: json['key'],
      expiration: json['expiration'],
      signedHeaders: Map<String, dynamic>.from(json['signedHeaders']),
    );
  }
}

class S3Service {
  final String baseUrl = "${ApiConfig.baseUrl}s3/presigned-request";

  /// Tạo presigned URL để upload file
  Future<PresignedUploadResponse> getPresignedUploadUrl({
    required String contentType,
    String acl = "private",
  }) async {
    final headers = await ApiHeaders.getHeaders();

    // Tạo key duy nhất cho file
    final uuid = const Uuid().v4();
    final key = "resource/$uuid.png"; // có thể sửa đuôi nếu file không phải ảnh

    final uri = Uri.parse(
      "$baseUrl?contentType=$contentType&acl=$acl&key=$key",
    );

    final response = await http.post(uri, headers: headers);

    if (response.statusCode != 200) {
      print('❌ Failed to get presigned URL: ${response.body}');
      throw Exception("Failed to get presigned URL: ${response.body}");
    }

    final data = json.decode(response.body);
    return PresignedUploadResponse.fromJson({
      ...data,
      'key': key, // đảm bảo key luôn có
    });
  }

  /// Upload file lên S3 bằng presigned URL (HTTP PUT)
  Future<void> uploadFileToS3({
    required String uploadUrl,
    required File file,
    required String contentType,
  }) async {
    try {
      final fileBytes = await file.readAsBytes();

      final headers = {
        "Content-Type": contentType,
        "x-amz-acl": "private",
      };

      final response = await http.put(
        Uri.parse(uploadUrl),
        headers: headers,
        body: fileBytes,
      );

      if (response.statusCode != 200) {
        print('❌ Failed to upload file: ${response.body}');
        throw Exception("Failed to upload file: ${response.body}");
      }
    } catch (e) {
      print('🚨 Error uploading file: $e');
      throw Exception("Error uploading file: $e");
    }
  }

  /// Lấy presigned URL để xem file sau khi upload
  Future<String> getViewImageUrl({required String key}) async {
    final headers = await ApiHeaders.getHeaders();
    final uri = Uri.parse("$baseUrl?key=$key&contentDisposition=inline");

    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception("Failed to get image URL: ${response.body}");
    }

    final data = json.decode(response.body);
    return data['url'];
  }
}
