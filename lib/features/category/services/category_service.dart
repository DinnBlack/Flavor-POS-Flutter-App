import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../core/utils/api_headers.dart';
import '../model/category_model.dart';

class CategoryService {
  final String baseUrl = "${ApiConfig.baseUrl}categories";
  final String baseCusUrl = "${ApiConfig.baseUrl}customer/categories";

  Future<List<CategoryModel>> getCategories(
      {int page = 0, int size = 10, String sort = "createdAt,ASC"}) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl?page=$page&size=$size&sort=$sort"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<CategoryModel> categories = (data['items'] as List)
          .map((item) => CategoryModel.fromMap(item))
          .toList();
      return categories;
    } else {
      throw Exception("Failed to load categories");
    }
  }

  Future<List<CategoryModel>> getCustomerCategories(
      {int page = 0, int size = 10, String sort = "createdAt,ASC"}) async {
    final response = await http.get(
      Uri.parse("$baseCusUrl?page=$page&size=$size&sort=$sort"),
      headers: {
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<CategoryModel> categories = (data['items'] as List)
          .map((item) => CategoryModel.fromMap(item))
          .toList();
      return categories;
    } else {
      throw Exception("Failed to load categories");
    }
  }

  Future<CategoryModel> getCategoryById(String id) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl/$id"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load category");
    }
  }

  Future<void> deleteCategory(String id) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.delete(
      Uri.parse("$baseUrl/$id"),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to delete category");
    }
  }

  Future<void> createCategory(String categoryName) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: json.encode({'name': categoryName}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to create category");
    }
  }

  Future<void> updateCategory(String id, String categoryName) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: headers,
      body: json.encode({'name': categoryName}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to update category");
    }
  }
}
