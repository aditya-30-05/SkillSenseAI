import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/app/theme.dart';
import 'package:trainer_app/models/ai_feedback.dart';
import 'package:trainer_app/providers/app_provider.dart';
import 'package:trainer_app/widgets/common_widgets.dart';

class AiCoachScreen extends ConsumerStatefulWidget {
  const AiCoachScreen({super.key});

  @override
  ConsumerState<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends ConsumerState<AiCoachScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  static const _suggestions = [
    'Why did Rahul lose marks in the last session?',
    'Summarize this trainee\'s performance.',
    'What should Rahul practice next?',
    'Show trainees who need additional practice.',
    'Generate a trainer report.',
  ];

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    await ref.read(aiChatHistoryProvider.notifier).sendUserMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(aiChatHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(),
          Expanded(
            child: messages.isEmpty
                ? _EmptyState(
                    suggestions: _suggestions,
                    onSuggest: (q) {
                      _inputCtrl.text = q;
                      _send();
                    },
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                    itemCount: messages.length,
                    itemBuilder: (context, i) =>
                        _ChatBubble(message: messages[i]),
                  ),
          ),
          _InputBar(
            controller: _inputCtrl,
            onSend: _send,
            onSuggest: messages.isEmpty
                ? null
                : null, // only show on empty state
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.aiPurple, Color(0xFF6D28D9)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SkillSense AI Coach',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'AI-powered training analysis and coaching assistant',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.aiPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.aiPurple.withValues(alpha: 0.25)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PulseDot(color: AppColors.aiPurple, size: 7),
                SizedBox(width: 7),
                Text(
                  'AI Engine Active',
                  style: TextStyle(color: AppColors.aiPurple, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSuggest;

  const _EmptyState({required this.suggestions, required this.onSuggest});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // AI icon with glow
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.aiPurple.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.aiPurple.withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.aiPurple.withValues(alpha: 0.12),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: AppColors.aiPurple, size: 40),
          ),
          const SizedBox(height: 24),
          const Text(
            'How can I help you today?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ask about trainee performance, session analysis,\ncoaching recommendations, or request reports.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.aiPurple,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Suggested questions',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: suggestions.map((s) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SuggestionPill(text: s, onTap: () => onSuggest(s)),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.navyCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.navyBorder),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textMuted),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI responses are mock analysis for demonstration. '
                    'In production, this connects to a FastAPI backend with an LLM.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.5),
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

class _SuggestionPill extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  const _SuggestionPill({required this.text, required this.onTap});

  @override
  State<_SuggestionPill> createState() => _SuggestionPillState();
}

class _SuggestionPillState extends State<_SuggestionPill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.aiPurple.withValues(alpha: 0.08)
                : AppColors.navyCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered
                  ? AppColors.aiPurple.withValues(alpha: 0.4)
                  : AppColors.navyBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: _hovered ? AppColors.aiPurple : AppColors.textMuted,
                size: 14,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: _hovered ? AppColors.textPrimary : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: _hovered ? AppColors.aiPurple : AppColors.textMuted,
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final AiChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 72),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.14),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(4),
                  ),
                  border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
                ),
                child: Text(
                  message.content,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Center(
                child: Text(
                  'T',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // AI message
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 72),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.aiPurple, Color(0xFF6D28D9)],
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.navyCard,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
                border: Border.all(color: AppColors.navyBorder),
              ),
              child: message.isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 52,
                      child: Row(
                        children: [
                          _TypingDot(delay: 0),
                          SizedBox(width: 5),
                          _TypingDot(delay: 200),
                          SizedBox(width: 5),
                          _TypingDot(delay: 400),
                        ],
                      ),
                    )
                  : _MarkdownText(text: message.content),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple markdown-like text renderer for AI responses
class _MarkdownText extends StatelessWidget {
  final String text;
  const _MarkdownText({required this.text});

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.startsWith('**') && line.endsWith('**')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              line.replaceAll('**', ''),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
          );
        }
        if (line.startsWith('- ') || line.startsWith('• ')) {
          return Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.circle, color: AppColors.teal, size: 5),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    line.replaceFirst(RegExp(r'^[-•]\s'), ''),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        if (line.startsWith('*') && !line.startsWith('**')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              line.replaceAll('*', ''),
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }
        if (line.startsWith('| ')) {
          return const SizedBox.shrink();
        }
        if (line.isEmpty) {
          return const SizedBox(height: 4);
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(
            line,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.55,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.aiPurple,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _InputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onSuggest;

  const _InputBar({
    required this.controller,
    required this.onSend,
    this.onSuggest,
  });

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      final has = widget.controller.text.isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.navyCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.navyBorder),
              ),
              child: TextField(
                controller: widget.controller,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                maxLines: null,
                onSubmitted: (_) => widget.onSend(),
                decoration: const InputDecoration(
                  hintText: 'Ask the AI Coach anything...',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  prefixIcon: Icon(Icons.chat_bubble_outline_rounded,
                      color: AppColors.textMuted, size: 18),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: ElevatedButton(
              onPressed: widget.onSend,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _hasText ? AppColors.aiPurple : AppColors.navyCard,
                foregroundColor: _hasText ? Colors.white : AppColors.textMuted,
                padding: const EdgeInsets.all(14),
                minimumSize: const Size(48, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Icon(Icons.send_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
