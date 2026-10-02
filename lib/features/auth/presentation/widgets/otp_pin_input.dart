import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';

/// Six-digit OTP input with auto-advance and optional auto-submit.
class OtpPinInput extends StatefulWidget {
  const OtpPinInput({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.enabled = true,
    this.length = 6,
    this.hasError = false,
  });

  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final int length;

  /// Paints every box in the theme's error colour.
  final bool hasError;

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
    if (mounted) setState(() {});
  }

  void _notifyChanged() {
    // Repaint so filled boxes pick up their filled style.
    setState(() {});
    final value = code;
    widget.onChanged?.call(value);
    if (value.length == widget.length &&
        RegExp(r'^\d+$').hasMatch(value)) {
      widget.onCompleted(value);
    }
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste / autofill of the full code into one box.
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

  OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: AppRadius.mdAll,
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final TextStyle? digitStyle = theme.textTheme.headlineSmall?.copyWith(
      color: widget.hasError ? scheme.error : scheme.onSurface,
      fontFeatures: AppTypography.tabularFigures,
    );

    // Codes are always read left-to-right, even in Arabic.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Semantics(
        container: true,
        label: context.tr('auth.reset.verificationCode'),
        child: Row(
          children: <Widget>[
            for (int index = 0; index < widget.length; index++) ...<Widget>[
              if (index > 0) const SizedBox(width: Spacing.xs),
              Expanded(child: _buildBox(context, index, scheme, digitStyle)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBox(
    BuildContext context,
    int index,
    ColorScheme scheme,
    TextStyle? digitStyle,
  ) {
    final bool filled = _controllers[index].text.isNotEmpty;
    final Color idle = widget.hasError
        ? scheme.error
        : (filled ? scheme.onSurfaceVariant : scheme.outline);
    final Color focused = widget.hasError ? scheme.error : scheme.primary;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 56),
        child: Semantics(
          label: context.tr('auth.otp.digitLabel', <String, Object?>{
            'index': index + 1,
            'count': widget.length,
          }),
          textField: true,
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
              textInputAction: index == widget.length - 1
                  ? TextInputAction.done
                  : TextInputAction.next,
              autofillHints: index == 0
                  ? const <String>[AutofillHints.oneTimeCode]
                  : null,
              // Allow paste of full code; onChanged distributes digits.
              maxLength: widget.length,
              style: digitStyle,
              cursorColor: focused,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: widget.hasError
                    ? scheme.errorContainer.withValues(alpha: 0.35)
                    : (filled
                        ? scheme.surfaceContainerHigh
                        : scheme.surface),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: Spacing.md,
                ),
                border: _border(idle, 1),
                enabledBorder: _border(idle, filled ? 1.5 : 1),
                disabledBorder: _border(scheme.outlineVariant, 1),
                focusedBorder: _border(focused, 2),
              ),
              onChanged: (value) => _onChanged(index, value),
            ),
          ),
        ),
      ),
    );
  }
}
