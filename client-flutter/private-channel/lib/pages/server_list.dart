import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:xinlake_platform/xinlake_platform.dart' as xp;
import 'package:xinlake_qrcode/xinlake_qrcode.dart' as xq;
import 'package:xinlake_tunnel/xinlake_tunnel.dart' as xt;

import '../config.dart' as config;
import '../providers/server_provider.dart';
import '../widgets/dialog_confirm.dart';

class ShadowsocksList extends StatefulWidget {
  const ShadowsocksList({
    required this.appBarColor,
    super.key,
  });

  final Color appBarColor;

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ShadowsocksList> {
  final _sortMenuController = MenuController();
  late AppLocalizations _appLocales;

  void _onItemDetail(
    BuildContext context,
    ServerProvider serverState,
    xt.Shadowsocks shadowsocks,
  ) async {
    // navigate to shadowsocks details
    final ss = await Navigator.of(context).pushNamed<xt.Shadowsocks>(
      config.AppRoute.shadowsocks,
      arguments: (shadowsocks, false),
    );

    if (ss != null) {
      if (shadowsocks == serverState.selected) {
        await xt.stopTunnel();
        // update selection
        await serverState.setSelected(ss);
      }

      await serverState.delete(shadowsocks);
      await serverState.put(ss);
    }
  }

  Future<void> _onItemRemove(
    BuildContext context,
    ServerProvider serverState,
    xt.Shadowsocks shadowsocks,
  ) async {
    // remove the server
    await serverState.delete(shadowsocks);

    // cancel remove
    if (context.mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text("${shadowsocks.name} ${_appLocales.removed}"),
          action: SnackBarAction(
            label: _appLocales.undo,
            onPressed: () async {
              await serverState.put(shadowsocks);
            },
          ),
        ),
      );
    }
  }

  Future<void> _importFromScreenshot() async {
    final codeList = await xq.readScreen();
    if (codeList == null || codeList.isEmpty) {
      return;
    }

    final ssList = <xt.Shadowsocks>[];
    for (final qrcode in codeList) {
      final shadowsocks = xt.Shadowsocks.parserQrCode(qrcode);
      if (shadowsocks != null) {
        ssList.add(shadowsocks);
      }
    }

    if (mounted) {
      final serverProvider = context.read<ServerProvider>();
      if (ssList.isNotEmpty) {
        await serverProvider.putAll(ssList);
      }

      // set recent adding method
      await serverProvider.setImportMethod(ServerAddingMethod.scanScreen);
    }
  }

  Future<void> _importFromCamera() async {
    final qrcode = await xq.fromCamera(
      prefix: "ss://",
      playBeep: true,
    );
    if (qrcode == null) {
      return;
    }

    if (mounted) {
      final serverProvider = context.read<ServerProvider>();
      final shadowsocks = xt.Shadowsocks.parserQrCode(qrcode);
      if (shadowsocks != null) {
        await context.read<ServerProvider>().put(
          shadowsocks,
          onOverWrite: () {
            // snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${shadowsocks.name} updated"),
                  ],
                ),
              ),
            );

            return true;
          },
        );
      }

      // set recent adding method
      await serverProvider.setImportMethod(ServerAddingMethod.scanQrcode);
    }
  }

  Future<void> _importFromImage() async {
    final images = await xp.pickFile(
      multiSelection: true,
      mimeTypes: "image/*",
      cacheDir: xp.AndroidAppDir.externalFiles,
      typesDescription: "Images",
    );
    if (images == null || images.isEmpty) {
      return;
    }

    final codeList = await xq.readImage(images.map((file) => file.path!).toList());
    if (codeList == null || codeList.isEmpty) {
      return;
    }

    final ssList = <xt.Shadowsocks>[];
    for (final qrcode in codeList) {
      final shadowsocks = xt.Shadowsocks.parserQrCode(qrcode);
      if (shadowsocks != null) {
        ssList.add(shadowsocks);
      }
    }

    if (mounted) {
      final serverProvider = context.read<ServerProvider>();
      if (ssList.isNotEmpty) {
        await serverProvider.putAll(ssList);
      }

      // set recent adding method
      await serverProvider.setImportMethod(ServerAddingMethod.importImage);
    }
  }

  Future<void> _createServer() async {
    final shadowsocks = await Navigator.of(context).pushNamed<xt.Shadowsocks>(
      config.AppRoute.shadowsocks,
      arguments: (
        xt.Shadowsocks(
          name: config.dateFormatShort.format(DateTime.now()),
          address: "",
          port: 0,
          password: "",
          encrypt: xt.Shadowsocks.encryptDefault,
        ),
        true,
      ),
    );

    if (mounted) {
      final serverProvider = context.read<ServerProvider>();
      if (shadowsocks != null && shadowsocks.isValid) {
        serverProvider.put(shadowsocks);
      }

      await serverProvider.setImportMethod(ServerAddingMethod.create);
    }
  }

  Widget _serverAction({EdgeInsetsGeometry? padding}) {
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: config.spacing),
      color: widget.appBarColor,
      child: Row(
        children: [
          // add server
          Consumer<ServerProvider>(
            builder: (context, serverState, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MenuAnchor(
                    builder: (context, controller, child) {
                      return IconButton(
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                        icon: const Icon(Icons.add_circle),
                      );
                    },
                    menuChildren: [
                      Platform.isWindows
                          ? MenuItemButton(
                              onPressed: () async => await _importFromScreenshot(),
                              child: Text(_appLocales.importFromScreenshot),
                            )
                          : MenuItemButton(
                              onPressed: () async => await _importFromCamera(),
                              child: Text(_appLocales.importFromScanner),
                            ),
                      MenuItemButton(
                        onPressed: () async => await _importFromImage(),
                        child: Text(_appLocales.importFromImage),
                      ),
                      MenuItemButton(
                        onPressed: () async => await _createServer(),
                        child: Text(_appLocales.createServer),
                      ),
                    ],
                  ),

                  // recent adding method
                  if (serverState.importMethod != null)
                    IconButton(
                      onPressed: switch (serverState.importMethod!) {
                        ServerAddingMethod.scanScreen => () async => await _importFromScreenshot(),
                        ServerAddingMethod.scanQrcode => () async => await _importFromCamera(),
                        ServerAddingMethod.importImage => () async => await _importFromImage(),
                        ServerAddingMethod.create => () async => await _createServer(),
                      },
                      icon: Icon(
                        switch (serverState.importMethod!) {
                          ServerAddingMethod.scanScreen => Icons.screenshot_monitor,
                          ServerAddingMethod.scanQrcode => Icons.qr_code_scanner,
                          ServerAddingMethod.importImage => Icons.image,
                          ServerAddingMethod.create => Icons.edit_note,
                        },
                      ),
                    ),
                ],
              );
            },
          ),

          const Spacer(),

          // sort
          MenuAnchor(
            controller: _sortMenuController,
            builder: (context, controller, child) {
              return Consumer<ServerProvider>(
                builder: (context, serverState, child) {
                  return MaterialButton(
                    clipBehavior: Clip.hardEdge,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(config.spacing),
                    ),
                    onPressed: serverState.serverEmpty
                        ? null
                        : () {
                            if (controller.isOpen) {
                              controller.close();
                            } else {
                              controller.open();
                            }
                          },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.sort),
                        SizedBox(width: config.spacing),
                        // selected sort mode
                        Text(
                          _appLocales.sortBy(switch (serverState.sortMode) {
                            ServerSortMode.name => "name",
                            ServerSortMode.updated => "updated",
                            ServerSortMode.encrypt => "encrypt",
                          }),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            menuChildren: ServerSortMode.values.map(
              (sortMode) {
                return MenuItemButton(
                  onPressed: () {
                    context.read<ServerProvider>().setSortMode(sortMode);
                    _sortMenuController.close();
                  },
                  child: Text(
                    _appLocales.sortBy(switch (sortMode) {
                      ServerSortMode.name => "name",
                      ServerSortMode.updated => "updated",
                      ServerSortMode.encrypt => "encrypt",
                    }),
                  ),
                );
              },
            ).toList(),
          ),

          SizedBox(width: config.spacing),

          // more
          MenuAnchor(
            builder: (BuildContext context, MenuController controller, Widget? child) {
              return IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(Icons.more_vert),
              );
            },
            menuChildren: <Widget>[
              // clear
              Consumer<ServerProvider>(
                builder: (BuildContext context, ServerProvider serverState, Widget? child) {
                  return MenuItemButton(
                    onPressed: serverState.serverEmpty
                        ? null
                        : () async {
                            final confirm = await showConfirm(
                              context: context,
                              title: _appLocales.delAllServers,
                              contentMarkdown: _appLocales.delAllServersBody,
                            );
                            if (confirm == true) {
                              await serverState.deleteAll();
                            }
                          },
                    child: Text(_appLocales.delAllServers),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serverList({EdgeInsetsGeometry? padding}) {
    return Consumer<ServerProvider>(
      child: _emptyList(),
      builder: (BuildContext context, ServerProvider serverState, Widget? child) {
        if (serverState.serverEmpty) {
          return Center(
            child: child!,
          );
        }

        // dismiss
        const startToEndThresholds = 0.5;
        const endToStartThresholds = 0.5;
        const bgIconSize = 36.0;
        final bgColor = Theme.of(context).hoverColor;
        final activeDelete = Theme.of(context).colorScheme.error;
        final activeEdit = Theme.of(context).colorScheme.primary;

        // server
        final serverSelColor = Theme.of(context).colorScheme.primaryContainer;
        final serverTitleText = Theme.of(context).textTheme.titleLarge;
        final serverInfoText = Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            );

        // sort
        final ssList = serverState.serverList
          ..sort(
            switch (serverState.sortMode) {
              ServerSortMode.updated => (ss1, ss2) => -ss1.modified.compareTo(ss2.modified),
              ServerSortMode.name => (ss1, ss2) => ss1.name.compareTo(ss2.name),
              ServerSortMode.encrypt => (ss1, ss2) => ss1.encrypt.compareTo(ss2.encrypt),
            },
          );

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: padding ?? EdgeInsets.all(config.spacing),
          child: Column(
            children: ssList.map<Widget>((shadowsocks) {
              return Dismissible(
                key: Key(shadowsocks.hashCode.toString()),

                // Dismiss
                dismissThresholds: const {
                  DismissDirection.startToEnd: startToEndThresholds,
                  DismissDirection.endToStart: endToStartThresholds,
                },
                onUpdate: (details) {
                  if (details.direction == DismissDirection.startToEnd) {
                    serverState.dismissToDelete = details.progress > startToEndThresholds;
                  } else if (details.direction == DismissDirection.endToStart) {
                    serverState.dismissToEdit = details.progress > endToStartThresholds;
                  }
                },
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    // delete server
                    return true;
                  } else if (direction == DismissDirection.endToStart) {
                    _onItemDetail(context, serverState, shadowsocks);
                    return false;
                  }
                  return false;
                },
                onDismissed: (direction) async {
                  await _onItemRemove(context, serverState, shadowsocks);
                },

                // Background-left
                background: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: config.spacing),
                      child: const Icon(Icons.arrow_forward),
                    ),
                    SizedBox(
                      width: bgIconSize,
                      height: bgIconSize,
                      child: Center(
                        child: Icon(
                          Icons.delete,
                          color: serverState.dismissToDelete ? activeDelete : null,
                          size: serverState.dismissToDelete ? bgIconSize : null,
                        ),
                      ),
                    ),
                  ],
                ),

                // Background-right
                secondaryBackground: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: bgIconSize,
                      height: bgIconSize,
                      child: Center(
                        child: Icon(
                          Icons.edit,
                          color: serverState.dismissToEdit ? activeEdit : null,
                          size: serverState.dismissToEdit ? bgIconSize : null,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: config.spacing),
                      child: const Icon(Icons.arrow_back),
                    ),
                  ],
                ),

                // Server
                child: Container(
                  margin: EdgeInsets.only(bottom: config.spacing),
                  decoration: BoxDecoration(
                    color: (shadowsocks == serverState.selected) ? serverSelColor : bgColor,
                    borderRadius: BorderRadius.circular(config.spacing),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(config.spacing),
                    onTap: () async {
                      await serverState.setSelected(shadowsocks);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(config.spacing),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            shadowsocks.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: serverTitleText,
                          ),

                          // spacing
                          SizedBox(height: config.spacing),

                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                shadowsocks.encrypt.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: serverInfoText,
                              ),
                              Text(
                                config.dateFormatDay.format(
                                  DateTime.fromMillisecondsSinceEpoch(shadowsocks.modified),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: serverInfoText,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // the content when the list is empty
  Widget _emptyList() {
    final mqSize = MediaQuery.of(context).size;
    final titleText = Theme.of(context).textTheme.headlineMedium;
    final infoText = TextStyle(
      color: Theme.of(context).disabledColor,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _appLocales.addServer,
          style: titleText,
        ),
        Padding(
          padding: EdgeInsets.only(
            top: config.spacing,
            bottom: config.spacing * 2,
          ),
          child: Text(
            _appLocales.noServer,
            style: infoText,
          ),
        ),
        IntrinsicWidth(
          stepWidth: mqSize.width / 8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            // action buttons
            children: [
              Platform.isWindows
                  ? ElevatedButton(
                      onPressed: () async => await _importFromScreenshot(),
                      child: Text(_appLocales.importFromScreenshot),
                    )
                  : ElevatedButton(
                      onPressed: () async => await _importFromCamera(),
                      child: Text(_appLocales.importFromScanner),
                    ),

              // spacing
              SizedBox(height: config.spacing),

              ElevatedButton(
                onPressed: () async => await _importFromImage(),
                child: Text(_appLocales.importFromImage),
              ),

              // spacing
              SizedBox(height: config.spacing),

              ElevatedButton(
                onPressed: () async => await _createServer(),
                child: Text(_appLocales.createServer),
              ),
            ],
          ),
        ),

        // foot padding
        SizedBox(height: mqSize.height / 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _appLocales = AppLocalizations.of(context);

    return Column(
      children: [
        _serverAction(),
        Expanded(
          child: _serverList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
