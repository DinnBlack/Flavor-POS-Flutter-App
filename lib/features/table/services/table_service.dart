import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../core/utils/api_headers.dart';
import '../model/table_model.dart';

class TableService {
  final String baseUrl = "${ApiConfig.baseUrl}tables";

  // Lấy tất cả các bàn với phân trang, sắp xếp
  Future<List<TableModel>> getTables({
    int page = 0,
    int size = 100,
    String sort = "number,ASC",
    String? status,
  }) async {
    final headers = await ApiHeaders.getHeaders();

    String url = "$baseUrl?page=$page&size=$size&sort=$sort";
    if (status != null) {
      url += "&filter=status=$status";
    }

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    final utf8DecodedBody = utf8.decode(response.bodyBytes);

    if (response.statusCode == 200) {
      final data = json.decode(utf8DecodedBody);
      final List<TableModel> tables = (data['items'] as List)
          .map((item) => TableModel.fromMap(item))
          .toList();
      return tables;
    } else {
      throw Exception("Failed to load tables");
    }
  }

  // Lấy thông tin một bàn theo id
  Future<TableModel> getTableById(String id) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl/$id"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return TableModel.fromMap(json.decode(response.body));
    } else {
      throw Exception("Failed to load table");
    }
  }

  // Xóa một bàn theo id
  Future<void> deleteTable(String id) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.delete(
      Uri.parse("$baseUrl/$id"),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to delete table");
    }
  }

// Tạo mới một bàn
  Future<void> createTable(int number, String floorId) async {
    try {
      final headers = await ApiHeaders.getHeaders();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode({
          'number': number,
          'description': '',
          'status': 'AVAILABLE',
          'floorId': floorId
        }),
      );

      if (response.statusCode == 200) {
        print('Table created successfully');
      } else {
        throw Exception(
            "Failed to create table, Status code: ${response.statusCode}");
      }
    } catch (e) {
      print('Error: $e');
      throw Exception("An error occurred while creating the table");
    }
  }

  // Cập nhật thông tin bàn theo id
  Future<void> updateTable(
      String id, int number, String description, String floorId) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: headers,
      body: json.encode({
        'number': number,
        'description': description,
        'status': 'AVAILABLE',
        'floorId': floorId
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to update table");
    }
  }

// Tạo bàn đồng loạt
  Future<void> createMultipleTables(
      List<Map<String, dynamic>> tableDataList) async {
    bool allFailed = true;

    for (var tableData in tableDataList) {
      try {
        await createTable(tableData['number'], tableData['floorId']);
        allFailed = false;
      } catch (e) {
        print("Failed to create table ${tableData['number']}: $e");
      }
    }

    if (allFailed) {
      throw Exception("All table creations failed");
    }
  }

  // Lấy sô lượng bàn theo trạng thái
  Future<int> countTablesByStatus(
    String? status, {
    String? floorName,
    List<TableModel>? listTable,
  }) async {
    try {
      List<TableModel> tables = listTable ?? await getTables(size: 1000);

      List<TableModel> filteredTables = tables.where((table) {
        bool matchStatus = true;
        if (status != null) {
          matchStatus = table.status == status;
        }
        bool matchFloor = true;
        if (floorName != null) {
          matchFloor = table.floorName == floorName;
        }
        return matchStatus && matchFloor;
      }).toList();

      return filteredTables.length;
    } catch (e) {
      print("Lỗi khi đếm bàn: $e");
      return 0;
    }
  }

  // Cập nhật trạng thái bàn (chung cho tất cả trạng thái)
  Future<void> updateTableStatus(String id, String status) async {
    try {
      // Chuyển trạng thái thành chữ hoa
      final statusUpperCase = status.toUpperCase();
      final headers = await ApiHeaders.getHeaders();
      final response = await http.put(
        Uri.parse("$baseUrl/$id"),
        headers: headers,
        body: json.encode({
          'status': statusUpperCase,
        }),
      );

      if (response.statusCode == 200) {
        print('Table status updated to $statusUpperCase');
      } else {
        throw Exception("Failed to update table status to $statusUpperCase");
      }
    } catch (e) {
      print('Error: $e');
      throw Exception(
          "An error occurred while updating table status to $status");
    }
  }

  // Sử dụng hàm updateTableStatus cho từng trạng thái
  Future<void> updateTableStatusAvailable(String id) async {
    await updateTableStatus(id, 'available');
  }

  Future<void> updateTableStatusOccupied(String id) async {
    await updateTableStatus(id, 'occupied');
  }

  Future<void> updateTableStatusReserved(String id) async {
    await updateTableStatus(id, 'reserved');
  }

  // Lấy bàn theo số bàn (tableNumber)
  Future<TableModel> getTableByTableNumber(int tableNumber) async {
    final headers = await ApiHeaders.getHeaders();

    String url =
        "$baseUrl?page=0&size=10&sort=createdAt,DESC&filter=number=$tableNumber";

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    final utf8DecodedBody = utf8.decode(response.bodyBytes);

    if (response.statusCode == 200) {
      final data = json.decode(utf8DecodedBody);
      final table = TableModel.fromMap(data['items'][0]);
      return table;
    } else {
      throw Exception("Failed to load table with number $tableNumber");
    }
  }

  // Lấy thông tin bàn theo số bàn (tableNumber)
  Future<TableModel> getCustomerTableByNumber(int number) async {
    String url =
        "${ApiConfig.baseUrl}customer/tables?page=0&size=10&sort=createdAt,DESC&filter=number=$number";

    final response = await http.get(
      Uri.parse(url),
    );

    final utf8DecodedBody = utf8.decode(response.bodyBytes);

    if (response.statusCode == 200) {
      final data = json.decode(utf8DecodedBody);
      print(data);
      if (data['items'].isNotEmpty) {
        return TableModel.fromMap(data['items'][0]);
      } else {
        throw Exception("No table found with number $number");
      }
    } else {
      throw Exception("Failed to load table with number $number");
    }
  }
}
