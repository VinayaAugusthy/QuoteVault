import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/route_constants.dart';
import '../utils/snackbar_utils.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri?>? _linkSubscription;
  GlobalKey<NavigatorState>? _navigatorKey;
  bool _initialized = false;

  static const Duration _navigationDelay = Duration(milliseconds: 300);
  static const Duration _errorDelay = Duration(milliseconds: 500);

  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    if (_initialized) return;
    _initialized = true;
    _navigatorKey = navigatorKey;

    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) => handleDeepLink(uri),
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );
  }

  /// Public method to handle deep links (can be called externally)
  void handleDeepLink(Uri? uri) {
    _handleDeepLink(uri);
  }

  void _handleDeepLink(Uri? uri) {
    if (uri == null || _navigatorKey?.currentState == null) return;

    debugPrint('Deep link received: $uri');

    // Handle password reset deep link
    if (uri.scheme == 'quotevault' && uri.host == 'reset-password') {
      // Check for error parameters first
      final error = _getParameter(uri, 'error');
      if (error != null) {
        _handleResetPasswordError(
          error,
          _getParameter(uri, 'error_code'),
          _getParameter(uri, 'error_description'),
        );
        return;
      }

      // Extract code parameter (Supabase sends 'code' for password reset)
      final code = uri.queryParameters['code'];
      if (code != null && code.isNotEmpty) {
        _handleCodeExchange(code);
      } else {
        _handleInvalidResetLink();
      }
    }
  }

  String? _getParameter(Uri uri, String key) {
    return uri.queryParameters[key] ??
        (uri.fragment.isNotEmpty
            ? Uri.splitQueryString(uri.fragment)[key]
            : null);
  }

  void _handleResetPasswordError(
    String error,
    String? errorCode,
    String? errorDescription,
  ) {
    _navigatorKey!.currentState!.pushNamedAndRemoveUntil(
      RouteConstants.forgotPassword,
      (route) => false,
    );

    Future.delayed(_errorDelay, () {
      final context = _navigatorKey?.currentState?.context;
      if (context != null) {
        String errorMessage = 'Password reset link is invalid or has expired.';
        if (errorCode == 'otp_expired') {
          errorMessage =
              'This password reset link has expired. Please request a new one.';
        } else if (errorDescription != null) {
          errorMessage = Uri.decodeComponent(
            errorDescription.replaceAll('+', ' '),
          );
        }
        SnackbarUtils.showError(context, errorMessage);
      }
    });
  }

  void _handleInvalidResetLink() {
    _navigatorKey!.currentState!.pushNamedAndRemoveUntil(
      RouteConstants.forgotPassword,
      (route) => false,
    );
    Future.delayed(_errorDelay, () {
      final context = _navigatorKey?.currentState?.context;
      if (context != null) {
        SnackbarUtils.showError(
          context,
          'Invalid password reset link. Please request a new one.',
        );
      }
    });
  }

  void _handleCodeExchange(String code) {
    final context = _navigatorKey?.currentState?.context;
    if (context == null) {
      debugPrint('No navigator context available for deep link handling');
      return;
    }

    final authBloc = context.read<AuthBloc>();
    StreamSubscription? subscription;
    bool handled = false;

    subscription = authBloc.stream.listen((state) {
      if (state is CodeExchangedForSession && !handled) {
        handled = true;
        subscription?.cancel();
        Future.delayed(_navigationDelay, () {
          _navigatorKey?.currentState?.pushNamedAndRemoveUntil(
            RouteConstants.resetPassword,
            (route) => false,
          );
        });
      } else if (state is AuthError && !handled) {
        final errorMessage = state.message;
        if (_isCodeExchangeError(errorMessage)) {
          handled = true;
          subscription?.cancel();
          _navigatorKey?.currentState?.pushNamedAndRemoveUntil(
            RouteConstants.forgotPassword,
            (route) => false,
          );
          Future.delayed(_errorDelay, () {
            final errorContext = _navigatorKey?.currentState?.context;
            if (errorContext != null) {
              SnackbarUtils.showError(errorContext, errorMessage);
            }
          });
        }
      }
    });

    authBloc.add(ExchangeCodeForSessionRequested(code: code));
  }

  bool _isCodeExchangeError(String errorMessage) {
    final lowerMessage = errorMessage.toLowerCase();
    return lowerMessage.contains('exchange') ||
        lowerMessage.contains('code') ||
        lowerMessage.contains('session') ||
        lowerMessage.contains('invalid') ||
        lowerMessage.contains('expired') ||
        lowerMessage.contains('flow state');
  }

  void dispose() {
    _linkSubscription?.cancel();
    _navigatorKey = null;
  }
}
