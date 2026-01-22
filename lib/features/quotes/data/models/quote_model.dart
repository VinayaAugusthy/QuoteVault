import '../../domain/entities/quote.dart';

class QuoteModel extends Quote {
  const QuoteModel({
    required super.id,
    required super.body,
    required super.author,
    required super.category,
    super.tags,
    required super.createdAt,
  });

  factory QuoteModel.fromMap(Map<String, dynamic> map) {
    final tagsSource = map['tags'];
    final tags = <String>[];

    if (tagsSource is List) {
      for (final tag in tagsSource) {
        if (tag is String && tag.isNotEmpty) {
          tags.add(tag);
        }
      }
    }

    final createdAt = map['created_at'];

    DateTime parseCreatedAt() {
      if (createdAt is DateTime) return createdAt;
      if (createdAt is String && createdAt.isNotEmpty) {
        return DateTime.parse(createdAt).toUtc();
      }
      return DateTime.now().toUtc();
    }

    return QuoteModel(
      id: map['id'] as String,
      body: (map['body'] ?? '') as String,
      author: (map['author'] ?? 'Unknown') as String,
      category: (map['category'] ?? 'General') as String,
      tags: tags,
      createdAt: parseCreatedAt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'body': body,
      'author': author,
      'category': category,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
