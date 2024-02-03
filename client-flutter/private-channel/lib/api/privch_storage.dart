import 'dart:convert';

import 'package:ed25519_edwards/ed25519_edwards.dart' as ed25519;
import 'package:flutter/foundation.dart';
import 'package:hashlib/hashlib.dart' as hashlib;
import 'package:http/http.dart' as http;
import 'package:privch/app/privch.dart';
import 'package:xinlake_text/validators.dart' as xtv;
import 'package:xinlake_tunnel/xinlake_tunnel.dart' as xtun;

Future<Map?> listServer() async {
  const maxRetry = 3;

  var pubIp = "";
  var retry = maxRetry;

  while (true) {
    try {
      final ipRespond = await http
          .get(
            Uri.parse(PrivCh.clientIpApi),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      if (ipRespond.statusCode == 200 && xtv.isIP(ipRespond.body)) {
        pubIp = ipRespond.body;
        break;
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }

    if (--retry < 0) {
      return null;
    } else {
      await Future.delayed(
        const Duration(seconds: 3),
      );
    }
  }

  retry = maxRetry;
  while (true) {
    try {
      final signature = ed25519.sign(
        ed25519.PrivateKey(
          base64.decode(PrivCh.storageEd25519Priv) + base64.decode(PrivCh.storageEd25519Pub),
        ),
        utf8.encode(
          hashlib.blake2b512.string(pubIp).hex(),
        ),
      );

      final listRespond = await http
          .post(
            Uri.parse(PrivCh.storageEndpoint),
            headers: {
              "content-type": "application/json",
            },
            body: json.encode(<String, String>{
              "signature": base64.encode(signature),
              "action": "list",
            }),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      if (listRespond.statusCode == 200) {
        final jsonBody = json.decode(
          utf8.decode(listRespond.bodyBytes),
        ) as Map;

        return jsonBody;
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }

    if (--retry < 0) {
      return null;
    } else {
      await Future.delayed(
        const Duration(seconds: 3),
      );
    }
  }
}

(String?, List<xtun.Shadowsocks>) parserServer(Map jsonData) {
  final version = jsonData["privch-version"] as String?;
  final result = jsonData["result"] as List?;

  final serverList = <xtun.Shadowsocks>[];

  if (result != null) {
    for (final map in result) {
      final name = map["name"] as String?;
      final content = map["content"] as String?;
      final modified = map["last-modified"] as String?;

      if (name != null && content != null && modified != null) {
        final modifiedTime = DateTime.tryParse(modified);

        for (final server in content.split('\n')) {
          final params = server.split(' ');
          if (params.length == 3) {
            final port = int.tryParse(params[0]) ?? 0;
            final encryption = params[1];
            final password = params[2];

            if (xtun.Shadowsocks.validate(
              address: name,
              port: port,
              encryption: encryption,
              password: password,
            )) {
              serverList.add(xtun.Shadowsocks(
                address: name,
                port: port,
                encryption: encryption,
                password: password,
                modified: modifiedTime?.millisecondsSinceEpoch,
              ));
            }
          }
        }
      }
    }
  }

  return (version, serverList);
}
