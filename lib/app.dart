import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'core/constants/route_constants.dart';
import 'core/di/injection_container.dart';
import 'core/services/deep_link_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'core/navigation/main_navigation_page.dart';

class QuoteVaultApp extends StatefulWidget {
  const QuoteVaultApp({super.key});

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

          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final home = state is AuthAuthenticated
                  ? MainNavigationPage(userId: state.user.id)
                  : const LoginPage();

              return MaterialApp(
                navigatorKey: _navigatorKey,
                title: 'QuoteVault',
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.deepPurple,
                  ),
                  useMaterial3: true,
                ),
                home: home,
                routes: {
                  RouteConstants.login: (context) => const LoginPage(),
                  RouteConstants.register: (context) => const RegisterPage(),
                  RouteConstants.forgotPassword: (context) =>
                      const ForgotPasswordPage(),
                  RouteConstants.resetPassword: (context) =>
                      const ResetPasswordPage(),
                  RouteConstants.quotesList: (context) {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user == null) {
                      return const LoginPage();
                    }
                    return MainNavigationPage(userId: user.id, initialIndex: 0);
                  },
                  RouteConstants.favorites: (context) {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user == null) {
                      return const LoginPage();
                    }
                    return MainNavigationPage(userId: user.id, initialIndex: 1);
                  },
                  RouteConstants.collections: (context) {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user == null) {
                      return const LoginPage();
                    }
                    return MainNavigationPage(userId: user.id, initialIndex: 2);
                  },
                  RouteConstants.settings: (context) {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user == null) {
                      return const LoginPage();
                    }
                    return MainNavigationPage(userId: user.id, initialIndex: 3);
                  },
                },
                debugShowCheckedModeBanner: false,
              );
            },
          );
        },
      ),
    );
  }
}
