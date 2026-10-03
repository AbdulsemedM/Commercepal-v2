import 'package:flutter/material.dart';

import 'package:commercepal/core/design_system.dart';

/// Square product thumbnail for order lists; shows a neutral placeholder
/// when the URL is empty or fails to load.
class OrderItemThumbnail extends StatelessWidget {
  const OrderItemThumbnail({
    super.key,
    required this.url,
    this.size = 56,
    this.semanticLabel,
  });

  final String url;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Widget placeholder = Container(
      width: size,
      height: size,
      color: scheme.surfaceContainerHigh,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: size * 0.42,
        color: scheme.outline,
      ),
    );

    return Semantics(
      image: true,
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: AppRadius.smAll,
          border: Border.all(color: context.commerce.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: url.trim().isEmpty
            ? placeholder
            : AppNetworkImage(
                url: url,
                width: size,
                height: size,
                placeholder: placeholder,
                errorWidget: placeholder,
              ),
      ),
    );
  }
}
