import 'package:flutter/material.dart';
import 'core/constants/route_constants.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/quotes/presentation/pages/quotes_list_page.dart';

class QuoteVaultApp extends StatelessWidget {
  const QuoteVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuoteVault',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: RouteConstants.login,
      routes: {
        RouteConstants.login: (context) => const LoginPage(),
        RouteConstants.register: (context) => const RegisterPage(),
        RouteConstants.forgotPassword: (context) => const ForgotPasswordPage(),
        RouteConstants.quotesList: (context) => const QuotesListPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
