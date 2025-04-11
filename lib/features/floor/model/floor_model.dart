class FloorModel {
  final String id;
  final String name;

//<editor-fold desc="Data Methods">
  const FloorModel({
    required this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FloorModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name);

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'FloorModel{' + ' id: $id,' + ' name: $name,' + '}';
  }

  FloorModel copyWith({
    String? id,
    String? name,
  }) {
    return FloorModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
    };
  }

  factory FloorModel.fromMap(Map<String, dynamic> map) {
    return FloorModel(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }

//</editor-fold>
}