import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  static const String _apiKey = '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';

  final List<Map<String, dynamic>> _suggestions = [
    {'text': 'Wheat ki best variety kaun si hai?', 'icon': Icons.grass_rounded, 'color': 0xFF1B8F5A},
    {'text': 'Tomato mein pest control kaise karein?', 'icon': Icons.pest_control_rounded, 'color': 0xFFE74C3C},
    {'text': 'Monsoon mein kya ugaana chahiye?', 'icon': Icons.wb_sunny_rounded, 'color': 0xFF2980B9},
    {'text': 'Organic fertilizer kaise banayein?', 'icon': Icons.science_rounded, 'color': 0xFF27AE60},
    {'text': 'Drip irrigation ke fayde kya hain?', 'icon': Icons.water_drop_rounded, 'color': 0xFF8E44AD},
    {'text': 'Mitti ki quality kaise sudharein?', 'icon': Icons.landscape_rounded, 'color': 0xFFE67E22},
  ];

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text.trim()});
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final List<Map<String, String>> apiMessages = [
        {
          'role': 'system',
          'content':
              'Tum BizKhet ke AI Farming Assistant ho. Tumhara naam KhetBot hai. Tum sirf farming, agriculture, crops, fertilizers, weather, irrigation, pest control aur farming business se related questions ka jawab dete ho. Answers Hindi mein do — simple aur practical — jo ek Indian farmer samajh sake. Short aur useful answers do. Bullets use karo jab zarurat ho.',
        },
      ];

      for (final msg in _messages) {
        apiMessages.add({
          'role': msg['role'] == 'assistant' ? 'assistant' : 'user',
          'content': msg['content']!,
        });
      }

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': apiMessages,
          'max_tokens': 800,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        setState(() {
          _messages.add({'role': 'assistant', 'content': reply});
          _isLoading = false;
        });
      } else {
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['error']?['message'] ?? 'Unknown error';
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': '❌ Error ${response.statusCode}: $errorMsg'
          });
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': '❌ Network error. Internet check karein.\n$e'
        });
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ KEY FIX — keyboard aane par layout push hoga properly
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF2F4F0),
      body: SafeArea(
        child: Column(
          children: [
            // App bar — fixed at top
            _buildAppBar(),

            // Chat area — expands and shrinks with keyboard
            Expanded(
              child: _messages.isEmpty
                  ? _buildWelcomeScreen()
                  : _buildChatList(),
            ),

            // Typing indicator
            if (_isLoading) _buildTypingIndicator(),

            // ✅ Input bar — no viewInsets needed, SafeArea + resizeToAvoidBottomInset handles it
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  // ── APP BAR ──────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A3D22),
            Color(0xFF0F5C35),
            Color(0xFF1B8F5A)
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 2),
            ),
            child: const Center(
              child:
                  Text('🌾', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('KhetBot',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                Row(children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2ECC71),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text('Online — AI Farming Expert',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 12)),
                ]),
              ],
            ),
          ),
          if (_messages.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => _messages.clear()),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  // ── WELCOME SCREEN ───────────────────────────────────────────
  Widget _buildWelcomeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B8F5A), Color(0xFF27AE60)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF1B8F5A)
                        .withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: const Center(
              child:
                  Text('🌾', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Namaste! Main KhetBot hoon 👋',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          const Text(
            'Aapka AI Farming Assistant!\nKoi bhi farming sawaal poochein.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black45, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 28),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Ye pooch sakte hain:',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54)),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: _suggestions.map((s) {
              final color = Color(s['color'] as int);
              return GestureDetector(
                onTap: () => _sendMessage(s['text'] as String),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: color.withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black
                              .withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(s['icon'] as IconData,
                          color: color, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(s['text'] as String,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── CHAT LIST ─────────────────────────────────────────────────
  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isUser = msg['role'] == 'user';
        return _buildMessageBubble(msg['content']!, isUser);
      },
    );
  }

  // ── MESSAGE BUBBLE ───────────────────────────────────────────
  Widget _buildMessageBubble(String content, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, bottom: 2),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B8F5A), Color(0xFF27AE60)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🌾',
                    style: TextStyle(fontSize: 14)),
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF1B8F5A)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft:
                      Radius.circular(isUser ? 18 : 4),
                  bottomRight:
                      Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                      color:
                          Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Text(
                content,
                style: TextStyle(
                  color:
                      isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin:
                  const EdgeInsets.only(left: 8, bottom: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1B8F5A)
                    .withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded,
                  color: Color(0xFF1B8F5A), size: 18),
            ),
          ],
        ],
      ),
    );
  }

  // ── TYPING INDICATOR ─────────────────────────────────────────
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B8F5A), Color(0xFF27AE60)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🌾',
                  style: TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                    color:
                        Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: const Row(children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF1B8F5A)),
              ),
              SizedBox(width: 8),
              Text('KhetBot soch raha hai...',
                  style: TextStyle(
                      color: Colors.black45,
                      fontSize: 13,
                      fontStyle: FontStyle.italic)),
            ]),
          ),
        ],
      ),
    );
  }

  // ── INPUT BAR ─────────────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      // ✅ FIX — no viewInsets here, SafeArea + resizeToAvoidBottomInset handles keyboard
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick suggestion chips
          if (_messages.isNotEmpty) ...[
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _suggestions.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final color =
                      Color(_suggestions[i]['color'] as int);
                  return GestureDetector(
                    onTap: () => _sendMessage(
                        _suggestions[i]['text'] as String),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                            color:
                                color.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        _suggestions[i]['text'] as String,
                        style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Text input + send button
          Row(children: [
            Expanded(
              child: TextField(
                controller: _controller,
                // ✅ FIX — maxLines 4 so it expands upward not overflow down
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (val) => _sendMessage(val),
                decoration: InputDecoration(
                  hintText: 'Farming sawaal poochein...',
                  hintStyle: const TextStyle(
                      color: Colors.black38, fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xFFF2F4F0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _sendMessage(_controller.text),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1B8F5A),
                      Color(0xFF27AE60)
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF1B8F5A)
                            .withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
