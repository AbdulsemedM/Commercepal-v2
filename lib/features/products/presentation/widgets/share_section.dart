import 'package:flutter/material.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';

class ShareSection extends StatelessWidget {
  const ShareSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Row(
        children: <Widget>[
          Text(
            '${LocalizationService.t(context, 'productDetail.share')}:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(width: Spacing.md),
          // Facebook icon
          IconButton(
            icon: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
            onPressed: () {
              // TODO: Handle Facebook share
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: Spacing.sm),
          // LinkedIn icon
          IconButton(
            icon: const Icon(Icons.business, color: Color(0xFF0077B5)),
            onPressed: () {
              // TODO: Handle LinkedIn share
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: Spacing.sm),
          // Twitter icon
          IconButton(
            icon: const Icon(Icons.alternate_email, color: Color(0xFF1DA1F2)),
            onPressed: () {
              // TODO: Handle Twitter share
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: Spacing.sm),
          // Email icon
          IconButton(
            icon: const Icon(Icons.email, color: Colors.grey),
            onPressed: () {
              // TODO: Handle Email share
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

