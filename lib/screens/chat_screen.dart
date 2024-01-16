import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satellite/provider/dark_mode_provider.dart';
import 'package:satellite/widgets/chat_messages.dart';
import 'package:satellite/widgets/new_message.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
        var darkMode = ref.watch(darkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Satellite'),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 25,
          ),
        actions: [
          Switch(
            activeTrackColor: Colors.grey,
            value: darkMode,
            onChanged: (val) {
              ref.read(darkModeProvider.notifier).toggle();
            },
          ),
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).colorScheme.onPrimary,
              ))
        ],
      ),
      body: const Column(
        children: [
          Expanded(child:
            ChatMessages(),
          ),
          NewMessage(),
        ],
      ),
    );
  }
}
