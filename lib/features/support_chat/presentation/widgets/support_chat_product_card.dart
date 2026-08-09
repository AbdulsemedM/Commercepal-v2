import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/widgets/app_network_image.dart';
import 'package:commercepal/features/support_chat/data/models/support_chat_product.dart';

class SupportChatProductCard extends StatelessWidget {
  const SupportChatProductCard({super.key, required this.product});

  final SupportChatProduct product;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            final String query =
                'id=${Uri.encodeComponent(product.id)}&name=${Uri.encodeComponent(product.title)}';
            context.push('${AppRoutes.productDetail}?$query');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1,
                child: product.image != null && product.image!.isNotEmpty
                    ? AppNetworkImage(
                        url: product.image!,
                        fit: BoxFit.cover,
                      )
                    : ColoredBox(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_outlined),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(Spacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (product.price != null && product.price!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        product.price!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.pink,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
