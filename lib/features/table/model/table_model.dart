class TableModel {
  final String id;
  final int number;
  final String description;
  final String status;
  final String floorName;
  final DateTime? openAt;

  //<editor-fold desc="Data Methods">
  const TableModel({
    required this.id,
    required this.number,
    required this.description,
    required this.status,
    required this.floorName,
    this.openAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is TableModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              number == other.number &&
              description == other.description &&
              status == other.status &&
              floorName == other.floorName &&
              openAt == other.openAt);

  @override
  int get hashCode =>
      id.hashCode ^
      number.hashCode ^
      description.hashCode ^
      status.hashCode ^
      floorName.hashCode ^
      openAt.hashCode;

  @override
  String toString() {
    return 'TableModel{' +
        ' id: $id,' +
        ' number: $number,' +
        ' description: $description,' +
        ' status: $status,' +
        ' floorName: $floorName,' +
        ' openAt: $openAt,' +
        '}';
  }

  TableModel copyWith({
    String? id,
    int? number,
    String? description,
    String? status,
    String? floorName,
    DateTime? openAt,
  }) {
    return TableModel(
      id: id ?? this.id,
      number: number ?? this.number,
      description: description ?? this.description,
      status: status ?? this.status,
      floorName: floorName ?? this.floorName,
      openAt: openAt ?? this.openAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'number': this.number,
      'description': this.description,
      'status': this.status,
      'floorName': this.floorName,
      'openAt': this.openAt?.toIso8601String(),
    };
  }

  factory TableModel.fromMap(Map<String, dynamic> map) {
    return TableModel(
      id: map['id'] as String,
      number: map['number'] as int,
      description: map['description'] as String,
      status: map['status'] as String,
      floorName: map['floorName'] as String,
      openAt: map['openAt'] != null ? DateTime.parse(map['openAt']) : null,
    );
  }

//</editor-fold>
}
