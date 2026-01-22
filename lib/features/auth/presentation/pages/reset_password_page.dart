import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/app_logo_header.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        UpdatePasswordRequested(newPassword: _passwordController.text),
      );
    }
  }

  void _navigateToLogin() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteConstants.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          SnackbarUtils.showError(context, state.message);
        } else if (state is PasswordUpdated) {
          SnackbarUtils.showSuccess(
            context,
            'Password updated successfully. Please login with your new password.',
          );
          _navigateToLogin();
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
                      // Title
                      Text(
                        AppStrings.resetPassword,
                        style: const TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12.0),
                      // Description
                      Text(
                        AppStrings.resetPasswordDescription,
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40.0),
                      // New Password field
                      AuthPasswordField(
                        label: AppStrings.newPassword,
                        controller: _passwordController,
                        placeholder: AppStrings.newPasswordPlaceholder,
                        isVisible: _isPasswordVisible,
                        onToggleVisibility: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24.0),
                      // Confirm New Password field
                      AuthPasswordField(
                        label: AppStrings.confirmNewPassword,
                        controller: _confirmPasswordController,
                        placeholder: AppStrings.confirmNewPasswordPlaceholder,
                        isVisible: _isConfirmPasswordVisible,
                        onToggleVisibility: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40.0),
                      // Reset Password button
                      PrimaryButton(
                        text: AppStrings.resetPasswordButton,
                        onPressed: state is AuthLoading
                            ? null
                            : _handleResetPassword,
                        isLoading: state is AuthLoading,
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
