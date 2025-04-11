import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../core/utils/api_headers.dart';
import '../model/product_model.dart';
import 's3_service.dart';

class ProductService {
  final String baseUrl = "${ApiConfig.baseUrl}dishes";
  final String baseCusUrl = "${ApiConfig.baseUrl}customer/dishes";
  final S3Service s3Service = S3Service();

  // Create a StreamController
  final StreamController<List<ProductModel>> _productStreamController =
      StreamController<List<ProductModel>>.broadcast();

  // Create a getter to access the stream
  Stream<List<ProductModel>> get productStream =>
      _productStreamController.stream;

  // Close the stream when done
  void closeStream() {
    _productStreamController.close();
  }

  // 🧾 API dành cho admin/có token
  Future<List<ProductModel>> getProducts({
    int page = 0,
    int size = 1000,
    String sort = "createdAt,ASC",
  }) async {
    try {
      final headers = await ApiHeaders.getHeaders();
      final response = await http.get(
        Uri.parse("$baseUrl?page=$page&size=$size&sort=$sort"),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['items'] as List)
            .map((item) => ProductModel.fromMap(item))
            .toList();
      } else {
        throw Exception("Failed to load products: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching products: $e");
    }
  }

  Future<List<ProductModel>> getCustomerProducts({
    int page = 0,
    int size = 1000,
    String sort = "createdAt,ASC",
    String? categoryId,
  }) async {
    try {
      String query =
          "?page=$page&size=$size&sort=$sort${categoryId != null ? '&filter=categoryId=$categoryId' : ''}";

      final response = await http.get(
        Uri.parse("$baseCusUrl$query"),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['items'] as List)
            .map((item) => ProductModel.fromMap(item))
            .toList();
      } else {
        throw Exception("Failed to load customer products: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching customer products: $e");
    }
  }

  Future<ProductModel> getProductById(String id) async {
    try {
      final headers = await ApiHeaders.getHeaders();
      final response = await http.get(
        Uri.parse("$baseUrl/$id"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ProductModel.fromMap(json.decode(response.body));
      } else {
        throw Exception("Failed to load product: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching product: $e");
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final headers = await ApiHeaders.getHeaders();
      final response = await http.delete(
        Uri.parse("$baseUrl/$id"),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to delete product: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error deleting product: $e");
    }
  }

  Future<void> createProduct(
      String name,
      double price,
      String description,
      bool isShown,
      String categoryId,
      File? imageFile,
      ) async {
    try {
      final headers = await ApiHeaders.getHeaders();
      String? imageUrl;

      if (imageFile != null) {
        // B1: Lấy presigned URL
        final presigned = await s3Service.getPresignedUploadUrl(
          contentType: 'image/jpeg',
        );

        // B2: Upload file lên S3
        await s3Service.uploadFileToS3(
          uploadUrl: presigned.url,
          file: imageFile,
          contentType: 'image/jpeg',
        );

        // B3: Lấy URL để truy cập ảnh
        imageUrl = await s3Service.getViewImageUrl(key: presigned.key);
      }

      print(imageUrl);

      final productData = {
        "name": name,
        "price": price,
        "description": description,
        "isShown": isShown,
        "categoryId": categoryId,
        "image": imageUrl,
      };

      print(productData);

      final createResponse = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(productData),
      );

      print(productData);
      print(createResponse.body);

      if (createResponse.statusCode != 200 && createResponse.statusCode != 201) {
        throw Exception("❌ Failed to create product: ${createResponse.body}");
      }

      print("✅ Product created successfully");
    } catch (e) {
      print("🚨 Error creating product: $e");
      throw Exception("Error creating product: $e");
    }
  }



  Future<void> updateProduct(
    String id,
    String name,
    double price,
    String description,
    bool isShown,
    String categoryId,
  ) async {
    try {
      final headers = await ApiHeaders.getHeaders();
      final response = await http.put(
        Uri.parse("$baseUrl/$id"),
        headers: headers,
        body: json.encode({
          "name": name,
          "price": price,
          "description": description,
          "isShown": isShown,
          "categoryId": categoryId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to update product: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error updating product: $e");
    }
  }
}
