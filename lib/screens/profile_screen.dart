import 'package:flutter/material.dart';
import '../main.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> couple;
  const ProfileScreen({super.key, required this.couple});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final user = supa.auth.currentUser!;
    final name = user.userMetadata?['display_name'] ?? user.email ?? 'You';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Us', style: t.titleLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: K.card, borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                const CircleAvatar(
                    radius: 26,
                    backgroundColor: K.rose,
                    child: Icon(Icons.favorite, color: K.ink)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: t.bodyMedium!
                              .copyWith(fontWeight: FontWeight.w600)),
                      Text('Knot code: ${couple['invite_code']}',
                          style: t.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: K.card,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            leading: const Icon(Icons.widgets_outlined, color: K.gold),
            title: const Text('Home-screen widget'),
            subtitle: const Text(
                'Long-press your home screen → Widgets → Knot. Latest drop shows there.',
                style: TextStyle(color: K.faded, fontSize: 12)),
          ),
          const SizedBox(height: 8),
          ListTile(
            tileColor: K.card,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            leading: const Icon(Icons.logout, color: K.rose),
            title: const Text('Sign out'),
            onTap: () => supa.auth.signOut(),
          ),
        ],
      ),
    );
  }
}
