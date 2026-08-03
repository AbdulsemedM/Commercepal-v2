import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/features/support_chat/bloc/support_chat_cubit.dart';
import 'package:commercepal/features/support_chat/presentation/widgets/support_chat_input_bar.dart';
import 'package:commercepal/features/support_chat/presentation/widgets/support_message_bubble.dart';
import 'package:commercepal/features/support_chat/presentation/widgets/support_quick_actions.dart';
import 'package:commercepal/services/localization_service.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final ScrollController _scrollController = ScrollController();
  int _lastMessageCount = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  String _statusLabel(BuildContext context, SupportChatLoaded state) {
    final status = state.sessionStatus.toUpperCase();
    final agent = state.agentName?.trim();
    if (agent != null && agent.isNotEmpty) {
      return agent;
    }
    if (status == 'WAITING' || state.escalated) {
      return LocalizationService.t(context, 'supportChat.waitingForAgent');
    }
    return LocalizationService.t(context, 'supportChat.aiOnly');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              LocalizationService.t(context, 'supportChat.title'),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            BlocBuilder<SupportChatCubit, SupportChatState>(
              buildWhen: (a, b) =>
                  a is SupportChatLoaded != b is SupportChatLoaded ||
                  (a is SupportChatLoaded &&
                      b is SupportChatLoaded &&
                      (a.sessionStatus != b.sessionStatus ||
                          a.agentName != b.agentName ||
                          a.escalated != b.escalated)),
              builder: (context, state) {
                if (state is! SupportChatLoaded) {
                  return const SizedBox.shrink();
                }
                return Text(
                  '● ${_statusLabel(context, state)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: BlocConsumer<SupportChatCubit, SupportChatState>(
        listener: (context, state) {
          if (state is SupportChatLoaded) {
            if (state.messages.length != _lastMessageCount) {
              _lastMessageCount = state.messages.length;
              _scrollToBottom();
            }
            if (state.sendError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.sendError!)),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is SupportChatLoading || state is SupportChatInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SupportChatError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: Spacing.md),
                    FilledButton(
                      onPressed: () =>
                          context.read<SupportChatCubit>().retry(),
                      child: Text(
                        LocalizationService.t(context, 'supportChat.retry'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final loaded = state as SupportChatLoaded;
          return Column(
            children: <Widget>[
              Expanded(
                child: loaded.messages.isEmpty && loaded.showWelcome
                    ? _WelcomeHint()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          vertical: Spacing.md,
                        ),
                        itemCount: loaded.messages.length,
                        itemBuilder: (context, index) {
                          return SupportMessageBubble(
                            message: loaded.messages[index],
                          );
                        },
                      ),
              ),
              SupportQuickActions(
                enabled: !loaded.isSending,
                onSelected: (text) =>
                    context.read<SupportChatCubit>().sendMessage(text),
              ),
              const SizedBox(height: Spacing.xs),
              SupportChatInputBar(
                isSending: loaded.isSending,
                onSend: (text) =>
                    context.read<SupportChatCubit>().sendMessage(text),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: Text(
                  LocalizationService.t(context, 'supportChat.poweredBy'),
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WelcomeHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.support_agent,
              size: 56,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              LocalizationService.t(context, 'supportChat.welcomeHint'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
