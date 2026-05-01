import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:baligh/core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.register)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Join the Baligh Community',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Start reporting and improving your city today.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            const AppTextField(
              label: 'Full Name',
              hint: 'Mohamed Lemine',
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: l10n.email,
              hint: 'email@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            const AppTextField(
              label: 'Phone Number',
              hint: '+222 ••••••••',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: l10n.password,
              hint: '••••••••',
              isPassword: true,
            ),
            const SizedBox(height: 20),
            const AppTextField(
              label: 'Confirm Password',
              hint: '••••••••',
              isPassword: true,
            ),
            const SizedBox(height: 40),
            AppButton(
              text: l10n.register,
              onPressed: () => context.go('/home'),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?"),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(l10n.login),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
