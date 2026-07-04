import 'package:flutter/material.dart';
import '../main.dart';
import '../theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();
  final name = TextEditingController();
  bool signUp = false;
  bool busy = false;
  String? error;

  Future<void> go() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (signUp) {
        await supa.auth.signUp(
          email: email.text.trim(),
          password: pass.text,
          data: {'display_name': name.text.trim()},
        );
      } else {
        await supa.auth.signInWithPassword(
            email: email.text.trim(), password: pass.text);
      }
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text('Knot', style: t.displayMedium),
              const SizedBox(height: 6),
              Text('A private space for two.', style: t.bodySmall),
              const SizedBox(height: 36),
              if (signUp) ...[
                TextField(
                    controller: name,
                    decoration: const InputDecoration(hintText: 'Your name')),
                const SizedBox(height: 12),
              ],
              TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'Email')),
              const SizedBox(height: 12),
              TextField(
                  controller: pass,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Password')),
              const SizedBox(height: 20),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(error!,
                      style: const TextStyle(color: K.rose, fontSize: 13)),
                ),
              ElevatedButton(
                onPressed: busy ? null : go,
                child: Text(busy
                    ? '...'
                    : signUp
                        ? 'Create account'
                        : 'Sign in'),
              ),
              TextButton(
                onPressed: () => setState(() => signUp = !signUp),
                child: Text(
                  signUp
                      ? 'Already have an account? Sign in'
                      : 'New here? Create an account',
                  style: const TextStyle(color: K.faded),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
