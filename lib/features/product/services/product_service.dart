import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
    String? categoryId,
    bool? isShown,
  }) async {
    try {
      final headers = await ApiHeaders.getHeaders();
      // Tạo danh sách filter
      List<String> filters = [];
      if (categoryId != null) filters.add("categoryId=$categoryId");
      if (isShown == true) filters.add("isShown=true");

      final queryParams = {
        'page': '$page',
        'size': '$size',
        'sort': sort,
        if (filters.isNotEmpty) 'filter': filters.join(";"),
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      final utf8DecodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final data = json.decode(utf8DecodedBody);
        final products = (data['items'] as List)
            .map((item) => ProductModel.fromMap(item))
            .toList();
        return products;
      } else {
        throw Exception("Failed to load products: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching products: $e");
    }
  }

  Future<int> getTotalProductCount({
    String? categoryId,
  }) async {
    try {
      final headers = await ApiHeaders.getHeaders();
      final queryParams = {
        'page': '0',
        'size': '1',
        'sort': 'createdAt,ASC',
        if (categoryId != null) 'filter': 'categoryId=$categoryId',
      };
      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        final data = json.decode(utf8DecodedBody);
        int totalItems = data['totalItems'];
        return totalItems;
      } else {
        throw Exception("Failed to load total product count: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching product count: $e");
    }
  }

  Future<List<ProductModel>> getCustomerProducts({
    int page = 0,
    int size = 1000,
    String sort = "createdAt,ASC",
    String? categoryId,
  }) async {
    try {
      String filter = "isShown=true";
      if (categoryId != null) {
        filter += ";categoryId=$categoryId";
      }

      String query = "?page=$page&size=$size&sort=$sort&filter=$filter";

      final response = await http.get(
        Uri.parse("$baseCusUrl$query"),
        headers: {
          "Content-Type": "application/json",
        },
      );

      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        final data = json.decode(utf8DecodedBody);
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
        String contentType = 'image/jpeg';
        String acl = 'public-read';
        imageUrl = await S3Service.uploadImage(
          imageFile: imageFile,
          contentType: contentType,
          acl: acl,
        );

        if (imageUrl != null) {
          print('Ảnh đã được upload thành công! URL ảnh: $imageUrl');
        } else {
          print('Có lỗi xảy ra khi upload ảnh.');
        }
      }

      final productData = {
        "name": name,
        "price": price,
        "description": description,
        "isShown": isShown,
        "categoryId": categoryId,
        "image": imageUrl ?? '',
      };

      print("Sending product data: $productData");

      final createResponse = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(productData),
      );

      print("Response status: ${createResponse.statusCode}");
      print("Response body: ${createResponse.body}");

      if (createResponse.statusCode != 200 &&
          createResponse.statusCode != 201) {
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

  Future<void> showProduct(ProductModel product) async {
    await _updateProductVisibility(product, true);
  }

  Future<void> hideProduct(ProductModel product) async {
    await _updateProductVisibility(product, false);
  }

  Future<void> _updateProductVisibility(
      ProductModel product, bool isVisible) async {
    try {
      final headers = await ApiHeaders.getHeaders();
      final response = await http.put(
        Uri.parse("$baseUrl/${product.id}"),
        headers: headers,
        body: json.encode({
          "name": product.name,
          "price": product.price,
          "description": product.description,
          "isShown": isVisible,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            "Failed to update product visibility: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error updating product visibility: $e");
    }
  }
}
