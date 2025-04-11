import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final double price;
  final String description;
  final bool isShown;
  final String? image;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    this.isShown = true,
    this.image,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    bool? isShown,
    String? image,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      isShown: isShown ?? this.isShown,
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'isShown': isShown,
      'image': image,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      description: map['description'] as String,
      isShown: map['isShown'] as bool? ?? true,
      image: map['image'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    description,
    isShown,
    image,
  ];
}
