import 'package:flutter/material.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  int _selectedTab = 0;
  final tabs = ['Trending', 'Latest', 'My Posts'];

  final List<Map<String, dynamic>> posts = [
    {
      "title": "Best organic fertilizer for wheat?",
      "author": "Ramesh Kumar",
      "initials": "RK",
      "category": "Fertilizer",
      "categoryColor": 0xFF27AE60,
      "likes": 12,
      "liked": false,
      "comments": [
        {"author": "Suresh", "initials": "SU", "text": "Use vermicompost", "time": "1h ago"},
        {"author": "Priya", "initials": "PR", "text": "Neem cake works well", "time": "30m ago"},
      ],
      "time": "2h ago",
      "views": 234,
    },
    {
      "title": "How to control pests in tomato crops naturally?",
      "author": "Sita Devi",
      "initials": "SD",
      "category": "Pest Control",
      "categoryColor": 0xFFE74C3C,
      "likes": 24,
      "liked": false,
      "comments": [
        {"author": "Mohan", "initials": "MO", "text": "Try neem oil spray", "time": "4h ago"},
      ],
      "time": "5h ago",
      "views": 512,
    },
    {
      "title": "Government subsidy for drip irrigation 2024",
      "author": "Amit Singh",
      "initials": "AS",
      "category": "Subsidy",
      "categoryColor": 0xFF2980B9,
      "likes": 45,
      "liked": false,
      "comments": [
        {"author": "Kavita", "initials": "KA", "text": "Check PMKSY scheme", "time": "20h ago"},
      ],
      "time": "1d ago",
      "views": 890,
    },
    {
      "title": "Monsoon forecast 2024 — what farmers should know",
      "author": "Dr. Rajiv Mehta",
      "initials": "RM",
      "category": "Weather",
      "categoryColor": 0xFF8E44AD,
      "likes": 67,
      "liked": false,
      "comments": [],
      "time": "2d ago",
      "views": 1240,
    },
  ];

  void _toggleLike(int index) {
    setState(() {
      posts[index]['liked'] = !posts[index]['liked'];
      posts[index]['likes'] += posts[index]['liked'] ? 1 : -1;
    });
  }

  void _openNewPost() {
    final titleController = TextEditingController();
    String selectedCategory = 'Fertilizer';
    final categories = ['Fertilizer', 'Pest Control', 'Subsidy', 'Weather', 'Irrigation', 'Seeds'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          margin: const EdgeInsets.all(12),
          padding: EdgeInsets.only(
            left: 20, right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('New Post',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Category', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 13)),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => setModalState(() => selectedCategory = categories[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: selectedCategory == categories[i]
                            ? const Color(0xFF1B8F5A)
                            : const Color(0xFFF2F4F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        categories[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selectedCategory == categories[i] ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Your Question', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'What do you want to ask the community?',
                  hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xFFF8FAF7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isNotEmpty) {
                      setState(() {
                        posts.insert(0, {
                          "title": titleController.text.trim(),
                          "author": "You",
                          "initials": "YO",
                          "category": selectedCategory,
                          "categoryColor": 0xFF1B8F5A,
                          "likes": 0,
                          "liked": false,
                          "comments": [],
                          "time": "Just now",
                          "views": 0,
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B8F5A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Post to Community',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addComment(int index) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Comment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Share your knowledge...',
                hintStyle: const TextStyle(color: Colors.black38),
                filled: true,
                fillColor: const Color(0xFFF8FAF7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    setState(() {
                      posts[index]['comments'].add({
                        "author": "You",
                        "initials": "YO",
                        "text": controller.text.trim(),
                        "time": "Just now",
                      });
                    });
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B8F5A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Post Comment',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F0),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: const Color(0xFF0F5C35),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0A3D22), Color(0xFF0F5C35), Color(0xFF1B8F5A)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Community',
                                    style: TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 1.5)),
                                Text('Forum',
                                    style: TextStyle(color: Colors.white, fontSize: 30,
                                        fontWeight: FontWeight.bold, height: 1.1)),
                              ],
                            ),
                            GestureDetector(
                              onTap: _openNewPost,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                                    SizedBox(width: 6),
                                    Text('Post', style: TextStyle(
                                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _headerBadge(Icons.people_rounded, '2.4k Members'),
                            const SizedBox(width: 10),
                            _headerBadge(Icons.forum_rounded, '${posts.length} Posts'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              title: const Text('Community Forum',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              collapseMode: CollapseMode.parallax,
            ),
          ),

          // Tab bar
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: List.generate(tabs.length, (i) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _selectedTab == i
                            ? const Color(0xFF1B8F5A)
                            : const Color(0xFFF2F4F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tabs[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _selectedTab == i ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                )),
              ),
            ),
          ),

          // Posts list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildPostCard(index),
                childCount: posts.length,
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewPost,
        backgroundColor: const Color(0xFF1B8F5A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ask Community',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _headerBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 13),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildPostCard(int index) {
    final post = posts[index];
    final catColor = Color(post['categoryColor']);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PostDetailPage(
            post: post,
            onAddComment: (comment) {
              setState(() {
                posts[index]['comments'].add({
                  "author": "You",
                  "initials": "YO",
                  "text": comment,
                  "time": "Just now",
                });
              });
            },
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        post['initials'],
                        style: TextStyle(
                          color: catColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post['author'],
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.black87)),
                        Text(post['time'],
                            style: const TextStyle(
                                color: Colors.black38, fontSize: 11)),
                      ],
                    ),
                  ),
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      post['category'],
                      style: TextStyle(
                        color: catColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                post['title'],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 12),

              // Actions row
              Row(
                children: [
                  // Like button
                  GestureDetector(
                    onTap: () => _toggleLike(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: post['liked']
                            ? const Color(0xFF1B8F5A).withValues(alpha: 0.1)
                            : const Color(0xFFF2F4F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            post['liked'] ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                            size: 15,
                            color: post['liked'] ? const Color(0xFF1B8F5A) : Colors.black45,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${post['likes']}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: post['liked'] ? const Color(0xFF1B8F5A) : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Comment button
                  GestureDetector(
                    onTap: () => _addComment(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline_rounded,
                              size: 15, color: Colors.black45),
                          const SizedBox(width: 5),
                          Text(
                            '${post['comments'].length}',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black45),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Views
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye_outlined,
                          size: 14, color: Colors.black38),
                      const SizedBox(width: 4),
                      Text(
                        '${post['views']}',
                        style: const TextStyle(fontSize: 12, color: Colors.black38),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── POST DETAIL PAGE ─────────────────────────────────────────
class PostDetailPage extends StatefulWidget {
  final Map<String, dynamic> post;
  final Function(String) onAddComment;

  const PostDetailPage({
    super.key,
    required this.post,
    required this.onAddComment,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late List<dynamic> comments;
  final commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    comments = List.from(widget.post['comments']);
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    if (commentController.text.trim().isEmpty) return;
    final newComment = {
      "author": "You",
      "initials": "YO",
      "text": commentController.text.trim(),
      "time": "Just now",
    };
    setState(() => comments.add(newComment));
    widget.onAddComment(commentController.text.trim());
    commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final catColor = Color(widget.post['categoryColor']);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5C35),
        foregroundColor: Colors.white,
        title: const Text('Discussion',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Post card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.post['category'],
                          style: TextStyle(
                              color: catColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.post['title'],
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold, height: 1.3),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(widget.post['initials'],
                                  style: TextStyle(
                                      color: catColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.post['author'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 13)),
                              Text(widget.post['time'],
                                  style: const TextStyle(
                                      color: Colors.black38, fontSize: 11)),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.thumb_up_rounded,
                                  size: 14, color: Color(0xFF1B8F5A)),
                              const SizedBox(width: 4),
                              Text('${widget.post['likes']}',
                                  style: const TextStyle(
                                      color: Color(0xFF1B8F5A),
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Comments header
                Row(
                  children: [
                    const Text('Comments',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B8F5A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${comments.length}',
                        style: const TextStyle(
                            color: Color(0xFF1B8F5A),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (comments.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded,
                              size: 40, color: Colors.black26),
                          SizedBox(height: 8),
                          Text('No comments yet. Be first!',
                              style: TextStyle(color: Colors.black45)),
                        ],
                      ),
                    ),
                  )
                else
                  ...comments.asMap().entries.map((entry) {
                    final c = entry.value;
                    final isYou = c['author'] == 'You';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isYou
                            ? const Color(0xFF1B8F5A).withValues(alpha: 0.05)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: isYou
                            ? Border.all(
                                color: const Color(0xFF1B8F5A).withValues(alpha: 0.2))
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isYou
                                  ? const Color(0xFF1B8F5A).withValues(alpha: 0.15)
                                  : const Color(0xFFF2F4F0),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                c['initials'] ?? '??',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isYou
                                      ? const Color(0xFF1B8F5A)
                                      : Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      c['author'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      c['time'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.black38, fontSize: 11),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  c['text'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),

          // Comment input bar
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: 'Share your knowledge...',
                      hintStyle:
                          const TextStyle(color: Colors.black38, fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFF2F4F0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _submitComment,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1B8F5A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
