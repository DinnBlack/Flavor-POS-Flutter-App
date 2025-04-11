import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:order_management_flutter_app/core/controllers/session_controller.dart';
import 'package:order_management_flutter_app/features/order/model/order_item_model.dart';
import '../../../core/config/api_config.dart';
import '../../../core/utils/api_headers.dart';
import '../model/order_model.dart';

class OrderService {
  final String baseUrl = "${ApiConfig.baseUrl}order";
  final String customerBaseUrl = "${ApiConfig.baseUrl}customer/orders";

  Future<List<OrderModel>> getOrders({
    int page = 0,
    int size = 1000,
    String sort = "createdAt,DESC",
    List<String>? statuses,
  }) async {
    try {
      final headers = await ApiHeaders.getHeaders();

      final url = "$baseUrl?page=$page&size=$size&sort=$sort";

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final allOrders = (data['items'] as List)
            .map((item) => OrderModel.fromMap(item))
            .toList();

        if (statuses != null && statuses.isNotEmpty) {
          // Lọc local theo status
          return allOrders
              .where((order) => statuses.contains(order.status))
              .toList();
        }

        return allOrders;
      } else {
        throw Exception("Failed to load orders: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching orders: $e");
    }
  }


  Future<OrderModel> getOrderById(String id) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl/$id"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return OrderModel.fromMap(json.decode(response.body));
    } else {
      throw Exception("Failed to load order");
    }
  }

  Future<void> rejectOrder(String id) async {
    await _updateOrderStatus(id, "rejection");
  }

  Future<void> markOrderAsReadyToDeliver(String id) async {
    await _updateOrderStatus(id, "ready-to-deliver");
  }

  Future<void> markOrderAsDelivered(String id) async {
    await _updateOrderStatus(id, "delivered");
  }

  Future<void> approveOrder(String id) async {
    await _updateOrderStatus(id, "approval");
  }

  Future<void> _updateOrderStatus(String id, String status) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.put(
      Uri.parse("$baseUrl/$id/$status"),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to update order status to $status");
    }
  }

  Future<void> createStaffOrder(
      int tableNumber, List<OrderItemModel> orderItems) async {
    try {
      final headers = await ApiHeaders.getHeaders();
      final sessionId = SessionController().getRandomSessionId();
      final response = await http.post(
        Uri.parse(customerBaseUrl),
        headers: headers,
        body: json.encode({
          "sessionId":sessionId,
          "tableNumber": tableNumber,
          "orderItems": orderItems.map((item) => item.toJson()).toList(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to create customer order. Status code: ${response.statusCode}");
      }
      print("Customer order created successfully: ${response.body}");
    } catch (e) {
      print("Error creating customer order: $e");
      throw Exception("Failed to create customer order: $e");
    }
  }

  Future<void> createCustomerOrder(
      int tableNumber, List<OrderItemModel> orderItems) async {
    try {
      final sessionId = await SessionController().getSessionId();
      final response = await http.post(
        Uri.parse(customerBaseUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          "sessionId":sessionId,
          "tableNumber": tableNumber,
          "orderItems": orderItems.map((item) => item.toJson()).toList(),
        }),
      );
      print(response);
      if (response.statusCode != 200) {
        throw Exception("Failed to create customer order. Status code: ${response.body}");
      }
      print("Customer order created successfully: ${response.body}");
    } catch (e) {
      print("Error creating customer order: $e");
      throw Exception("Failed to create customer order: $e");
    }
  }

  Future<void> updateCustomerOrder(String id, String sessionId, int tableNumber,
      List<Map<String, dynamic>> orderItems) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.put(
      Uri.parse("$customerBaseUrl/$id"),
      headers: headers,
      body: json.encode({
        "sessionId": sessionId,
        "tableNumber": tableNumber,
        "orderItems": orderItems
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to update customer order");
    }
  }

  Future<List<OrderModel>> getCustomerOrders(String sessionId) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.get(
      Uri.parse("$customerBaseUrl?session-id=$sessionId"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data as List).map((item) => OrderModel.fromMap(item)).toList();
    } else {
      throw Exception("Failed to load orders for sessionId: $sessionId");
    }
  }

  Future<OrderModel> getCustomerOrderById(String id) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.get(
      Uri.parse("$customerBaseUrl/$id"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return OrderModel.fromMap(json.decode(response.body));
    } else {
      throw Exception("Failed to load order with id: $id");
    }
  }
}
