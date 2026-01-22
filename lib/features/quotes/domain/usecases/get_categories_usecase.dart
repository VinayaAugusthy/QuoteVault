import '../repositories/quote_repository.dart';

class GetCategoriesUseCase {
  final QuoteRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<String>> call() {
    return repository.getCategories();
  }
}
