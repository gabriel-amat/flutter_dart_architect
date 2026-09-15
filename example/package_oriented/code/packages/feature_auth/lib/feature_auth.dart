library feature_auth;

import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class AuthLoginPage extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  const AuthLoginPage({super.key, required this.onLoginSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login (Feature Auth Package)')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(decoration: InputDecoration(labelText: 'Email')),
              const SizedBox(height: 16),
              const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Senha')),
              const SizedBox(height: 24),
              DsPrimaryButton(
                label: 'Acessar Conta',
                onPressed: onLoginSuccess,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
