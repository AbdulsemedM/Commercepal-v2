import 'dart:async';

import 'package:flutter/material.dart';

import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';

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
        final ColorScheme scheme = Theme.of(context).colorScheme;
        final bool active = isExpanded;
        return IconButton(
          tooltip: context.tr('checkout.hint.tooltip'),
          isSelected: active,
          onPressed: toggle,
          style: IconButton.styleFrom(
            minimumSize: const Size.square(AppSizes.minTouchTarget),
            foregroundColor: scheme.onSurfaceVariant,
            backgroundColor:
                active ? scheme.primaryContainer : Colors.transparent,
          ),
          icon: const Icon(Icons.info_outline_rounded),
          selectedIcon: Icon(Icons.info_rounded, color: scheme.primary),
        );
      },
    );
  }

  Widget buildBanner({required String message}) {
    return AnimatedBuilder(
      animation: _curved,
      builder: (BuildContext context, Widget? child) {
        // Reduced motion: jump straight to the end state.
        final double t = MediaQuery.disableAnimationsOf(context)
            ? (isExpanded ? 1.0 : 0.0)
            : _curved.value;
        if (t <= 0.001) {
          return const SizedBox.shrink();
        }
        return ClipRect(
          child: Align(
            alignment: AlignmentDirectional.topEnd,
            heightFactor: t,
            child: Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: child,
            ),
          ),
        );
      },
      child: Builder(
        builder: (BuildContext context) {
          final ThemeData theme = Theme.of(context);
          final CommerceColors commerce = context.commerce;
          return Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              Spacing.gutter,
              Spacing.sm,
              Spacing.gutter,
              Spacing.xs,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: commerce.infoContainer,
                borderRadius: AppRadius.mdAll,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.info_outline_rounded,
                    color: commerce.info,
                    size: AppSizes.iconMd,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: commerce.onInfoContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
