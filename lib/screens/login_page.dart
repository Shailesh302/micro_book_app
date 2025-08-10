// lib/screens/login_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLogin = true;
  bool _isLoading = false;

  void _showFeedbackDialog({required String title, required String content}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final email = _emailController.text;
      final password = _passwordController.text;
      try {
        if (_isLogin) {
          await _authService.signInWithEmailPassword(email, password);
        } else {
          final newUser = await _authService.signUpWithEmailPassword(email, password);
          if (newUser != null) {
            await _authService.signOut();
            _showFeedbackDialog(
              title: 'Account Created!',
              content: 'Your account has been created successfully. Please log in to continue.',
            );
            setState(() {
              _isLogin = true;
              _emailController.clear();
              _passwordController.clear();
            });
          }
        }
      } on FirebaseAuthException catch (e) {
        String message = 'An error occurred. Please check your credentials.';
        if (e.code == 'email-already-in-use') {
          message = 'This email address is already in use by another account.';
        } else if (e.code == 'wrong-password' || e.code == 'user-not-found' || e.code == 'invalid-credential') {
          message = 'Invalid email or password. Please try again.';
        }
        _showFeedbackDialog(title: 'Authentication Failed', content: message);
      } catch (e) {
        _showFeedbackDialog(title: 'Error', content: 'An unexpected error occurred.');
      }
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Icon(Icons.menu_book_rounded, size: 60, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('Micro-Book', textAlign: TextAlign.center, style: textTheme.headlineLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_isLogin ? 'Sign in to continue' : 'Create an account', textAlign: TextAlign.center, style: textTheme.titleMedium),
                  const SizedBox(height: 40.0),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.primary.withOpacity(0.7)),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || v.isEmpty || !v.contains('@')) ? 'Please enter a valid email' : null,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(hintText: 'Password', prefixIcon: Icon(Icons.lock_outline_rounded, color: theme.colorScheme.primary.withOpacity(0.7)), filled: true, fillColor: theme.colorScheme.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
                  ),
                  const SizedBox(height: 24.0),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: _submit,
                    child: Text(_isLogin ? 'Login' : 'Sign Up'),
                  ),
                  TextButton(
                    onPressed: () { if (!_isLoading) setState(() => _isLogin = !_isLogin); },
                    child: Text(_isLogin ? 'Create an account' : 'I already have an account'),
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