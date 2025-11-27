import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flight_safe/services/ai_chatbot_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);
  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final msg = ChatMessage(
      text: AiChatbotService.getResponse('hello', _messages),
      isUser: false,
      timestamp: DateTime.now(),
    );
    _messages.add(msg);
    _scrollToBottom(delayed: true);
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userMsg = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
      _controller.clear();
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 800), () {
      final botText = AiChatbotService.getResponse(text, _messages);
      final botMsg = ChatMessage(
        text: botText,
        isUser: false,
        timestamp: DateTime.now(),
      );
      setState(() {
        _messages.add(botMsg);
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom({bool delayed = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: Duration(milliseconds: delayed ? 600 : 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _showQuickExamples() {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withOpacity(0.4),
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.blue[700],
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Try asking me...',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _exampleChip('What is DXB airport?', scheme),
                      _exampleChip('Cheapest flights ADD to DXB', scheme),
                      _exampleChip('Ethiopian Airlines fleet', scheme),
                      _exampleChip('Best time to fly to London', scheme),
                      _exampleChip('Direct flights from NYC', scheme),
                      _exampleChip('Airlines flying to Tokyo', scheme),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _exampleChip(String text, ColorScheme scheme) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _controller.text = text;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [scheme.primaryContainer, scheme.primary],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: scheme.tertiary.withOpacity(0.4)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: scheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _messageBubble(ChatMessage msg, ColorScheme scheme) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[_avatar(true, scheme), const SizedBox(width: 10)],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  gradient: isUser
                      ? LinearGradient(
                          colors: [scheme.primary, scheme.primaryContainer],
                        )
                      : LinearGradient(
                          colors: [scheme.surfaceVariant, scheme.surface],
                        ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  msg.text,
                  style: TextStyle(
                    color: isUser ? scheme.onPrimary : scheme.onSurface,
                    fontSize: 15.5,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            if (isUser) ...[const SizedBox(width: 10), _avatar(false, scheme)],
          ],
        ),
      ),
    );
  }

  Widget _avatar(bool isBot, ColorScheme scheme) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: isBot ? scheme.primary : scheme.secondary,
      child: Icon(
        isBot ? Icons.auto_awesome : Icons.person,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _typingIndicator(ColorScheme scheme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16, bottom: 16),
        child: Row(
          children: [
            _avatar(true, scheme),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (i) => Container(
                    margin: const EdgeInsets.only(right: 6),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: colorScheme.surface,
        statusBarIconBrightness: colorScheme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primaryContainer],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.auto_awesome,
                color: colorScheme.onPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Flight Assistant AI',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.lightbulb_outline, color: colorScheme.primary),
            onPressed: _showQuickExamples,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _emptyState(colorScheme)
                : Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (ctx, i) {
                          if (i == _messages.length && _isTyping)
                            return _typingIndicator(colorScheme);
                          return _messageBubble(_messages[i], colorScheme);
                        },
                      ),
                    ],
                  ),
          ),
          _inputBar(colorScheme),
        ],
      ),
    );
  }

  Widget _emptyState(ColorScheme scheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.primaryContainer],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withOpacity(0.6),
                  blurRadius: 30,
                ),
              ],
            ),
            child: const Icon(
              Icons.flight_takeoff,
              color: Colors.white,
              size: 60,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Hello! I\'m your Flight Assistant',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Ask me anything about flights, airports,\nairlines, prices, or routes!',
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurface.withOpacity(0.65)),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _showQuickExamples,
            icon: Icon(Icons.lightbulb, color: scheme.onPrimary),
            label: const Text('See Examples'),
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBar(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.lightbulb_outline, color: scheme.primary),
              onPressed: _showQuickExamples,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: scheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: scheme.outline.withOpacity(0.6)),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Ask about flights...',
                    hintStyle: TextStyle(
                      color: scheme.onSurface.withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scheme.primary, scheme.primaryContainer],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withOpacity(0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
