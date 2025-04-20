import '../../invoice/model/invoice_model.dart';

class ShiftModel {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final String managerName;
  final int totalInvoices;
  final double totalRevenue;
  final List<InvoiceModel> invoices;
  final bool open;

//<editor-fold desc="Data Methods">
  const ShiftModel({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.managerName,
    required this.totalInvoices,
    required this.totalRevenue,
    required this.invoices,
    required this.open,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShiftModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          managerName == other.managerName &&
          totalInvoices == other.totalInvoices &&
          totalRevenue == other.totalRevenue &&
          invoices == other.invoices &&
          open == other.open);

  @override
  int get hashCode =>
      id.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      managerName.hashCode ^
      totalInvoices.hashCode ^
      totalRevenue.hashCode ^
      invoices.hashCode ^
      open.hashCode;

  @override
  String toString() {
    return 'ShiftModel{' +
        ' id: $id,' +
        ' startTime: $startTime,' +
        ' endTime: $endTime,' +
        ' managerName: $managerName,' +
        ' totalInvoices: $totalInvoices,' +
        ' totalRevenue: $totalRevenue,' +
        ' invoices: $invoices,' +
        ' open: $open,' +
        '}';
  }

  ShiftModel copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    String? managerName,
    int? totalInvoices,
    double? totalRevenue,
    List<InvoiceModel>? invoices,
    bool? open,
  }) {
    return ShiftModel(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      managerName: managerName ?? this.managerName,
      totalInvoices: totalInvoices ?? this.totalInvoices,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      invoices: invoices ?? this.invoices,
      open: open ?? this.open,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'startTime': this.startTime,
      'endTime': this.endTime,
      'managerName': this.managerName,
      'totalInvoices': this.totalInvoices,
      'totalRevenue': this.totalRevenue,
      'invoices': this.invoices,
      'open': this.open,
    };
  }

  factory ShiftModel.fromMap(Map<String, dynamic> map) {
    return ShiftModel(
      id: map['id'] as String,
      startTime: DateTime.parse(map['startTime'] ?? ''),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      managerName: map['managerName'] as String,
      totalInvoices: map['totalInvoices'] as int,
      totalRevenue: (map['totalRevenue'] as num).toDouble(),
      invoices: (map['invoices'] as List<dynamic>)
          .map((e) => InvoiceModel.fromMap(e))
          .toList(),
      open: map['open'] as bool,
    );
  }


//</editor-fold>
}