import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';
import 'screens/auth_screen.dart';
import 'screens/pairing_screen.dart';
import 'screens/shell.dart';

// ── EDIT THESE TWO LINES AFTER CREATING YOUR SUPABASE PROJECT ──
const supabaseUrl = 'https://YOUR-PROJECT.supabase.co';
const supabaseAnonKey = 'YOUR-ANON-KEY';
// ────────────────────────────────────────────────────────────────

final supa = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const KnotApp());
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
