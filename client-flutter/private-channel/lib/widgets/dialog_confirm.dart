import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

Future<bool?> showConfirm({
  required BuildContext context,
  required String title,
  double? contentWidth,
  String? contentMarkdown,
}) async {
  return showDialog<bool?>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      final appLocales = AppLocalizations.of(context);

      return AlertDialog(
        title: Text(title),
        content: (contentMarkdown != null)
            ? SingleChildScrollView(
                child: SizedBox(
                  width: contentWidth,
                  child: MarkdownBody(
                    data: contentMarkdown,
                  ),
                ),
              )
            : null,
        actions: <Widget>[
          TextButton(
            child: Text(appLocales.approve),
            onPressed: () {
              Navigator.of(context).pop<bool>(true);
            },
          ),
        ],
      );
    },
  );
}
