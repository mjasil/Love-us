import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../theme.dart';

/// Days together + custom countdowns (anniversary, next trip, etc.)
class CountdownScreen extends StatefulWidget {
  final Map<String, dynamic> couple;
  const CountdownScreen({super.key, required this.couple});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  Stream<List<Map<String, dynamic>>> get events => supa
      .from('countdowns')
      .stream(primaryKey: ['id'])
      .eq('couple_id', widget.couple['id'])
      .order('date');

  Future<void> addEvent() async {
    final titleCtrl = TextEditingController();
    DateTime? picked;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: K.card,
        title: const Text('New date'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                    hintText: 'Anniversary, trip, birthday…')),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                picked = await showDatePicker(
                  context: ctx,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );
              },
              child: const Text('Pick date'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty || picked == null) return;
              await supa.from('countdowns').insert({
                'couple_id': widget.couple['id'],
                'title': titleCtrl.text.trim(),
                'date': DateFormat('yyyy-MM-dd').format(picked!),
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(color: K.rose)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final started = widget.couple['created_at'] != null
        ? DateTime.parse(widget.couple['created_at'])
        : DateTime.now();
    final daysTogether = DateTime.now().difference(started).inDays;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Days', style: t.titleLarge),
        actions: [
          IconButton(
              onPressed: addEvent,
              icon: const Icon(Icons.add, color: K.gold)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [K.rose.withOpacity(.25), K.gold.withOpacity(.15)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text('$daysTogether',
                    style: t.displayMedium!
                        .copyWith(fontSize: 56, color: K.gold)),
                Text('days in our space', style: t.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 20),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: events,
            builder: (context, snap) {
              final items = snap.data ?? [];
              if (items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text('Add anniversaries, trips, birthdays with +',
                      textAlign: TextAlign.center, style: t.bodySmall),
                );
              }
              return Column(
                children: items.map((e) {
                  final date = DateTime.parse(e['date']);
                  final diff =
                      date.difference(DateTime.now()).inDays + 1;
                  final label = diff >= 0
                      ? 'in $diff days'
                      : '${diff.abs()} days ago';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: K.card,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e['title'],
                                  style: t.bodyMedium!.copyWith(
                                      fontWeight: FontWeight.w600)),
                              Text(DateFormat('d MMMM yyyy').format(date),
                                  style: t.bodySmall),
                            ],
                          ),
                        ),
                        Text(label,
                            style: t.bodyMedium!.copyWith(color: K.gold)),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
