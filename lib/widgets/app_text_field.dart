import 'package:material_ui/material_ui.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon == null ? null : Icon(icon),
        ),
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Senha',
    this.validator,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: widget.controller,
        validator: widget.validator,
        obscureText: _hidden,
        onFieldSubmitted: (_) => widget.onSubmitted?.call(),
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            tooltip: _hidden ? 'Mostrar senha' : 'Esconder senha',
            icon: Icon(_hidden ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _hidden = !_hidden),
          ),
        ),
      ),
    );
  }
}
