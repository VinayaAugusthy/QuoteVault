import 'package:flutter/material.dart';
import 'package:quote_vault/core/constants/app_strings.dart';

class CreateQuotePage extends StatelessWidget {
  const CreateQuotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text(AppStrings.createQuote)));
  }
}
