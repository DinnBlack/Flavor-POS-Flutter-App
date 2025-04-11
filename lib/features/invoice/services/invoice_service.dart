  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import '../../../core/config/api_config.dart';
  import '../../../core/utils/api_headers.dart';
  import '../model/invoice_model.dart';

  class InvoiceService {
    final String baseUrl = "${ApiConfig.baseUrl}invoice";

    // GET: Danh sách hóa đơn
    Future<List<InvoiceModel>> getInvoices({
      int page = 0,
      int size = 1000,
      String sort = "createdAt,DESC",
      List<String> filters = const [],
    }) async {
      final headers = await ApiHeaders.getHeaders();

      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        'page': '$page',
        'size': '$size',
        'sort': sort,
        if (filters.isNotEmpty) 'filter': filters,
      });

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<InvoiceModel> invoices = (data['items'] as List)
            .map((item) => InvoiceModel.fromMap(item))
            .toList();
        return invoices;
      } else {
        throw Exception("Failed to load invoices");
      }
    }

    // GET: Chi tiết hóa đơn theo ID
    Future<InvoiceModel> getInvoiceById(String id) async {
      final headers = await ApiHeaders.getHeaders();

      final response = await http.get(
        Uri.parse("$baseUrl/$id"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return InvoiceModel.fromMap(json.decode(response.body));
      } else {
        throw Exception("Failed to load invoice");
      }
    }

    // POST: Tạo hóa đơn mới
    Future<InvoiceModel> createInvoice({
      required String orderId,
      required String paymentMethod,
      required double amountGiven,
    }) async {
      final headers = await ApiHeaders.getHeaders();

      print(orderId);
      print(paymentMethod);
      print(amountGiven);

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode({
          "orderId": orderId,
          "paymentMethod": paymentMethod,
          "amountGiven": amountGiven,
        }),
      );

      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        return InvoiceModel.fromMap(json.decode(response.body));
      } else {
        throw Exception("Failed to create invoice");
      }
    }
  }
