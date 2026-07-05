import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';
import 'screens/auth_screen.dart';
import 'screens/pairing_screen.dart';
import 'screens/shell.dart';

// ── EDIT THESE TWO LINES AFTER CREATING YOUR SUPABASE PROJECT ──
const supabaseUrl = 'https://kvkoncdduueryfvtrhxd.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt2a29uY2RkdXVlcnlmdnRyaHhkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMyMDY5ODIsImV4cCI6MjA5ODc4Mjk4Mn0.AOdvv3GvU03OJMZcgpqgEWTqJiKdhXYnA6lVUgNuiec';
// ────────────────────────────────────────────────────────────────

final supa = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Catch anything that would otherwise crash the app before a single
  // widget renders, and show it on-screen instead of bouncing to home.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  String? initError;
  try {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  } catch (e) {
    initError = e.toString();
  }
  runApp(initError == null ? const KnotApp() : CrashScreen(error: initError));
}

/// Shown instead of crashing when startup fails, so we can see why.
class CrashScreen extends StatelessWidget {
  final String error;
  const CrashScreen({super.key, required this.error});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF1C1418),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Couldn\'t start Knot',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(error,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class KnotApp extends StatelessWidget {
  const KnotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Knot',
      debugShowCheckedModeBanner: false,
      theme: knotTheme,
      home: const Gate(),
    );
  }
}

/// Decides which screen to show: login → pairing → main app.
class Gate extends StatelessWidget {
  const Gate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supa.auth.onAuthStateChange,
      builder: (context, snap) {
        final session = supa.auth.currentSession;
        if (session == null) return const AuthScreen();
        return FutureBuilder(
          future: supa
              .from('couples')
              .select()
              .or('user_a.eq.${session.user.id},user_b.eq.${session.user.id}')
              .maybeSingle(),
          builder: (context, coupleSnap) {
            if (coupleSnap.connectionState != ConnectionState.done) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            if (coupleSnap.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Something went wrong loading your space:\n${coupleSnap.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              );
            }
            final couple = coupleSnap.data;
            if (couple == null || couple['user_b'] == null) {
              return PairingScreen(existingCouple: couple);
            }
            return Shell(couple: couple);
          },
        );
      },
    );
  }
}
