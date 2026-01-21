import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/widgets/primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/app_logo_header.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Password visibility toggle
  bool _isPasswordVisible = false;

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // TODO: Dispatch LoginRequested event to AuthBloc
    }
  }

  // Navigate to forgot password page
  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, RouteConstants.forgotPassword);
  }

  // Navigate to register page
  void _navigateToRegister() {
    Navigator.pushNamed(context, RouteConstants.register);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppLogoHeader(),
                const SizedBox(height: 20.0),
                // Welcome Back title
                Text(
                  AppStrings.welcomeBack,
                  style: const TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12.0),
                // Sign in subtitle
                Text(
                  AppStrings.signInToAccount,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40.0),
                // Email field with @ icon
                AuthTextField(
                  label: AppStrings.emailAddress,
                  controller: _emailController,
                  placeholder: AppStrings.emailPlaceholder,
                  keyboardType: TextInputType.emailAddress,
                  suffixIcon: const Icon(
                    Icons.alternate_email,
                    color: AppColors.iconGrey,
                    size: 20.0,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                // Password field
                AuthPasswordField(
                  label: AppStrings.password,
                  controller: _passwordController,
                  placeholder: AppStrings.passwordPlaceholderLogin,
                  isVisible: _isPasswordVisible,
                  onToggleVisibility: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12.0),
                // Forgot Password link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _navigateToForgotPassword,
                    child: Text(
                      AppStrings.forgotPassword,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),
                // Login button
                // TODO: Listen to AuthBloc state changes
                // Show loading indicator when AuthState is AuthLoading
                // Navigate to home on AuthSuccess
                // Show error message on AuthFailure
                PrimaryButton(
                  text: AppStrings.login,
                  onPressed: _handleLogin,
                  icon: const Icon(Icons.arrow_forward, size: 20.0),
                ),
                const SizedBox(height: 32.0),
                // Footer with register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.dontHaveAccount,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    GestureDetector(
                      onTap: _navigateToRegister,
                      child: const Text(
                        AppStrings.joinQuoteVault,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
