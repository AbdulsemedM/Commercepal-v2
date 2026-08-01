import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';

/// Six-digit OTP input with auto-advance and optional auto-submit.
class OtpPinInput extends StatefulWidget {
  const OtpPinInput({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.enabled = true,
    this.length = 6,
  });

  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final int length;

  @override
  State<OtpPinInput> createState() => OtpPinInputState();
}

class OtpPinInputState extends State<OtpPinInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get code => _controllers.map((c) => c.text).join();

  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    if (_focusNodes.isNotEmpty) {
      _focusNodes.first.requestFocus();
    }
    widget.onChanged?.call('');
  }

  void _notifyChanged() {
    final value = code;
    widget.onChanged?.call(value);
    if (value.length == widget.length &&
        RegExp(r'^\d+$').hasMatch(value)) {
      widget.onCompleted(value);
    }
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste of full code into one box.
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < widget.length; i++) {
        _controllers[i].text =
            i < digits.length ? digits[i] : '';
      }
      final focusIndex = digits.length >= widget.length
          ? widget.length - 1
          : digits.length;
      _focusNodes[focusIndex].requestFocus();
      _notifyChanged();
      return;
    }

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    _notifyChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 48,
          child: Focus(
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace &&
                  _controllers[index].text.isEmpty &&
                  index > 0) {
                _controllers[index - 1].clear();
                _focusNodes[index - 1].requestFocus();
                _notifyChanged();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              enabled: widget.enabled,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              // Allow paste of full code; onChanged distributes digits.
              maxLength: widget.length,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppDecorations.softCream,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: Spacing.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: (value) => _onChanged(index, value),
            ),
          ),
        );
      }),
    );
  }
}
