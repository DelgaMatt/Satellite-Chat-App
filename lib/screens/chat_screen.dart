import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:satellite/widgets/chat_messages.dart';
import 'package:satellite/widgets/new_message.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Satellite'),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 20
          ),
        actions: [
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
