import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../theme.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> couple;
  const ChatScreen({super.key, required this.couple});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ctrl = TextEditingController();

  Stream<List<Map<String, dynamic>>> get msgs => supa
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('couple_id', widget.couple['id'])
      .order('created_at', ascending: false)
      .limit(200);

  Future<void> send() async {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;
    ctrl.clear();
    await supa.from('messages').insert({
      'couple_id': widget.couple['id'],
      'sender': supa.auth.currentUser!.id,
      'body': text,
    });
  }

  @override
  Widget build(BuildContext context) {
    final me = supa.auth.currentUser!.id;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Chat', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: msgs,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snap.data!;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final m = items[i];
                    final mine = m['sender'] == me;
                    return Align(
                      alignment:
                          mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * .75),
                        decoration: BoxDecoration(
                          color: mine ? K.rose : K.card,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(mine ? 18 : 4),
                            bottomRight: Radius.circular(mine ? 4 : 18),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(m['body'],
                                style: TextStyle(
                                    color: mine ? K.ink : K.milk,
                                    fontSize: 15)),
                            Text(
                              DateFormat('HH:mm').format(
                                  DateTime.parse(m['created_at']).toLocal()),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: (mine ? K.ink : K.faded)
                                      .withOpacity(.7)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      decoration:
                          const InputDecoration(hintText: 'Say something…'),
                      onSubmitted: (_) => send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: K.rose),
                    onPressed: send,
                    icon: const Icon(Icons.arrow_upward, color: K.ink),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
