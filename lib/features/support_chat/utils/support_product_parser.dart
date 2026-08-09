import 'dart:convert';

import 'package:commercepal/features/support_chat/data/models/support_chat_product.dart';

final RegExp supportProductsBlockRegex = RegExp(
  r'\[PRODUCTS\](.*?)\[/PRODUCTS\]',
  dotAll: true,
);

class ParsedSupportMessage {
  const ParsedSupportMessage({
    required this.textSegments,
    required this.products,
  });

  final List<String> textSegments;
  final List<SupportChatProduct> products;
}

ParsedSupportMessage parseSupportMessageProducts(String messageText) {
  final List<String> textSegments = <String>[];
  final List<SupportChatProduct> products = <SupportChatProduct>[];
  int lastEnd = 0;

  for (final RegExpMatch match in supportProductsBlockRegex.allMatches(messageText)) {
    final String before = messageText.substring(lastEnd, match.start).trim();
    if (before.isNotEmpty) {
      textSegments.add(before);
    }
    products.addAll(_parseProductsPayload(match.group(1) ?? ''));
    lastEnd = match.end;
  }

  final String trailing = messageText.substring(lastEnd).trim();
  if (trailing.isNotEmpty) {
    textSegments.add(trailing);
  }

  if (textSegments.isEmpty && products.isEmpty) {
    textSegments.add(messageText);
  }

  return ParsedSupportMessage(
    textSegments: textSegments,
    products: products,
  );
}

List<SupportChatProduct> _parseProductsPayload(String raw) {
  final String trimmed = raw.trim();
  if (trimmed.isEmpty) return <SupportChatProduct>[];

  try {
    final Object? decoded = jsonDecode(trimmed);
    if (decoded is List<dynamic>) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(SupportChatProduct.fromJson)
          .where((SupportChatProduct p) => p.id.isNotEmpty)
          .toList();
    }
    if (decoded is Map<String, dynamic>) {
      final SupportChatProduct product = SupportChatProduct.fromJson(decoded);
      return product.id.isEmpty ? <SupportChatProduct>[] : <SupportChatProduct>[product];
    }
  } catch (_) {
    return <SupportChatProduct>[];
  }
  return <SupportChatProduct>[];
}
