import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/auth_bloc.dart';
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
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  // Navigate to forgot password page
  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, RouteConstants.forgotPassword);
  }

  void _navigateToRegister() {
    Navigator.pushReplacementNamed(context, RouteConstants.register);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          SnackbarUtils.showError(context, state.message);
        } else if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, RouteConstants.quotesList);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 48.0,
            ),
            child: Form(
              key: _formKey,
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return Column(
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
                      PrimaryButton(
                        text: AppStrings.login,
                        onPressed: state is AuthLoading ? null : _handleLogin,
                        isLoading: state is AuthLoading,
                        icon: state is AuthLoading
                            ? null
                            : const Icon(Icons.arrow_forward, size: 20.0),
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
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
