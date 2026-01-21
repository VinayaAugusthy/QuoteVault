import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class QuotesListPage extends StatelessWidget {
  const QuotesListPage({super.key});

  void _handleLogout(BuildContext context) {
    context.read<AuthBloc>().add(const LogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteConstants.login,
            (route) => false,
          );
        } else if (state is AuthError) {
          SnackbarUtils.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(
          title: const Text(AppStrings.appName),
          backgroundColor: AppColors.backgroundWhite,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.primaryTeal),
              onPressed: () => _handleLogout(context),
              tooltip: AppStrings.logout,
            ),
          ],
        ),
        body: const Center(child: Text('Quotes List Page')),
      ),
    );
  }
}
