import 'package:flutter/material.dart';

class AdminLoginDialog extends StatefulWidget {
  final String password;

  const AdminLoginDialog({
    super.key,
    required this.password,
  });

  static Future<bool> open(
    BuildContext context, {
    required String password,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AdminLoginDialog(password: password),
    );
    return ok ?? false;
  }

  @override
  State<AdminLoginDialog> createState() => _AdminLoginDialogState();
}

class _AdminLoginDialogState extends State<AdminLoginDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Admin login'),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Password',
        ),
        onSubmitted: (_) => _onLogin(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _onLogin,
          child: const Text('Login'),
        ),
      ],
    );
  }

  void _onLogin() {
    final ok = _ctrl.text.trim() == widget.password;
    Navigator.pop(context, ok);
  }
}