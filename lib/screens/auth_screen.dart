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

  void _showLanguageSelector() {
    final c = widget.controller;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(c.t('chooseLanguage'),
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 8),
            for (final option in const [
              ('en', 'English'),
              ('hi', 'हिन्दी'),
              ('mr', 'मराठी'),
              ('kn', 'ಕನ್ನಡ'),
              ('te', 'తెలుగు'),
              ('bn', 'বাংলা'),
            ])
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: Icon(
                  c.language == option.$1
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: c.language == option.$1 ? primary : textMuted,
                ),
                title: Text(option.$2,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                onTap: () {
                  c.setLanguage(option.$1);
                  Navigator.pop(sheetContext);
                },
              ),
          ]),
        ),
      ),
    );
  }

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

  InputDecoration _fieldDecoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Stack(children: [
                      Semantics(
                        image: true,
                        label: 'Kabadiwala Connect logo',
                        child: Image.asset(
                          'assets/branding/kabadiwala_connect_logo.png',
                          width: 96,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      Positioned(
                        right: -8,
                        top: -8,
                        child: IconButton(
                          tooltip: c.t('language'),
                          onPressed: _showLanguageSelector,
                          icon: const Icon(Icons.language_rounded, color: textMuted),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(c.t('authTitle'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w500, color: textMain)),
                        const SizedBox(height: 8),
                        Text(c.t('authSubtitle'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, color: textMuted)),
                        const SizedBox(height: 28),
                        TextField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          decoration: _fieldDecoration(c.t('emailLabel')),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: password,
                          obscureText: true,
                          decoration: _fieldDecoration(c.t('passwordLabel')),
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _submit(),
                        ),
                        if (error != null) ...[
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(error!, style: const TextStyle(color: danger, fontSize: 13)),
                          ),
                        ],
                        if (confirmEmailNotice != null) ...[
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(confirmEmailNotice!,
                                style: const TextStyle(color: textMuted, fontSize: 13)),
                          ),
                        ],
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: submitting
                                  ? null
                                  : () => setState(() {
                                        signUpMode = !signUpMode;
                                        error = null;
                                        confirmEmailNotice = null;
                                      }),
                              child: Text(
                                signUpMode ? c.t('authToggleToSignIn') : c.t('authToggleToSignUp'),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            FilledButton(
                              onPressed:
                                  submitting || !_validEmail || !_validPassword ? null : _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24)),
                              ),
                              child: submitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(signUpMode ? c.t('signUpAction') : c.t('signInAction')),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
