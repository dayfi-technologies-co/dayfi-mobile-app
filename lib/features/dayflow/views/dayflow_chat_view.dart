import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/widgets/dayflow_chat_ui.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/features/dayflow/views/dayflow_plan_review_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({required this.text, required this.isUser});
}

class DayFlowChatView extends StatefulWidget {
  final String? initialPrompt;

  const DayFlowChatView({super.key, this.initialPrompt});

  @override
  State<DayFlowChatView> createState() => _DayFlowChatViewState();
}

class _DayFlowChatViewState extends State<DayFlowChatView> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMessage>[];
  bool _thinking = false;

  static const _quickPrompts = [
    DayFlowCopy.quickPromptBudgetSalary,
    DayFlowCopy.quickPromptRecurring,
    DayFlowCopy.quickPromptThisMonth,
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(const _ChatMessage(text: DayFlowCopy.chatWelcome, isUser: false));
    if (widget.initialPrompt != null && widget.initialPrompt!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _send(widget.initialPrompt!.trim());
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _thinking) return;

    setState(() {
      _messages.add(_ChatMessage(text: text.trim(), isUser: true));
      _thinking = true;
      _controller.clear();
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final reply = _buildAssistantReply(text);
    setState(() {
      _messages.add(_ChatMessage(text: reply, isUser: false));
      _thinking = false;
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final plan = DayFlowPlan.demoFromPrompt(text);
    final approved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DayFlowPlanReviewView(plan: plan, sourcePrompt: text),
      ),
    );
    if (approved == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  String _buildAssistantReply(String prompt) {
    return '''Got it! Here's what I understood:

• Income & fixed expenses from your message
• Recurring sends and category budgets
• Leftover you can move to DayEarn

Tap **Approve & Activate** on the next screen to turn this into your live plan.''';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        title: Text(
          'DayFlow AI',
          style: TextStyle(
            fontFamily: 'FunnelDisplay',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20, color: onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'End Chat',
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.purple500ForTheme(context),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              itemCount: _messages.length + (_thinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (_thinking && index == _messages.length) {
                  return _Bubble(
                    text: 'DayFlow is thinking…',
                    isUser: false,
                    isTyping: true,
                  );
                }
                final msg = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _Bubble(text: msg.text, isUser: msg.isUser),
                );
              },
            ),
          ),
          if (_messages.length <= 1)
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                itemCount: _quickPrompts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final prompt = _quickPrompts[i];
                  return ActionChip(
                    label: Text(
                      prompt,
                      style: const TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () => _send(prompt),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(
                      color: onSurface.withValues(alpha: 0.12),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        DayFlowChatUi.chipRadius,
                      ),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(18, 8, 18, 12 + bottomInset),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _send,
                    decoration: InputDecoration(
                      hintText: 'Message DayFlow…',
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    TopSnackbar.show(
                      context,
                      message: 'Voice input coming soon',
                    );
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/svgs/phone-call.svg',
                    height: 22,
                    color: onSurface.withValues(alpha: 0.55),
                  ),
                ),
                IconButton(
                  onPressed: () => _send(_controller.text),
                  icon: Icon(
                    Icons.send_rounded,
                    color: AppColors.purple500ForTheme(context),
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

class _Bubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isTyping;

  const _Bubble({
    required this.text,
    required this.isUser,
    this.isTyping = false,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final bg = isUser
        ? AppColors.primary400.withValues(alpha: 0.18)
        : Theme.of(context).colorScheme.surface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(DayFlowChatUi.bubbleRadius),
            border: isUser
                ? null
                : Border.all(color: onSurface.withValues(alpha: 0.08)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isUser) ...[
                  Text(
                    'DayFlow',
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary400,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  text,
                  style: DayFlowChatUi.body(context).copyWith(
                    fontStyle: isTyping ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
