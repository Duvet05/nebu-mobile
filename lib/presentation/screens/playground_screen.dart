import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/personality.dart';
import '../providers/personality_provider.dart';

class PlaygroundScreen extends ConsumerStatefulWidget {
  const PlaygroundScreen({this.initialPersonality, super.key});

  final Personality? initialPersonality;

  @override
  ConsumerState<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends ConsumerState<PlaygroundScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  Personality? _selectedPersonality;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _selectedPersonality = widget.initialPersonality;
    if (_selectedPersonality != null) {
      _addGreeting(_selectedPersonality!);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addGreeting(Personality personality) {
    final greeting = personality.greeting ??
        'playground.default_greeting'.tr(args: [personality.name]);
    setState(() {
      _messages.add(_ChatMessage(
        text: greeting,
        isUser: false,
        personality: personality.name,
      ));
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _selectedPersonality == null) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isSending = true;
    });
    _messageController.clear();

    _scrollToBottom();

    // Simulate local response (no backend call for playground)
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          text: _generateLocalResponse(text, _selectedPersonality!),
          isUser: false,
          personality: _selectedPersonality!.name,
        ));
        _isSending = false;
      });
      _scrollToBottom();
    });
  }

  String _generateLocalResponse(String userMessage, Personality personality) {
    final category = personality.category?.toLowerCase() ?? '';

    return switch (category) {
      'educativo' => 'playground.response_educativo'.tr(args: [userMessage]),
      'entretenimiento' =>
        'playground.response_entretenimiento'.tr(args: [userMessage]),
      'companero' => 'playground.response_companero'.tr(args: [userMessage]),
      'creativo' => 'playground.response_creativo'.tr(args: [userMessage]),
      'aventura' => 'playground.response_aventura'.tr(args: [userMessage]),
      'bienestar' => 'playground.response_bienestar'.tr(args: [userMessage]),
      _ => 'playground.response_default'.tr(args: [personality.name]),
    };
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('playground.title'.tr()),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => setState(() {
                _messages.clear();
                if (_selectedPersonality != null) {
                  _addGreeting(_selectedPersonality!);
                }
              }),
              tooltip: 'playground.clear_chat'.tr(),
            ),
        ],
      ),
      body: Column(
        children: [
          // Personality selector
          _buildPersonalitySelector(theme),

          // Local mode banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.alertPadding,
              vertical: context.spacing.buttonBottomMargin,
            ),
            color: context.colors.warning.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(Icons.wifi_off, size: 16, color: context.colors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'playground.local_mode_banner'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.colors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(context.spacing.alertPadding),
                    itemCount: _messages.length + (_isSending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _messages.length) {
                        return _buildTypingIndicator(theme);
                      }
                      return _buildMessageBubble(
                        _messages[index],
                        theme,
                      );
                    },
                  ),
          ),

          // Input bar
          _buildInputBar(theme),
        ],
      ),
    );
  }

  Widget _buildPersonalitySelector(ThemeData theme) {
    final personalitiesAsync = ref.watch(personalitiesProvider);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.alertPadding,
        vertical: context.spacing.buttonBottomMargin,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
        ),
      ),
      child: personalitiesAsync.when(
        data: (personalities) => DropdownButtonFormField<String>(
          key: ValueKey(_selectedPersonality?.id),
          initialValue: _selectedPersonality?.id,
          decoration: InputDecoration(
            labelText: 'playground.select_personality'.tr(),
            prefixIcon: const Icon(Icons.psychology),
            border: OutlineInputBorder(borderRadius: context.radius.input),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: personalities
              .map((p) => DropdownMenuItem(
                    value: p.id,
                    child: Text(p.name, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (id) {
            final p = personalities.firstWhere((p) => p.id == id);
            setState(() {
              _selectedPersonality = p;
              _messages.clear();
              _addGreeting(p);
            });
          },
        ),
        loading: () => const LinearProgressIndicator(),
        error: (_, _) => Text(
          'personalities.error_loading'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: context.colors.error,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.smart_toy_outlined,
              size: 80,
              color: context.colors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'playground.empty_title'.tr(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'playground.empty_message'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildMessageBubble(_ChatMessage message, ThemeData theme) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isUser ? 48 : 0,
          right: isUser ? 0 : 48,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? context.colors.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.panel),
            topRight: const Radius.circular(AppRadius.panel),
            bottomLeft: Radius.circular(isUser ? AppRadius.panel : AppRadius.checkbox),
            bottomRight: Radius.circular(isUser ? AppRadius.checkbox : AppRadius.panel),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser && message.personality != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.personality!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: context.colors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              message.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isUser
                    ? context.colors.textOnFilled
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(right: 48, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.panel),
              topRight: Radius.circular(AppRadius.panel),
              bottomRight: Radius.circular(AppRadius.panel),
              bottomLeft: Radius.circular(AppRadius.checkbox),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _BouncingDot(delay: i * 200),
              ),
            ),
          ),
        ),
      );

  Widget _buildInputBar(ThemeData theme) => Container(
        padding: EdgeInsets.all(context.spacing.alertPadding),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  enabled: _selectedPersonality != null,
                  decoration: InputDecoration(
                    hintText: _selectedPersonality != null
                        ? 'playground.message_hint'.tr()
                        : 'playground.select_first'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: context.radius.bottomSheet,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed:
                    _selectedPersonality != null && !_isSending
                        ? _sendMessage
                        : null,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      );
}

class _ChatMessage {
  _ChatMessage({
    required this.text,
    required this.isUser,
    this.personality,
  });
  final String text;
  final bool isUser;
  final String? personality;
}

class _BouncingDot extends StatefulWidget {
  const _BouncingDot({required this.delay});
  final int delay;

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _animation.value),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
}
