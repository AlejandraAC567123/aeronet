import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.onSubmit,
    required this.isLoading,
  });

  final Function(String? name, String email, String password, bool isSignup) onSubmit;
  final bool isLoading;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignup = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _isSignup ? _nameController.text.trim() : null,
        _emailController.text.trim(),
        _passwordController.text,
        _isSignup,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isSignup) ...[
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              style: const TextStyle(color: Colors.white),
              validator: (val) => val == null || val.trim().isEmpty
                  ? 'Por favor ingresa tu nombre'
                  : null,
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.mail_outline),
            ),
            style: const TextStyle(color: Colors.white),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Por favor ingresa tu correo';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                return 'Por favor ingresa un correo válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            style: const TextStyle(color: Colors.white),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Por favor ingresa tu contraseña';
              }
              if (val.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: widget.isLoading ? null : _submit,
            icon: widget.isLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(_isSignup ? Icons.person_add_alt : Icons.login),
            label: Text(_isSignup ? 'Registrarme' : 'Ingresar'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.isLoading
                ? null
                : () => setState(() => _isSignup = !_isSignup),
            child: Text(
              _isSignup ? '¿Ya tienes una cuenta? Inicia sesión' : 'Crear cuenta de cliente',
              style: const TextStyle(color: Color(0xFF2DD4BF)),
            ),
          ),
        ],
      ),
    );
  }
}
