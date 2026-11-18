import 'package:material_ui/material_ui.dart';

import '../core/app_routes.dart';
import '../core/validators.dart';
import '../services/auth_service.dart';
import '../widgets/app_text_field.dart';
import '../widgets/feedback.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await AuthService.instance.login(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
    } on AuthException catch (e) {
      if (mounted) showMessage(context, e.message, isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 72,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Meu Estoque',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const Text(
                      'Entre para controlar seus produtos',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      controller: _emailCtrl,
                      label: 'E-mail',
                      icon: Icons.alternate_email,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    PasswordField(
                      controller: _passwordCtrl,
                      validator: Validators.password,
                      onSubmitted: _signIn,
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _busy ? null : _signIn,
                      child: _busy
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Entrar'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.register),
                      child: const Text('Ainda não tem conta? Criar conta'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
