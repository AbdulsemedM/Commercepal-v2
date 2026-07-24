import 'dart:async';

import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';

/// Coordinates the payment hint icon + banner that expands from / collapses
/// into the header info button.
class PaymentHintController extends ChangeNotifier {
  PaymentHintController({required TickerProvider vsync}) {
    _controller = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 420),
    );
    _curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _controller.addStatusListener(_onStatus);
  }

  late final AnimationController _controller;
  late final CurvedAnimation _curved;
  Timer? _autoHideTimer;
  bool _disposed = false;

  Animation<double> get animation => _curved;

  bool get isExpanded =>
      _controller.status == AnimationStatus.completed ||
      _controller.status == AnimationStatus.forward;

  void _onStatus(AnimationStatus status) {
    if (_disposed) return;
    if (status == AnimationStatus.completed) {
      _scheduleAutoHide();
    } else if (status == AnimationStatus.dismissed ||
        status == AnimationStatus.reverse) {
      _autoHideTimer?.cancel();
      _autoHideTimer = null;
    }
    notifyListeners();
  }

  void _scheduleAutoHide() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 5), () {
      if (_disposed) return;
      collapse();
    });
  }

  /// Expands the banner out of the icon (called on first open).
  void expand() {
    if (_disposed) return;
    _autoHideTimer?.cancel();
    _controller.forward();
  }

  /// Collapses the banner back into the icon.
  void collapse() {
    if (_disposed) return;
    _autoHideTimer?.cancel();
    _autoHideTimer = null;
    _controller.reverse();
  }

  /// Tap handler: expand if collapsed; collapse if expanded.
  void toggle() {
    if (_disposed) return;
    if (isExpanded || _controller.status == AnimationStatus.forward) {
      collapse();
    } else {
      expand();
    }
  }

  /// Starts the intro expand on the next frame.
  void startIntro() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed) return;
      expand();
    });
  }

  Widget buildIcon() {
    return ListenableBuilder(
      listenable: this,
      builder: (BuildContext context, Widget? child) {
        final bool active = isExpanded;
        return Material(
          color: active
              ? AppColors.pink.withValues(alpha: 0.12)
              : AppColors.cream,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: toggle,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active
                      ? AppColors.pink.withValues(alpha: 0.45)
                      : const Color(0xFFF0E6D8),
                ),
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: active ? AppColors.pink : AppColors.navy,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildBanner({required String message}) {
    return AnimatedBuilder(
      animation: _curved,
      builder: (BuildContext context, Widget? child) {
        final double t = _curved.value;
        if (t <= 0.001) {
          return const SizedBox.shrink();
        }
        return ClipRect(
          child: Align(
            alignment: Alignment.topRight,
            heightFactor: t,
            child: Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: Transform.scale(
                alignment: Alignment.topRight,
                scale: 0.88 + (0.12 * t),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.md,
          Spacing.md,
          Spacing.md,
          Spacing.sm,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: AppColors.pink.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.pink.withValues(alpha: 0.28),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.pink,
                size: 22,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _autoHideTimer?.cancel();
    _controller.removeStatusListener(_onStatus);
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }
}
