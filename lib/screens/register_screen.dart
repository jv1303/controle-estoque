import 'package:material_ui/material_ui.dart';

import '../core/app_routes.dart';
import '../core/validators.dart';
import '../services/auth_service.dart';
import '../widgets/app_text_field.dart';
import '../widgets/feedback.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_nameCtrl, _emailCtrl, _passwordCtrl, _confirmCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validateConfirm(String? value) {
    if (value != _passwordCtrl.text) {
      return 'As duas senhas precisam ser iguais';
    }
    return null;
  }

  Future<void> _createAccount() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await AuthService.instance.register(
        name: _nameCtrl.text,
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
    return Scaffold(
      appBar: AppBar(title: const Text('Nova conta')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            AppTextField(
              controller: _nameCtrl,
              label: 'Nome completo',
              icon: Icons.person_outline,
              validator: (v) => Validators.notEmpty(v, field: 'O nome'),
            ),
            AppTextField(
              controller: _emailCtrl,
              label: 'Seu e-mail',
              icon: Icons.alternate_email,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
            PasswordField(
              controller: _passwordCtrl,
              validator: Validators.password,
            ),
            PasswordField(
              controller: _confirmCtrl,
              label: 'Repita a senha',
              validator: _validateConfirm,
              onSubmitted: _createAccount,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _busy ? null : _createAccount,
              child: const Text('Criar minha conta'),
            ),
          ],
        ),
      ),
    );
  }
}
