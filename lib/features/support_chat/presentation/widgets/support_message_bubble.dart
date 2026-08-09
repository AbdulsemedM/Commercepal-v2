import 'package:flutter/material.dart';

import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/features/support_chat/data/models/support_message.dart';
import 'package:commercepal/features/support_chat/presentation/widgets/support_chat_product_card.dart';
import 'package:commercepal/features/support_chat/utils/support_product_parser.dart';
import 'package:commercepal/services/localization_service.dart';

class SupportMessageBubble extends StatelessWidget {
  const SupportMessageBubble({super.key, required this.message});

  final SupportMessage message;

  @override
  Widget build(BuildContext context) {
    final bool isCustomer = message.isCustomer;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final ParsedSupportMessage parsed =
        parseSupportMessageProducts(message.messageText);

    return Align(
      alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.xxs,
          ),
          child: Column(
            crossAxisAlignment:
                isCustomer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              if (!isCustomer)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 4),
                  child: Text(
                    message.isAgent
                        ? LocalizationService.t(
                            context,
                            'supportChat.agentLabel',
                          )
                        : LocalizationService.t(
                            context,
                            'supportChat.aiLabel',
                          ),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              for (final String segment in parsed.textSegments)
                if (segment.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: Spacing.xxs),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isCustomer
                          ? AppColors.primary
                          : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isCustomer ? 16 : 4),
                        bottomRight: Radius.circular(isCustomer ? 4 : 16),
                      ),
                    ),
                    child: Text(
                      segment,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.35,
                        color: isCustomer ? Colors.white : scheme.onSurface,
                      ),
                    ),
                  ),
              if (!isCustomer && parsed.products.isNotEmpty)
                SizedBox(
                  height: 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: parsed.products.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: Spacing.sm),
                    itemBuilder: (BuildContext context, int index) {
                      return SupportChatProductCard(
                        product: parsed.products[index],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
