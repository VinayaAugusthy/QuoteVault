import 'package:equatable/equatable.dart';

class Collection extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<String> quoteIds;

  const Collection({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.quoteIds,
  });

  Collection copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<String>? quoteIds,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      quoteIds: quoteIds ?? this.quoteIds,
    );
  }

  @override
  List<Object?> get props => [id, name, createdAt, quoteIds];
}
