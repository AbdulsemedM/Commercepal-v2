import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/services/localization_service.dart';

/// Draggable floating button that opens support chat.
/// Stays on the left or right edge only (never the middle); Y is free within bounds.
class DraggableSupportChatFab extends StatefulWidget {
  const DraggableSupportChatFab({
    super.key,
    this.bottomNavClearance = 88,
  });

  /// Space reserved above the bottom navigation bar.
  final double bottomNavClearance;

  @override
  State<DraggableSupportChatFab> createState() =>
      _DraggableSupportChatFabState();
}

class _DraggableSupportChatFabState extends State<DraggableSupportChatFab> {
  static const double _fabSize = 56;
  static const double _edgeInset = 8;
  Offset? _offset;
  bool _loaded = false;
  bool _dragging = false;
  bool _moved = false;

  @override
  void initState() {
    super.initState();
    _loadOffset();
  }

  Future<void> _loadOffset() async {
    final saved = await Storage().getSupportChatFabOffset();
    if (!mounted) return;
    setState(() {
      if (saved != null) {
        _offset = Offset(saved.$1, saved.$2);
      }
      _loaded = true;
    });
  }

  double _leftX(EdgeInsets padding) => padding.left + _edgeInset;

  double _rightX(Size size, EdgeInsets padding) =>
      size.width - padding.right - _fabSize - _edgeInset;

  Offset _defaultOffset(Size size, EdgeInsets padding) {
    return Offset(
      _rightX(size, padding),
      size.height - widget.bottomNavClearance - padding.bottom - _fabSize - 16,
    );
  }

  Offset _clampVertical(Offset raw, Size size, EdgeInsets padding) {
    final double minY = padding.top + _edgeInset;
    final double maxY =
        size.height - widget.bottomNavClearance - padding.bottom - _fabSize - _edgeInset;
    return Offset(
      raw.dx,
      raw.dy.clamp(minY, maxY > minY ? maxY : minY),
    );
  }

  /// Snaps horizontally to the nearer side (left or right edge only).
  Offset _snapToSide(Offset raw, Size size, EdgeInsets padding) {
    final Offset clamped = _clampVertical(raw, size, padding);
    final double left = _leftX(padding);
    final double right = _rightX(size, padding);
    final double midX = size.width / 2;
    final double fabCenterX = clamped.dx + _fabSize / 2;
    final double snappedX = fabCenterX < midX ? left : right;
    return Offset(snappedX, clamped.dy);
  }

  Future<void> _persist(Offset offset) async {
    await Storage().saveSupportChatFabOffset(offset.dx, offset.dy);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();

    final Size size = MediaQuery.sizeOf(context);
    final EdgeInsets padding = MediaQuery.paddingOf(context);
    final Offset pos = _dragging
        ? _clampVertical(
            _offset ?? _defaultOffset(size, padding),
            size,
            padding,
          )
        : _snapToSide(
            _offset ?? _defaultOffset(size, padding),
            size,
            padding,
          );

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: GestureDetector(
        onPanStart: (_) {
          _moved = false;
          setState(() => _dragging = true);
        },
        onPanUpdate: (details) {
          if (details.delta.distance > 0.5) _moved = true;
          setState(() {
            _offset = _clampVertical(pos + details.delta, size, padding);
          });
        },
        onPanEnd: (_) {
          final snapped = _snapToSide(_offset ?? pos, size, padding);
          setState(() {
            _dragging = false;
            _offset = snapped;
          });
          _persist(snapped);
        },
        onTap: () {
          if (_moved) return;
          context.push(AppRoutes.supportChat);
        },
        child: Semantics(
          button: true,
          label: LocalizationService.t(context, 'supportChat.openChat'),
          child: Material(
            elevation: _dragging ? 8 : 4,
            shape: const CircleBorder(),
            color: AppColors.primary,
            child: SizedBox(
              width: _fabSize,
              height: _fabSize,
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
