import 'package:flutter/material.dart';
import 'package:commercepal/core/constants/spacing.dart';

class ProductSpecifications extends StatelessWidget {
  const ProductSpecifications({
    super.key,
    required this.specifications,
  });

  final Map<String, String> specifications;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ...specifications.entries.map((MapEntry<String, String> entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: Spacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    '• ',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                            ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '${entry.key}: ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: entry.value,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

