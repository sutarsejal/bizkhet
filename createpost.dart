import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final supabase = Supabase.instance.client;
  final title = TextEditingController();
  final content = TextEditingController();

  Future<void> submit() async {
    final user = supabase.auth.currentUser!;

    await supabase.from('posts').insert({
      'title': title.text,
      'content': content.text,
      'user_id': user.id,
      'user_name': user.email,
      'likes_users': [],
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: content, decoration: const InputDecoration(labelText: 'Content')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: submit, child: const Text('Post')),
          ],
        ),
      ),
    );
  }
}
