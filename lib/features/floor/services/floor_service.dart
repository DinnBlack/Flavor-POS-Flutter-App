import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../core/utils/api_headers.dart';
import '../model/floor_model.dart';

class FloorService {
  final String baseUrl = "${ApiConfig.baseUrl}floors";

  // Lấy tất cả các tầng với phân trang, sắp xếp
  Future<List<FloorModel>> getFloors(
      {int page = 0, int size = 10, String sort = "createdAt,ASC"}) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl?page=$page&size=$size&sort=$sort"),
      headers: headers,
    );
    final utf8DecodedBody = utf8.decode(response.bodyBytes);
    if (response.statusCode == 200) {
      final data = json.decode(utf8DecodedBody);
      final List<FloorModel> floors = (data['items'] as List)
          .map((item) => FloorModel.fromMap(item))
          .toList();
      return floors;
    } else {
      throw Exception("Failed to load floors");
    }
  }

  // Lấy thông tin một tầng theo id
  Future<FloorModel> getFloorById(String id) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl/$id"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return FloorModel.fromMap(json.decode(response.body));
    } else {
      throw Exception("Failed to load floor");
    }
  }

  // Xóa một tầng theo id
  Future<void> deleteFloor(String id) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.delete(
      Uri.parse("$baseUrl/$id"),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to delete floor");
    }
  }

  // Tạo mới một tầng
  Future<void> createFloor(String floorName) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: json.encode({'name': floorName}),
    );
    if (response.statusCode == 200) {
      print('Floor created successfully');
    } else {
      throw Exception("Failed to create floor");
    }
  }

  // Cập nhật thông tin tầng theo id
  Future<void> updateFloor(String id, String floorName) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: headers,
      body: json.encode({'name': floorName}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to update floor");
    }
  }
}
