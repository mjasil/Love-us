import 'package:flutter/material.dart';
import '../theme.dart';
import 'feed_screen.dart';
import 'chat_screen.dart';
import 'countdown_screen.dart';
import 'profile_screen.dart';

class Shell extends StatefulWidget {
  final Map<String, dynamic> couple;
  const Shell({super.key, required this.couple});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int idx = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      FeedScreen(couple: widget.couple),
      ChatScreen(couple: widget.couple),
      CountdownScreen(couple: widget.couple),
      ProfileScreen(couple: widget.couple),
    ];
    return Scaffold(
      body: pages[idx],
      bottomNavigationBar: NavigationBar(
        backgroundColor: K.card,
        indicatorColor: K.rose.withOpacity(.18),
        selectedIndex: idx,
        onDestinationSelected: (i) => setState(() => idx = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.favorite_outline, color: K.faded),
              selectedIcon: Icon(Icons.favorite, color: K.rose),
              label: 'Drops'),
          NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline, color: K.faded),
              selectedIcon: Icon(Icons.chat_bubble, color: K.rose),
              label: 'Chat'),
          NavigationDestination(
              icon: Icon(Icons.hourglass_empty, color: K.faded),
              selectedIcon: Icon(Icons.hourglass_full, color: K.gold),
              label: 'Days'),
          NavigationDestination(
              icon: Icon(Icons.person_outline, color: K.faded),
              selectedIcon: Icon(Icons.person, color: K.rose),
              label: 'Us'),
        ],
      ),
    );
  }
}
