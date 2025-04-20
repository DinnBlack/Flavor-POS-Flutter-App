import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../core/utils/api_headers.dart';
import '../model/shift_model.dart';

class ShiftService {
  final String baseUrl = "${ApiConfig.baseUrl}shifts";

  // Lấy danh sách các ca làm việc
  Future<List<ShiftModel>> getShifts({
    int page = 0,
    int size = 1000,
    String sort = "createdAt,DESC",
  }) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl?page=$page&size=$size&sort=$sort"),
      headers: headers,
    );

    final utf8DecodedBody = utf8.decode(response.bodyBytes);
    if (response.statusCode == 200) {
      final data = json.decode(utf8DecodedBody);
      final List<ShiftModel> shifts = (data['items'] as List)
          .map((item) => ShiftModel.fromMap(item))
          .toList();

      return shifts;
    } else {
      throw Exception("Failed to load shifts");
    }
  }

  // Lấy ca làm việc theo ID
  Future<ShiftModel> getShiftById(String id) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl/$id"),
      headers: headers,
    );

    final utf8DecodedBody = utf8.decode(response.bodyBytes);
    if (response.statusCode == 200) {
      return ShiftModel.fromMap(json.decode(utf8DecodedBody));
    } else {
      throw Exception("Failed to get shift by ID");
    }
  }

  // Bắt đầu ca làm mới
  Future<void> startShift() async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.post(
      Uri.parse("$baseUrl/start"),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to start new shift");
    }
  }

  Future<void> endShift(String shiftId) async {
    final headers = await ApiHeaders.getHeaders();

    final response = await http.put(
      Uri.parse("$baseUrl/$shiftId/end"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      print("Shift ended successfully");
    } else {
      throw Exception("Failed to end shift");
    }
  }

  Future<ShiftModel?> getCurrentShift() async {
    final headers = await ApiHeaders.getHeaders();

    final response = await http.get(
      Uri.parse("$baseUrl?page=0&size=10&sort=createdAt,DESC"),
      headers: headers,
    );

    final utf8DecodedBody = utf8.decode(response.bodyBytes);
    if (response.statusCode == 200) {
      final data = json.decode(utf8DecodedBody);
      final items = data['items'] as List;
      for (var item in items) {
        if (item['open'] == true) {
          return ShiftModel.fromMap(item);
        }
      }
      return null;
    } else {
      throw Exception("Failed to load shifts");
    }
  }
}
