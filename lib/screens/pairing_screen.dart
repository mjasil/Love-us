import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../theme.dart';

/// After signup you either create a knot (get a code) or join with
/// your partner's code. Once both sides are in, the couple row is complete.
class PairingScreen extends StatefulWidget {
  final Map<String, dynamic>? existingCouple;
  const PairingScreen({super.key, this.existingCouple});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final codeCtrl = TextEditingController();
  String? myCode;
  bool busy = false;
  String? error;

  @override
  void initState() {
    super.initState();
    myCode = widget.existingCouple?['invite_code'];
    if (myCode != null) _waitForPartner();
  }

  String _genCode() {
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final r = Random.secure();
    return List.generate(6, (_) => chars[r.nextInt(chars.length)]).join();
  }

  Future<void> createKnot() async {
    setState(() => busy = true);
    final code = _genCode();
    await supa.from('couples').insert({
      'user_a': supa.auth.currentUser!.id,
      'invite_code': code,
    });
    setState(() {
      myCode = code;
      busy = false;
    });
    _waitForPartner();
  }

  void _waitForPartner() {
    supa
        .from('couples')
        .stream(primaryKey: ['id'])
        .eq('invite_code', myCode!)
        .listen((rows) {
          if (rows.isNotEmpty && rows.first['user_b'] != null && mounted) {
            // Partner joined — rebuild the gate.
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const Gate()),
              (_) => false,
            );
          }
        });
  }

  Future<void> joinKnot() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final res = await supa.rpc('join_couple', params: {
        'p_code': codeCtrl.text.trim().toUpperCase(),
      });
      if (res == false) throw 'Invalid or already-used code';
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Gate()),
          (_) => false,
        );
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
              Text('Tie the knot', style: t.displayMedium),
              const SizedBox(height: 6),
              Text('Link with your person to unlock your space.',
                  style: t.bodySmall),
              const SizedBox(height: 32),
              if (myCode != null) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: K.card,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text('Your invite code', style: t.bodySmall),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: myCode!));
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied')));
                        },
                        child: Text(myCode!,
                            style: t.displayMedium!.copyWith(
                                color: K.gold, letterSpacing: 8)),
                      ),
                      const SizedBox(height: 8),
                      Text('Waiting for your partner to join…',
                          style: t.bodySmall),
                    ],
                  ),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: busy ? null : createKnot,
                  child: const Text('Create our space'),
                ),
                const SizedBox(height: 28),
                Text('— or join with a code —',
                    textAlign: TextAlign.center, style: t.bodySmall),
                const SizedBox(height: 16),
                TextField(
                  controller: codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  decoration:
                      const InputDecoration(hintText: '6-letter code'),
                ),
                const SizedBox(height: 12),
                if (error != null)
                  Text(error!,
                      style: const TextStyle(color: K.rose, fontSize: 13)),
                OutlinedButton(
                  onPressed: busy ? null : joinKnot,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    side: const BorderSide(color: K.rose),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26)),
                  ),
                  child:
                      const Text('Join', style: TextStyle(color: K.rose)),
                ),
              ],
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
