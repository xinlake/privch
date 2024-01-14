import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:xinlake_text/validators.dart' as xv;
import 'package:xinlake_tunnel/shadowsocks.dart';

import '../config.dart' as config;
import '../providers/shadowsocks_provider.dart';

class ShadowsocksView extends StatefulWidget {
  const ShadowsocksView({super.key});

  @override
  State<ShadowsocksView> createState() {
    return _State();
  }
}

class _State extends State<ShadowsocksView> {
  late AppLocalizations _appLocales;

  final _nameEditing = TextEditingController();
  final _addressEditing = TextEditingController();
  final _portEditing = TextEditingController();
  final _passwordEditing = TextEditingController();

  Widget _buildLead() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ssQrcode(),
        Expanded(
          child: SingleChildScrollView(
            child: _buildShadowsocks(),
          ),
        ),
      ],
    );
  }

  Widget _buildShadowsocks() {
    final borderColor = Theme.of(context).splashColor;

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      children: [
        TableRow(
          children: [
            _optionLabel(_appLocales.ssName),
            Padding(
              padding: EdgeInsets.all(config.spacing),
              child: _ssName(borderColor),
            ),
          ],
        ),

        TableRow(
          children: [
            _optionLabel(_appLocales.ssAddress),
            Padding(
              padding: EdgeInsets.all(config.spacing),
              child: _ssAddress(borderColor),
            ),
          ],
        ),

        // port
        TableRow(
          children: [
            _optionLabel(_appLocales.ssPort),
            Padding(
              padding: EdgeInsets.all(config.spacing),
              child: _ssPort(borderColor),
            ),
          ],
        ),

        // password
        TableRow(
          children: [
            _optionLabel(_appLocales.ssPassword),
            Padding(
              padding: EdgeInsets.all(config.spacing),
              child: _ssPassword(borderColor),
            ),
          ],
        ),

        // encrypt
        TableRow(
          children: [
            _optionLabel(_appLocales.ssEncrypt),
            Padding(
              padding: EdgeInsets.all(config.spacing),
              child: _ssEncryption(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _ssQrcode() {
    final size = MediaQuery.of(context).size.shortestSide * 0.7;
    final colorBg = Theme.of(context).colorScheme.surface;
    final colorFg = Theme.of(context).colorScheme.inverseSurface;

    return Container(
      color: colorBg,
      alignment: Alignment.center,
      child: Consumer<ShadowsocksProvider>(
        builder: (context, ssProvider, child) {
          return QrImageView(
            padding: EdgeInsets.all(size * 0.07),
            data: ssProvider.encodeBase64(),
            version: QrVersions.auto,
            size: size,
            eyeStyle: QrEyeStyle(
              color: colorFg,
              eyeShape: QrEyeShape.circle,
            ),
            dataModuleStyle: QrDataModuleStyle(
              color: colorFg,
              dataModuleShape: QrDataModuleShape.circle,
            ),
          );
        },
      ),
    );
  }

  Widget _ssName(Color borderColor) {
    return Consumer<ShadowsocksProvider>(
      builder: (context, ssProvider, child) {
        return _ssValue(
          borderColor: borderColor,
          suffixIcon: (ssProvider.nameChange != ssProvider.name)
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // cancel
                    if (ssProvider.enableRestore)
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _nameEditing.clearComposing();
                          _nameEditing.text = ssProvider.name;
                          ssProvider.resetNameChange();
                        },
                        icon: const Icon(Icons.undo),
                      ),

                    // update
                    if (ssProvider.nameChange != null)
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          _nameEditing.clearComposing();

                          ssProvider.setName(
                            ssProvider.nameChange!,
                          );
                        },
                        icon: const Icon(Icons.check),
                      ),
                  ],
                )
              : null,
          controller: _nameEditing,
          onChanged: (value) {
            ssProvider.nameChange = value.isNotEmpty ? value : null;
          },
          validator: (value) {
            return (ssProvider.nameChange != null && ssProvider.nameChange!.isNotEmpty)
                ? null
                : _appLocales.invalidName;
          },
        );
      },
    );
  }

  Widget _ssAddress(Color borderColor) {
    return Consumer<ShadowsocksProvider>(
      builder: (context, ssProvider, child) {
        return _ssValue(
          borderColor: borderColor,
          keyboardType: TextInputType.number,
          suffixIcon: (ssProvider.addressChange != ssProvider.address)
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // cancel
                    if (ssProvider.enableRestore)
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _addressEditing.clearComposing();
                          _addressEditing.text = ssProvider.address;
                          ssProvider.resetAddressChange();
                        },
                        icon: const Icon(Icons.undo),
                      ),

                    // update
                    if (ssProvider.addressChange != null)
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          _addressEditing.clearComposing();

                          ssProvider.setAddress(
                            ssProvider.addressChange!,
                          );
                        },
                        icon: const Icon(Icons.check),
                      ),
                  ],
                )
              : null,
          controller: _addressEditing,
          onChanged: (value) {
            ssProvider.addressChange = xv.isIP(value) ? value : null;
          },
          validator: (value) {
            return (ssProvider.addressChange != null && ssProvider.addressChange!.isNotEmpty)
                ? null
                : _appLocales.invalidIpAddress;
          },
        );
      },
    );
  }

  Widget _ssPort(Color borderColor) {
    return Consumer<ShadowsocksProvider>(
      builder: (context, ssProvider, child) {
        return _ssValue(
          borderColor: borderColor,
          keyboardType: TextInputType.number,
          suffixIcon: (ssProvider.portChange != ssProvider.port)
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // cancel
                    if (ssProvider.enableRestore)
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _portEditing.clearComposing();
                          _portEditing.text = ssProvider.port.toString();
                          ssProvider.resetPortChange();
                        },
                        icon: const Icon(Icons.undo),
                      ),

                    // update
                    if (ssProvider.portChange != null)
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          _portEditing.clearComposing();

                          ssProvider.setPort(
                            ssProvider.portChange!,
                          );
                        },
                        icon: const Icon(Icons.check),
                      ),
                  ],
                )
              : null,
          controller: _portEditing,
          onChanged: (value) {
            ssProvider.portChange = xv.getNumberInRange(
              value,
              min: 1000,
              max: 65535,
            );
          },
          validator: (value) {
            return (ssProvider.portChange != null &&
                    ssProvider.portChange! >= 1000 &&
                    ssProvider.portChange! <= 65535)
                ? null
                : _appLocales.invalidPortNumber;
          },
        );
      },
    );
  }

  Widget _ssPassword(Color borderColor) {
    return Consumer<ShadowsocksProvider>(
      builder: (context, ssProvider, child) {
        return _ssValue(
          obscureText: ssProvider.passwordInvisible,
          borderColor: borderColor,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  ssProvider.passwordInvisible = !ssProvider.passwordInvisible;
                },
                icon: Icon(
                  ssProvider.passwordInvisible ? Icons.visibility : Icons.visibility_off,
                ),
              ),
              if (ssProvider.passwordChange != ssProvider.password)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // cancel
                    if (ssProvider.enableRestore)
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _passwordEditing.clearComposing();
                          _passwordEditing.text = ssProvider.password;
                          ssProvider.resetPasswordChange();
                        },
                        icon: const Icon(Icons.undo),
                      ),

                    // update
                    if (ssProvider.passwordChange != null)
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          _passwordEditing.clearComposing();

                          ssProvider.setPassword(
                            ssProvider.passwordChange!,
                          );
                        },
                        icon: const Icon(Icons.check),
                      ),
                  ],
                ),
            ],
          ),
          controller: _passwordEditing,
          onChanged: (value) {
            ssProvider.passwordChange = value.isNotEmpty ? value : null;
          },
          validator: (value) {
            return (ssProvider.passwordChange != null && ssProvider.passwordChange!.isNotEmpty)
                ? null
                : _appLocales.invalidPassword;
          },
        );
      },
    );
  }

  Widget _ssEncryption() {
    return Consumer<ShadowsocksProvider>(
      builder: (context, ShadowsocksProvider shadowsocksProvider, child) {
        return ElevatedButton(
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (context) {
                final selectionColor = Theme.of(context).colorScheme.primary;

                return Dialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // title
                      Text(
                        "Encryption",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),

                      Padding(
                        padding: EdgeInsets.all(config.spacing),
                        child: Wrap(
                          spacing: config.spacing,
                          runSpacing: config.spacing,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: Shadowsocks.encryptMethods.map((encryption) {
                            bool selected = encryption == shadowsocksProvider.encrypt;
                            return selected
                                ? Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: selectionColor,
                                      ),
                                      borderRadius: BorderRadius.circular(config.spacing * 8),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: config.spacing * 2,
                                      vertical: config.spacing,
                                    ),
                                    child: Text(
                                      encryption.toUpperCase(),
                                    ),
                                  )
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: config.spacing * 2,
                                        vertical: config.spacing,
                                      ),
                                    ),
                                    onPressed: () {
                                      shadowsocksProvider.setEncrypt(encryption);
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Text(
                                      encryption.toUpperCase(),
                                    ),
                                  );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Text(
            shadowsocksProvider.encrypt.toUpperCase(),
          ),
        );
      },
    );
  }

  Widget _ssValue({
    bool obscureText = false,
    TextInputType? keyboardType,
    required Color borderColor,
    String? labelText,
    Widget? suffixIcon,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    final labelColor = Theme.of(context).hintColor;

    return TextFormField(
      magnifierConfiguration: TextMagnifierConfiguration.disabled,
      spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
      enableSuggestions: false,
      autocorrect: false,
      obscureText: obscureText,
      obscuringCharacter: '•',
      minLines: 1,
      maxLines: 1,
      keyboardType: keyboardType,
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        isDense: true,
        // https://github.com/flutter/flutter/issues/18751
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.spacing),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: borderColor,
          ),
          borderRadius: BorderRadius.circular(config.spacing),
        ),
        labelText: labelText,
        labelStyle: TextStyle(color: labelColor),
        suffixIcon: suffixIcon,
      ),
      controller: controller,
      autovalidateMode: AutovalidateMode.always,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _optionLabel(
    String label, {
    EdgeInsetsGeometry? padding,
  }) {
    return Padding(
      padding: padding ?? EdgeInsets.all(config.spacing),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _appLocales = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            final ss = context.read<ShadowsocksProvider>();
            Navigator.of(context).pop(ss);
          }
        },
        child: _buildLead(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final ss = context.read<ShadowsocksProvider>();

    _nameEditing.text = ss.name;
    _addressEditing.text = ss.address;
    _portEditing.text = ss.port.toString();
    _passwordEditing.text = ss.password;
  }

  @override
  void dispose() {
    _nameEditing.dispose();
    _addressEditing.dispose();
    _portEditing.dispose();
    _passwordEditing.dispose();

    super.dispose();
  }
}
