import 'package:flutter/material.dart';

import '../ministry_controller.dart';
import '../models/workflow_models.dart';
import '../widgets/common.dart';

/// Sign in / sign up gate shown before onboarding when the app is running
/// against a real Supabase backend (`SupabaseConfig.isConfigured`) and there
/// is no active session yet. In local-only demo mode this screen never
/// appears — `MinistryController.load()` skips straight to onboarding.
class AuthScreen extends StatefulWidget {
  const AuthScreen({required this.controller, super.key});
  final MinistryController controller;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool signUpMode = false;
  bool submitting = false;
  String? error;
  String? confirmEmailNotice;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  bool get _validEmail => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.text.trim());
  bool get _validPassword => password.text.length >= 6;

  Future<void> _submit() async {
    final c = widget.controller;
    final cloud = c.cloud;
    if (cloud == null || !_validEmail || !_validPassword || submitting) return;
    setState(() {
      submitting = true;
      error = null;
      confirmEmailNotice = null;
    });

    final outcome = signUpMode
        ? await cloud.signUp(
            email: email.text.trim(),
            password: password.text,
            role: UserRole.collector,
            language: c.language,
          )
        : await cloud.signIn(email: email.text.trim(), password: password.text);

    if (!mounted) return;

    if (!outcome.success) {
      setState(() {
        submitting = false;
        error = outcome.message.isNotEmpty ? outcome.message : c.t('authGenericError');
      });
      return;
    }

    if (outcome.needsEmailConfirmation) {
      setState(() {
        submitting = false;
        confirmEmailNotice = c.t('authConfirmEmailNotice');
      });
      return;
    }

    await c.load();
    if (mounted) setState(() => submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Scaffold(
      backgroundColor: appBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              ScreenHeading(title: c.t('authTitle'), subtitle: c.t('authSubtitle')),
              const SizedBox(height: 24),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(c.t('emailLabel'),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    Text(c.t('passwordLabel'),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: password,
                      obscureText: true,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _submit(),
                    ),
                  ],
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error!, style: const TextStyle(color: danger)),
              ],
              if (confirmEmailNotice != null) ...[
                const SizedBox(height: 12),
                Text(confirmEmailNotice!, style: const TextStyle(color: textMuted)),
              ],
              const SizedBox(height: 20),
              PrimaryButton(
                label: signUpMode ? c.t('signUpAction') : c.t('signInAction'),
                onPressed: submitting || !_validEmail || !_validPassword ? null : _submit,
              ),
              const SizedBox(height: 12),
              if (submitting) const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 12),
              TextButton(
                onPressed: submitting
                    ? null
                    : () => setState(() {
                          signUpMode = !signUpMode;
                          error = null;
                          confirmEmailNotice = null;
                        }),
                child: Text(signUpMode ? c.t('authToggleToSignIn') : c.t('authToggleToSignUp')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
