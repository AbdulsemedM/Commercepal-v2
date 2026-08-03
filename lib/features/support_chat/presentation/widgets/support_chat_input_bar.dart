import 'package:flutter/material.dart';

import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/services/localization_service.dart';

class SupportChatInputBar extends StatefulWidget {
  const SupportChatInputBar({
    super.key,
    required this.onSend,
    this.enabled = true,
    this.isSending = false,
  });

  final ValueChanged<String> onSend;
  final bool enabled;
  final bool isSending;

  @override
  State<SupportChatInputBar> createState() => _SupportChatInputBarState();
}

class _SupportChatInputBarState extends State<SupportChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!widget.enabled || widget.isSending || !_hasText) return;
    final text = _controller.text.trim();
    _controller.clear();
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool canSend =
        widget.enabled && !widget.isSending && _hasText;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.md,
          Spacing.xs,
          Spacing.md,
          Spacing.sm,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled && !widget.isSending,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: LocalizationService.t(
                      context,
                      'supportChat.typeMessage',
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.sm,
                    ),
                  ),
                  minLines: 1,
                  maxLines: 4,
                ),
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Material(
              color: canSend ? AppColors.primary : scheme.outlineVariant,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: canSend ? _submit : null,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: widget.isSending
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
