import 'package:equatable/equatable.dart';

/// Represents a quote inside the domain layer.
class Quote extends Equatable {
  /// Unique identifier for the quote.
  final String id;

  /// The textual body of the quote.
  final String body;

  /// The author of the quote.
  final String author;

  /// A human-friendly category for grouping.
  final String category;

  /// Tags supplied by the source data.
  final List<String> tags;

  /// When the quote was created in the database.
  final DateTime createdAt;

  const Quote({
    required this.id,
    required this.body,
    required this.author,
    required this.category,
    this.tags = const [],
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, body, author, category, tags, createdAt];
}
