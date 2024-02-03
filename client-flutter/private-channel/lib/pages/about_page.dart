import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:privch/app/privch.dart';
import 'package:privch/config.dart' as config;
import 'package:privch/widgets/app_title.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xinlake_platform/xinlake_platform.dart' as xp;

Future<void> showAbout({
  required BuildContext context,
}) async {
  return showDialog(
    context: context,
    builder: (context) {
      const iconAsset = "_assets/Icons/app-192.png";

      final appLocales = AppLocalizations.of(context);
      final iconSize = MediaQuery.of(context).size.shortestSide * 0.13;

      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // title
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // logo
                Image.asset(
                  iconAsset,
                  width: iconSize,
                  height: iconSize,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // name
                      Padding(
                        padding: EdgeInsets.only(
                          left: config.spacing,
                          top: config.spacing,
                          bottom: config.spacing * 0.5,
                        ),
                        child: buildAppTitle(context),
                      ),
                      FutureBuilder<xp.VersionInfo?>(
                        future: xp.getAppVersion(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return Text(
                              "v${snapshot.data!.version}",
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            );
                          }

                          return const SizedBox();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(
              indent: 10,
              endIndent: 10,
              height: 20,
            ),

            // license
            TextButton(
              onPressed: () async {
                final verInfo = await xp.getAppVersion();
                if (context.mounted) {
                  showLicensePage(
                    context: context,
                    applicationVersion: verInfo?.version,
                    applicationIcon: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(iconAsset),
                    ),
                  );
                }
              },
              child: Text(appLocales.ossLicense),
            ),

            // privacy policy
            TextButton(
              onPressed: () async {
                await launchUrl(
                  Uri.parse(PrivCh.appPrivacyPolicy),
                  mode: LaunchMode.platformDefault,
                  webOnlyWindowName: "_blank",
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(appLocales.privacyPolicy),
                  const SizedBox(width: 8),
                  const Icon(Icons.open_in_new),
                ],
              ),
            )
          ],
        ),
      );
    },
  );
}
