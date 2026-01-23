import '../../features/quotes/data/datasources/quote_local_datasource.dart';
import '../../features/quotes/data/datasources/quote_remote_datasource.dart';
import '../../features/quotes/data/models/quote_model.dart';
import '../../features/quotes/domain/entities/quote.dart';

/// Selects a deterministic "Quote of the Day" and caches it locally so the
/// same quote is shown for the entire calendar day on the device.
///
/// Optional hook: [preferRemoteDailyQuote] can be enabled later if you add a
/// server-side daily quote endpoint. For now, deterministic selection is local.
class DailyQuoteService {
  static final DateTime _seed = DateTime(2024, 1, 1);

  final QuoteRemoteDataSource remoteDataSource;
  final QuoteLocalDataSource localDataSource;
  final bool preferRemoteDailyQuote;

  const DailyQuoteService({
    required this.remoteDataSource,
    required this.localDataSource,
    this.preferRemoteDailyQuote = false,
  });

  /// Returns the quote for "today" (device local calendar day).
  /// Uses SharedPreferences cache to ensure stability throughout the day.
  Future<Quote?> getDailyQuote({DateTime? now}) async {
    final today = _dateOnly(now ?? DateTime.now());
    final cacheKey = _dateKey(today);

    final cached = await localDataSource.getCachedDailyQuote(dateKey: cacheKey);
    if (cached != null) return cached;

    QuoteModel? selected;

    if (preferRemoteDailyQuote) {
      try {
        selected = await remoteDataSource.fetchDailyQuote();
      } catch (_) {
        // Ignore remote errors; fall back to local deterministic selection.
      }
    }

    selected ??= await _selectDeterministicallyForDate(today);
    if (selected == null) return null;

    await localDataSource.cacheDailyQuote(dateKey: cacheKey, quote: selected);
    return selected;
  }

  /// Pre-computes quotes for a date range using a single remote fetch of all
  /// candidate quotes. This is used for scheduling notifications ahead of time.
  Future<List<Quote>> getQuotesForNextDays({
    DateTime? start,
    int days = 30,
  }) async {
    final startDate = _dateOnly(start ?? DateTime.now());
    if (days <= 0) return const <Quote>[];

    final all = await remoteDataSource.fetchAllQuotesForDailyQuote();
    if (all.isEmpty) return const <Quote>[];

    final results = <Quote>[];
    for (var i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final picked = _pickFromList(all, date);
      if (picked != null) results.add(picked);
    }
    return results;
  }

  Future<QuoteModel?> _selectDeterministicallyForDate(DateTime date) async {
    final all = await remoteDataSource.fetchAllQuotesForDailyQuote();
    return _pickFromList(all, date);
  }

  QuoteModel? _pickFromList(List<QuoteModel> quotes, DateTime date) {
    if (quotes.isEmpty) return null;

    final dayOffset = _dateOnly(date).difference(_dateOnly(_seed)).inDays;
    final index = dayOffset % quotes.length;
    return quotes[index];
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static String _dateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
