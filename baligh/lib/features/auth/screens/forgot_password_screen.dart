import 'package:flutter/material.dart';
import 'package:baligh/core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _isSent = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.forgotPassword)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _isSent 
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mark_email_read_outlined, size: 100, color: Colors.green),
                const SizedBox(height: 32),
                const Text(
                  'Email Sent!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'We have sent a password recovery link to your email address.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 48),
                AppButton(
                  text: 'Back to Login',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Reset Password',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Enter your email address and we will send you a link to reset your password.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 48),
                AppTextField(
                  label: l10n.email,
                  hint: 'email@example.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 40),
                AppButton(
                  text: 'Send Reset Link',
                  onPressed: () {
                    setState(() => _isSent = true);
                  },
                ),
              ],
            ),
      ),
    );
  }
}
