import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:supabase/supabase.dart';

const _categoryMap = {
  'inspiration': 'Inspiration',
  'motivational': 'Motivation',
  'motivation': 'Motivation',
  'success': 'Success',
  'wisdom': 'Wisdom',
  'mindset': 'Mindset',
  'life': 'Life',
  'learning': 'Learning',
};

void main() async {
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final supabaseKey =
      Platform.environment['SUPABASE_SERVICE_ROLE_KEY'] ??
      Platform.environment['SUPABASE_KEY'];
  final favqsToken = Platform.environment['FAVQS_API_TOKEN'];

  if (supabaseUrl == null ||
      supabaseKey == null ||
      favqsToken == null ||
      favqsToken.isEmpty) {
    stderr.writeln('Missing environment variables.');
    stderr.writeln(
      'Set SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY (or SUPABASE_KEY) and FAVQS_API_TOKEN.',
    );
    exit(1);
  }

  final client = SupabaseClient(supabaseUrl, supabaseKey);
  final quotes = await _fetchFavqsQuotes(favqsToken, limit: 200);

  if (quotes.isEmpty) {
    stderr.writeln('No quotes were fetched from FavQs. Aborting.');
    exit(1);
  }

  stdout.writeln('Seeding ${quotes.length} quotes into Supabase...');

  final payload = quotes.map(_mapToPayload).toList();
  const batchSize = 40;

  for (var i = 0; i < payload.length; i += batchSize) {
    final chunk = payload.sublist(i, min(i + batchSize, payload.length));
    try {
      await client.from('quotes').upsert(chunk, onConflict: 'external_id');
    } on PostgrestException catch (e) {
      stderr.writeln('Failed to insert chunk: ${e.message}');
      exit(1);
    } catch (e) {
      stderr.writeln('Failed to insert chunk: ${e.toString()}');
      exit(1);
    }
  }

  stdout.writeln('Seeding completed successfully.');
}

Map<String, dynamic> _mapToPayload(Map<String, dynamic> data) {
  final tags =
      (data['tags'] as List<dynamic>?)
          ?.whereType<String>()
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .map((tag) => tag.toLowerCase())
          .toList() ??
      [];

  return {
    'external_id': 'favqs_${data['id']}',
    'body': data['body'] ?? '',
    'author': data['author'] ?? 'Unknown',
    'category': _deriveCategory(tags),
    'tags': tags,
    'created_at': DateTime.now().toUtc().toIso8601String(),
  };
}

String _deriveCategory(List<String> tags) {
  for (final tag in tags) {
    final key = tag.toLowerCase();
    if (_categoryMap.containsKey(key)) {
      return _categoryMap[key]!;
    }
  }
  return 'General';
}

Future<List<Map<String, dynamic>>> _fetchFavqsQuotes(
  String token, {
  int limit = 100,
}) async {
  final quotes = <Map<String, dynamic>>[];
  var page = 1;

  while (quotes.length < limit) {
    final response = await http.get(
      Uri.parse('https://favqs.com/api/quotes?page=$page'),
      headers: {
        'Authorization': 'Token token="$token"',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'FavQs API returned ${response.statusCode}: ${response.reasonPhrase}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final pageQuotes =
        (body['quotes'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>()
            .where((quote) => quote['body'] != null && quote['author'] != null)
            .toList() ??
        [];

    if (pageQuotes.isEmpty) break;

    quotes.addAll(pageQuotes);

    final lastPageValue = body['last_page'];
    int lastPage;
    if (lastPageValue is bool) {
      lastPage = lastPageValue ? page : page + 1;
    } else if (lastPageValue is int) {
      lastPage = lastPageValue;
    } else {
      lastPage = page;
    }
    if (page >= lastPage) break;

    page++;
  }

  return quotes.take(limit).toList();
}
