import '../../domain/entities/collection.dart';

class CollectionModel extends Collection {
  const CollectionModel({
    required super.id,
    required super.name,
    required super.createdAt,
    required super.quoteIds,
  });

  factory CollectionModel.fromMap(Map<String, dynamic> map) {
    return CollectionModel(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      quoteIds:
          (map['quoteIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(growable: false) ??
          const <String>[],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'quoteIds': quoteIds,
    };
  }

  @override
  CollectionModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<String>? quoteIds,
  }) {
    return CollectionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      quoteIds: quoteIds ?? this.quoteIds,
    );
  }
}
