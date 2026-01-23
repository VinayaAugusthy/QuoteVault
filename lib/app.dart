import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'core/constants/route_constants.dart';
import 'core/di/injection_container.dart';
import 'core/services/deep_link_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'core/navigation/main_navigation_page.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/settings/presentation/cubit/settings_state.dart';

class QuoteVaultApp extends StatefulWidget {
  final SettingsState initialSettings;

  const QuoteVaultApp({super.key, required this.initialSettings});

  @override
  State<QuoteVaultApp> createState() => _QuoteVaultAppState();
}

class _QuoteVaultAppState extends State<QuoteVaultApp> {
  final DeepLinkService _deepLinkService = DeepLinkService();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  Uri? _pendingDeepLink;
  bool _deepLinkInitialized = false;

  static const Duration _pendingDeepLinkDelay = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    _checkInitialDeepLink();
  }

  void _initializeDeepLinkService(BuildContext context) {
    if (_deepLinkInitialized) return;
    _deepLinkInitialized = true;

    _deepLinkService.initialize(_navigatorKey);
    // Handle pending deep link if app was opened from terminated state
    if (_pendingDeepLink != null) {
      Future.delayed(_pendingDeepLinkDelay, () {
        _deepLinkService.handleDeepLink(_pendingDeepLink);
      });
    }
  }

  Future<void> _checkInitialDeepLink() async {
    final appLinks = AppLinks();
    final uri = await appLinks.getInitialLink();
    if (uri != null) {
      _pendingDeepLink = uri;
    }
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) =>
              InjectionContainer().authBloc..add(const CheckAuthStatus()),
        ),
        BlocProvider<SettingsCubit>(
          create: (_) => InjectionContainer().settingsCubit(
            initialState: widget.initialSettings,
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Initialize deep link service after BlocProvider is available
          // Use a one-time callback to ensure it only runs once
          if (!_deepLinkInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_deepLinkInitialized) {
                _initializeDeepLinkService(context);
              }
            });
          }

          return BlocListener<AuthBloc, AuthState>(
            listenWhen: (prev, curr) => curr is AuthAuthenticated,
            listener: (context, state) {
              // After login, pull remote settings so they sync across devices.
              context.read<SettingsCubit>().loadSettings();
            },
            child: BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
                return BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    final home = authState is AuthAuthenticated
                        ? MainNavigationPage(userId: authState.user.id)
                        : const LoginPage();

                    return MaterialApp(
                      navigatorKey: _navigatorKey,
                      title: 'QuoteVault',
                      theme: AppTheme.light(settingsState.accentColor),
                      darkTheme: AppTheme.dark(settingsState.accentColor),
                      themeMode: settingsState.themeMode,
                      home: home,
                      routes: {
                        RouteConstants.login: (context) => const LoginPage(),
                        RouteConstants.register: (context) =>
                            const RegisterPage(),
                        RouteConstants.forgotPassword: (context) =>
                            const ForgotPasswordPage(),
                        RouteConstants.resetPassword: (context) =>
                            const ResetPasswordPage(),
                        RouteConstants.quotesList: (context) {
                          final user =
                              Supabase.instance.client.auth.currentUser;
                          if (user == null) {
                            return const LoginPage();
                          }
                          return MainNavigationPage(
                            userId: user.id,
                            initialIndex: 0,
                          );
                        },
                        RouteConstants.favorites: (context) {
                          final user =
                              Supabase.instance.client.auth.currentUser;
                          if (user == null) {
                            return const LoginPage();
                          }
                          return MainNavigationPage(
                            userId: user.id,
                            initialIndex: 1,
                          );
                        },
                        RouteConstants.collections: (context) {
                          final user =
                              Supabase.instance.client.auth.currentUser;
                          if (user == null) {
                            return const LoginPage();
                          }
                          return MainNavigationPage(
                            userId: user.id,
                            initialIndex: 2,
                          );
                        },
                        RouteConstants.settings: (context) {
                          final user =
                              Supabase.instance.client.auth.currentUser;
                          if (user == null) {
                            return const LoginPage();
                          }
                          return MainNavigationPage(
                            userId: user.id,
                            initialIndex: 3,
                          );
                        },
                      },
                      debugShowCheckedModeBanner: false,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
