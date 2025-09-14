import 'package:flutter/material.dart';
import '../utils/asset_manager.dart';

class QalbuChatScreen extends StatefulWidget {
  const QalbuChatScreen({super.key});

  @override
  State<QalbuChatScreen> createState() => _QalbuChatScreenState();
}

class _QalbuChatScreenState extends State<QalbuChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Add initial welcome messages with modern Islamic greeting
    messages = [
      ChatMessage(
        text: "بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ\n\nAssalamu'alaikum warahmatullahi wabarakatuh 🌙",
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      ChatMessage(
        text: "Ahlan wa sahlan, akhi/ukhti! Selamat datang di QalbuChat - teman curhat Islami Anda ✨\n\nSaya di sini untuk mendengarkan keluh kesah, memberikan nasihat berdasarkan Al-Quran dan Sunnah, serta menemani Anda dalam perjalanan spiritual.",
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      ChatMessage(
        text: "💭 Ceritakan apa yang sedang Anda rasakan hari ini\n💚 Bagikan kebahagiaan atau kesedihan Anda\n🤲 Minta doa atau nasihat Islami\n📖 Diskusi tentang ayat Al-Quran dan hadits\n\nIngat, Allah selalu mendengar hamba-Nya. Mari berbagi dan saling menguatkan dalam keimanan! 🤗",
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
    ];
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: _messageController.text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      messages.add(userMessage);
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      final responses = [
        "Barakallahu fiika atas kepercayaanmu untuk berbagi. Allah SWT berfirman: 'Dan barangsiapa bertawakal kepada Allah, maka Allah akan mencukupkan (keperluan)nya.' (QS. At-Talaq: 3)",
        "Masya Allah, ingatlah firman Allah dalam QS. Al-Baqarah ayat 286: 'Allah tidak membebani seseorang melainkan sesuai dengan kesanggupannya.' Yakinlah bahwa Allah tidak akan memberikan cobaan melebihi kemampuan kita.",
        "Subhanallah, mari kita renungkan bersama hikmah dari Allah dalam situasi ini. Setiap kesulitan pasti ada kemudahan, sebagaimana firman-Nya dalam QS. Ash-Sharh.",
        "Semoga Allah memberikan kemudahan untukmu, akhi/ukhti. Jangan lupa untuk selalu berdoa, dzikir, dan bertawakal kepada Allah. 'Wa man yatawakkal 'ala Allah fa huwa hasbuh' - Barangsiapa bertawakal kepada Allah, maka Allah akan mencukupkannya.",
        "Alhamdulillahi rabbil alamiin. Tetap semangat dalam menjalani hidup dengan ridha Allah. Ingat, setiap doa yang kita panjatkan tidak akan sia-sia. Allah Maha Mendengar lagi Maha Mengabulkan.",
        "La hawla wa la quwwata illa billah. Kekuatan hanya milik Allah. Ketika kita merasa lemah, ingatlah bahwa Allah selalu bersama hamba-Nya yang beriman. Tetap istiqamah dalam beribadah, ya.",
        "Allahu a'lam, Allah lebih mengetahui apa yang terbaik untuk kita. Kadang apa yang kita anggap buruk justru mengandung kebaikan yang belum kita ketahui. Tetap bersabar dan berdoa.",
        "Rabbana atina fi'd-dunya hasanatan wa fi'l-akhirati hasanatan wa qina 'adhab an-nar. Semoga Allah memberikan kebaikan di dunia dan akhirat untukmu. Tetap dekat dengan Al-Quran dan sunnah Rasulullah.",
      ];
      
      final response = ChatMessage(
        text: responses[DateTime.now().millisecondsSinceEpoch % responses.length],
        isUser: false,
        timestamp: DateTime.now(),
      );

      if (mounted) {
        setState(() {
          messages.add(response);
          _isTyping = false;
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2D5A5A), // Teal gelap
              Color(0xFF4A6741), // Green gelap
              Color(0xFFF0F8F8), // Light teal
            ],
            stops: [0.0, 0.2, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  children: [
                    // Header dengan avatar dan title
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Qalbu Bot Avatar
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              AssetManager.chatBotAvatar,
                              width: 45,
                              height: 45,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF8FA68E), Color(0xFF2D5A5A)],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.psychology,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Bot info
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Qalbu Assistant',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Color(0xFF4CAF50),
                                    size: 8,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Online • Siap membantu',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            onPressed: () {
                              // TODO: Show menu
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Chat messages dengan modern container
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FFFE),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Chat messages
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
                          itemCount: messages.length + (_isTyping ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == messages.length && _isTyping) {
                              return _buildModernTypingIndicator();
                            }
                            return _buildModernMessageBubble(messages[index]);
                          },
                        ),
                      ),

                      // Modern Input field
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2D5A5A).withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, -4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: SafeArea(
                          child: Row(
                            children: [
                              // Attach button
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8FA68E).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Color(0xFF8FA68E),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    // TODO: Show attachment options
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Text input
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FFFE),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: const Color(0xFF8FA68E).withOpacity(0.2),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _messageController,
                                    decoration: const InputDecoration(
                                      hintText: 'Ketik pesan untuk Qalbu...',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF8FA68E),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 14,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      color: Color(0xFF2D5A5A),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: null,
                                    textInputAction: TextInputAction.send,
                                    onSubmitted: (_) => _sendMessage(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Send button
                              GestureDetector(
                                onTap: _sendMessage,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF8FA68E),
                                        Color(0xFF2D5A5A),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF8FA68E).withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Quick suggestions button
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: FloatingActionButton(
              heroTag: "suggestions",
              mini: true,
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: () {
                _showQuickSuggestions();
              },
              child: const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFF8FA68E),
                size: 20,
              ),
            ),
          ),
          // Voice message button
          FloatingActionButton(
            heroTag: "voice",
            backgroundColor: const Color(0xFF8FA68E),
            elevation: 6,
            onPressed: () {
              _showVoiceRecording();
            },
            child: const Icon(
              Icons.mic,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickSuggestions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF8FA68E).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Saran Topik Percakapan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D5A5A),
              ),
            ),
            const SizedBox(height: 20),
            ...[
              'Bagaimana cara mengatasi kecemasan menurut Islam?',
              'Doa-doa untuk menenangkan hati',
              'Tips istiqamah dalam beribadah',
              'Hikmah dalam menghadapi cobaan',
              'Cara mendekatkan diri kepada Allah',
            ].map((suggestion) => _buildSuggestionTile(suggestion)).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionTile(String suggestion) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _messageController.text = suggestion;
        _sendMessage();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Text(
          suggestion,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF2D5A5A),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showVoiceRecording() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8FA68E), Color(0xFF2D5A5A)],
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Fitur Voice Message',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D5A5A),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Akan segera hadir!\nSaat ini silakan gunakan text message.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8FA68E),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF8FA68E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            // Modern bot avatar
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 12, bottom: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8FA68E), Color(0xFF2D5A5A)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8FA68E).withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  AssetManager.chatBotAvatar,
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8FA68E), Color(0xFF2D5A5A)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 16,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Column(
                crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: message.isUser 
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF8FA68E), Color(0xFF2D5A5A)],
                            )
                          : null,
                      color: message.isUser ? null : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: message.isUser ? const Radius.circular(20) : const Radius.circular(4),
                        bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: message.isUser 
                              ? const Color(0xFF8FA68E).withOpacity(0.2)
                              : const Color(0xFF2D5A5A).withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                          spreadRadius: 0,
                        ),
                      ],
                      border: !message.isUser 
                          ? Border.all(
                              color: const Color(0xFF8FA68E).withOpacity(0.1),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser ? Colors.white : const Color(0xFF2D5A5A),
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Timestamp
                  Padding(
                    padding: EdgeInsets.only(
                      left: message.isUser ? 0 : 8,
                      right: message.isUser ? 8 : 0,
                    ),
                    child: Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: const Color(0xFF8FA68E).withOpacity(0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 12, bottom: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D5A5A), Color(0xFF8FA68E)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D5A5A).withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Modern bot avatar
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 12, bottom: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8FA68E), Color(0xFF2D5A5A)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8FA68E).withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                AssetManager.chatBotAvatar,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8FA68E), Color(0xFF2D5A5A)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 16,
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2D5A5A).withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                  spreadRadius: 0,
                ),
              ],
              border: Border.all(
                color: const Color(0xFF8FA68E).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModernTypingDot(0),
                const SizedBox(width: 6),
                _buildModernTypingDot(200),
                const SizedBox(width: 6),
                _buildModernTypingDot(400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTypingDot(int delay) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween<double>(begin: 0.3, end: 1.0),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8FA68E).withOpacity(value),
                  Color(0xFF2D5A5A).withOpacity(value),
                ],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) setState(() {});
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// Data model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
