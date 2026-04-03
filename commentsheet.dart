import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentSheet extends StatefulWidget {
  final int postId;
  const CommentSheet({super.key, required this.postId});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final supabase = Supabase.instance.client;
  final text = TextEditingController();
  List comments = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await supabase
        .from('comments')
        .select()
        .eq('post_id', widget.postId)
        .order('created_at');

    setState(() => comments = data);
  }

  Future<void> send() async {
    final user = supabase.auth.currentUser!;

    await supabase.from('comments').insert({
      'post_id': widget.postId,
      'text': text.text,
      'user_id': user.id,
      'user_name': user.email,
    });

    text.clear();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...comments.map((c) => ListTile(title: Text(c['text']))),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(child: TextField(controller: text)),
                IconButton(onPressed: send, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
