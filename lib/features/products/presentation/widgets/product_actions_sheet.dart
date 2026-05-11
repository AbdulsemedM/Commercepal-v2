import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:commercepal/services/localization_service.dart';

Future<void> showProductActionsSheet(
  BuildContext context, {
  required String productId,
  required String title,
  String? shareUrl,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: Text(
                LocalizationService.t(ctx, 'productActions.share'),
              ),
              onTap: () async {
                final url = shareUrl;
                Navigator.pop(ctx);
                final text = url != null && url.isNotEmpty
                    ? '$title\n$url'
                    : '$title\nID: $productId';
                await Share.share(text);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(
                LocalizationService.t(ctx, 'productActions.copyLink'),
              ),
              onTap: () async {
                final url = shareUrl;
                final link =
                    url != null && url.isNotEmpty ? url : 'product:$productId';
                await Clipboard.setData(ClipboardData(text: link));
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        LocalizationService.t(
                          context,
                          'productActions.copied',
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.open_in_browser),
              title: Text(
                LocalizationService.t(ctx, 'productActions.openBrowser'),
              ),
              onTap: () async {
                final url = shareUrl;
                Navigator.pop(ctx);
                if (url == null || url.isEmpty) return;
                final uri = Uri.tryParse(url);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
