import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/exchange_code_for_session_usecase.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/update_password_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../features/collections/data/datasources/collection_remote_datasource.dart';
import '../../features/collections/data/repositories/collection_repository_impl.dart';
import '../../features/collections/domain/repositories/collection_repository.dart';
import '../../features/collections/domain/usecases/add_quote_to_collection_usecase.dart';
import '../../features/collections/domain/usecases/create_collection_usecase.dart';
import '../../features/collections/domain/usecases/get_collections_usecase.dart';
import '../../features/collections/presentation/bloc/collections_bloc.dart';
import '../../features/quotes/data/datasources/quote_local_datasource.dart';
import '../../features/quotes/data/datasources/quote_remote_datasource.dart';
import '../../features/quotes/data/repositories/quote_repository_impl.dart';
import '../../features/quotes/data/repositories/quote_share_repository_impl.dart';
import '../../features/quotes/domain/repositories/quote_repository.dart';
import '../../features/quotes/domain/repositories/quote_share_repository.dart';
import '../../features/quotes/domain/usecases/get_categories_usecase.dart';
import '../../features/quotes/domain/usecases/get_daily_quote_usecase.dart';
import '../../features/quotes/domain/usecases/get_favorite_quote_ids_usecase.dart';
import '../../features/quotes/domain/usecases/get_favorite_quotes_usecase.dart';
import '../../features/quotes/domain/usecases/get_quotes_by_ids_usecase.dart';
import '../../features/quotes/domain/usecases/get_quotes_usecase.dart';
import '../../features/quotes/domain/usecases/toggle_favorite_usecase.dart';
import '../../features/quotes/presentation/bloc/quotes_bloc.dart';
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/datasources/settings_remote_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../features/settings/presentation/cubit/settings_state.dart';
import '../services/notification_service.dart';
import '../services/daily_quote_service.dart';

class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  // Supabase Client
  SupabaseClient get supabaseClient => Supabase.instance.client;

  // Data Sources
  AuthRemoteDataSource get authRemoteDataSource =>
      AuthRemoteDataSourceImpl(supabaseClient: supabaseClient);

  SettingsLocalDataSource get settingsLocalDataSource =>
      SettingsLocalDataSourceImpl();

  SettingsRemoteDataSource get settingsRemoteDataSource =>
      SettingsRemoteDataSourceImpl(supabaseClient: supabaseClient);

  // Repositories
  AuthRepository get authRepository =>
      AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);

  SettingsRepository get settingsRepository => SettingsRepositoryImpl(
    localDataSource: settingsLocalDataSource,
    remoteDataSource: settingsRemoteDataSource,
    supabaseClient: supabaseClient,
  );

  QuoteRemoteDataSource get quoteRemoteDataSource =>
      QuoteRemoteDataSourceImpl(supabaseClient: supabaseClient);

  QuoteLocalDataSource get quoteLocalDataSource => QuoteLocalDataSource();

  DailyQuoteService get dailyQuoteService => DailyQuoteService(
    remoteDataSource: quoteRemoteDataSource,
    localDataSource: quoteLocalDataSource,
  );

  NotificationService get notificationService =>
      NotificationService(dailyQuoteService: dailyQuoteService);

  QuoteRepository get quoteRepository => QuoteRepositoryImpl(
    remoteDataSource: quoteRemoteDataSource,
    dailyQuoteService: dailyQuoteService,
  );

  QuoteShareRepository get quoteShareRepository => QuoteShareRepositoryImpl();

  // Use Cases
  LoginUseCase get loginUseCase => LoginUseCase(authRepository);
  RegisterUseCase get registerUseCase => RegisterUseCase(authRepository);
  LogoutUseCase get logoutUseCase => LogoutUseCase(authRepository);
  ForgotPasswordUseCase get forgotPasswordUseCase =>
      ForgotPasswordUseCase(authRepository);
  GetCurrentUserUseCase get getCurrentUserUseCase =>
      GetCurrentUserUseCase(authRepository);
  UpdatePasswordUseCase get updatePasswordUseCase =>
      UpdatePasswordUseCase(authRepository);
  ExchangeCodeForSessionUseCase get exchangeCodeForSessionUseCase =>
      ExchangeCodeForSessionUseCase(authRepository);

  GetQuotesUseCase get getQuotesUseCase => GetQuotesUseCase(quoteRepository);
  GetCategoriesUseCase get getCategoriesUseCase =>
      GetCategoriesUseCase(quoteRepository);
  GetDailyQuoteUseCase get getDailyQuoteUseCase =>
      GetDailyQuoteUseCase(quoteRepository);
  GetFavoriteQuoteIdsUseCase get getFavoriteQuoteIdsUseCase =>
      GetFavoriteQuoteIdsUseCase(quoteRepository);
  GetFavoriteQuotesUseCase get getFavoriteQuotesUseCase =>
      GetFavoriteQuotesUseCase(quoteRepository);
  ToggleFavoriteUseCase get toggleFavoriteUseCase =>
      ToggleFavoriteUseCase(quoteRepository);

  GetQuotesByIdsUseCase get getQuotesByIdsUseCase =>
      GetQuotesByIdsUseCase(quoteRepository);

  // Collections
  CollectionRemoteDataSource get collectionRemoteDataSource =>
      CollectionRemoteDataSourceImpl(supabaseClient: supabaseClient);

  CollectionRepository get collectionRepository =>
      CollectionRepositoryImpl(remoteDataSource: collectionRemoteDataSource);

  GetCollectionsUseCase get getCollectionsUseCase =>
      GetCollectionsUseCase(collectionRepository);

  CreateCollectionUseCase get createCollectionUseCase =>
      CreateCollectionUseCase(collectionRepository);

  AddQuoteToCollectionUseCase get addQuoteToCollectionUseCase =>
      AddQuoteToCollectionUseCase(collectionRepository);

  // BLoCs
  AuthBloc get authBloc => AuthBloc(
    loginUseCase: loginUseCase,
    registerUseCase: registerUseCase,
    logoutUseCase: logoutUseCase,
    forgotPasswordUseCase: forgotPasswordUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
    updatePasswordUseCase: updatePasswordUseCase,
    exchangeCodeForSessionUseCase: exchangeCodeForSessionUseCase,
  );

  SettingsCubit settingsCubit({SettingsState? initialState}) => SettingsCubit(
    settingsRepository: settingsRepository,
    initialState: initialState,
  );

  QuotesBloc quotesBloc({required String userId}) => QuotesBloc(
    getQuotesUseCase: getQuotesUseCase,
    getCategoriesUseCase: getCategoriesUseCase,
    getDailyQuoteUseCase: getDailyQuoteUseCase,
    getFavoriteQuoteIdsUseCase: getFavoriteQuoteIdsUseCase,
    toggleFavoriteUseCase: toggleFavoriteUseCase,
    userId: userId,
  );

  FavoritesBloc favoritesBloc({required String userId}) => FavoritesBloc(
    getFavoriteQuotesUseCase: getFavoriteQuotesUseCase,
    toggleFavoriteUseCase: toggleFavoriteUseCase,
    userId: userId,
  );

  CollectionsBloc collectionsBloc({required String userId}) => CollectionsBloc(
    getCollectionsUseCase: getCollectionsUseCase,
    createCollectionUseCase: createCollectionUseCase,
    addQuoteToCollectionUseCase: addQuoteToCollectionUseCase,
    getQuotesByIdsUseCase: getQuotesByIdsUseCase,
    userId: userId,
  );
}
