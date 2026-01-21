import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/widgets/primary_button.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendResetLink() {
    if (_formKey.currentState!.validate()) {
      // TODO: Dispatch ForgotPasswordRequested event to AuthBloc
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, RouteConstants.login);
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
                const SizedBox(height: 40.0),
                // Large teal rounded rectangle with icon
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  padding: const EdgeInsets.all(40.0),
                  decoration: BoxDecoration(
                    color: AppColors.lightTeal,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Center(
                    child: Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryTeal,
                        shape: BoxShape.circle,
                      ),
                      child: CustomPaint(
                        painter: _ListIconPainter(),
                        size: const Size(80.0, 80.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40.0),
                // Forgot Password heading
                Text(
                  AppStrings.forgotPassword,
                  style: const TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                // Description text
                Text(
                  AppStrings.forgotPasswordDescription,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40.0),
                // Email field
                AuthTextField(
                  label: AppStrings.emailAddress,
                  controller: _emailController,
                  placeholder: AppStrings.emailPlaceholder,
                  keyboardType: TextInputType.emailAddress,
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
                const SizedBox(height: 32.0),
                // Send Reset Link button
                // TODO: Listen to AuthBloc state changes
                // Show loading indicator when AuthState is AuthLoading
                // Show success message on AuthSuccess
                // Show error message on AuthFailure
                PrimaryButton(
                  text: AppStrings.sendResetLink,
                  onPressed: _handleSendResetLink,
                ),
                const SizedBox(height: 32.0),
                // Footer with back to login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.rememberedIt,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    GestureDetector(
                      onTap: _navigateToLogin,
                      child: const Text(
                        AppStrings.backToLogin,
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

// Custom painter for the list icon (three horizontal lines: top and bottom dashed, middle solid)
class _ListIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.backgroundWhite
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashPaint = Paint()
      ..color = AppColors.backgroundWhite
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final lineLength = size.width * 0.6;
    final startX = (size.width - lineLength) / 2;
    final endX = startX + lineLength;

    // Top dashed line
    _drawDashedLine(
      canvas,
      Offset(startX, centerY - 16.0),
      Offset(endX, centerY - 16.0),
      dashPaint,
    );

    // Middle solid line
    canvas.drawLine(Offset(startX, centerY), Offset(endX, centerY), paint);

    // Bottom dashed line
    _drawDashedLine(
      canvas,
      Offset(startX, centerY + 16.0),
      Offset(endX, centerY + 16.0),
      dashPaint,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 8.0;
    const dashSpace = 4.0;
    double startX = start.dx;

    while (startX < end.dx) {
      canvas.drawLine(
        Offset(startX, start.dy),
        Offset(startX + dashWidth, start.dy),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
