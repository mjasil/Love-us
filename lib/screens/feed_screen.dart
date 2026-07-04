import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:home_widget/home_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../main.dart';
import '../theme.dart';

/// The Locket part: snap a photo, it lands on your partner's feed
/// and home-screen widget.
class FeedScreen extends StatefulWidget {
  final Map<String, dynamic> couple;
  const FeedScreen({super.key, required this.couple});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final picker = ImagePicker();
  bool uploading = false;

  Stream<List<Map<String, dynamic>>> get drops => supa
      .from('drops')
      .stream(primaryKey: ['id'])
      .eq('couple_id', widget.couple['id'])
      .order('created_at', ascending: false)
      .limit(50);

  Future<void> drop(ImageSource source) async {
    final img = await picker.pickImage(
        source: source, maxWidth: 1080, imageQuality: 82);
    if (img == null) return;
    setState(() => uploading = true);
    try {
      final path = '${widget.couple['id']}/${const Uuid().v4()}.jpg';
      await supa.storage.from('drops').upload(path, File(img.path));
      final url = supa.storage.from('drops').getPublicUrl(path);
      await supa.from('drops').insert({
        'couple_id': widget.couple['id'],
        'sender': supa.auth.currentUser!.id,
        'image_url': url,
      });
      // Update my own home widget too (partner's updates on next app open;
      // push-driven widget refresh is a v2 job with FCM).
      await HomeWidget.saveWidgetData('latest_url', url);
      await HomeWidget.updateWidget(
          name: 'KnotWidgetProvider', iOSName: 'KnotWidget');
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final me = supa.auth.currentUser!.id;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Drops', style: t.titleLarge),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: K.rose,
        foregroundColor: K.ink,
        onPressed: uploading
            ? null
            : () => showModalBottomSheet(
                  context: context,
                  backgroundColor: K.card,
                  builder: (_) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading:
                              const Icon(Icons.camera_alt, color: K.rose),
                          title: const Text('Camera'),
                          onTap: () {
                            Navigator.pop(context);
                            drop(ImageSource.camera);
                          },
                        ),
                        ListTile(
                          leading:
                              const Icon(Icons.photo_library, color: K.rose),
                          title: const Text('Gallery'),
                          onTap: () {
                            Navigator.pop(context);
                            drop(ImageSource.gallery);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
        icon: uploading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.favorite),
        label: Text(uploading ? 'Sending…' : 'Drop'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: drops,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data!;
          if (items.isEmpty) {
            return Center(
              child: Text('No drops yet.\nSend the first one 💌',
                  textAlign: TextAlign.center, style: t.bodySmall),
            );
          }
          // Keep widget in sync with the newest drop when feed loads.
          HomeWidget.saveWidgetData('latest_url', items.first['image_url'])
              .then((_) => HomeWidget.updateWidget(
                  name: 'KnotWidgetProvider', iOSName: 'KnotWidget'));
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final d = items[i];
              final mine = d['sender'] == me;
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                        imageUrl: d['image_url'], fit: BoxFit.cover),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: K.ink.withOpacity(.65),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${mine ? "you" : "them"} · ${DateFormat('d MMM').format(DateTime.parse(d['created_at']).toLocal())}',
                          style: const TextStyle(
                              fontSize: 11, color: K.milk),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
