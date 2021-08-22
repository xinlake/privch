import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:privch/library/validator/validators.dart';
import 'package:privch/data/shadowsocks.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShadowsocksDetailPage extends StatefulWidget {
  ShadowsocksDetailPage(this.ssEdit, this.onSave);

  // Fields in a Widget subclass are always marked "final".
  final Shadowsocks ssEdit;
  final void Function(Shadowsocks) onSave;

  @override
  _ShadowsocksDetailPageState createState() => _ShadowsocksDetailPageState();
}

class _ShadowsocksDetailPageState extends State<ShadowsocksDetailPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _isFormChanged = false;
  bool _isEncryptChanged = false;

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSave(widget.ssEdit);
      Navigator.of(context).pop();
    } else {
      showDialog(
        context: context,
        builder: (buildContext) {
          // TODO style
          return AlertDialog(
            contentPadding: EdgeInsets.only(top: 20),
            title: Text('Save Changes'),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.warning,
                    size: 36,
                    color: Theme.of(context).errorColor,
                  ),
                  SizedBox(height: 10),
                  Text('Cannot save invalid info, Sorry!'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Expanded(
          child: Text(widget.ssEdit.name),
        ),
        IconButton(
          icon: Icon(Icons.check),
          onPressed: ((_isFormChanged || _isEncryptChanged) && _formKey.currentState!.validate())
              ? _save
              : null,
        ),
      ],
    );
  }

  Widget _buildForm() {
    InputDecoration inputDecoration = InputDecoration(
      hintStyle: TextStyle(fontStyle: FontStyle.italic),
      contentPadding: EdgeInsets.symmetric(vertical: 5),
    );

    return Form(
      key: _formKey,
      onChanged: () => setState(() => (_isFormChanged = true)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // server name
          TextFormField(
            autovalidateMode: AutovalidateMode.always,
            initialValue: widget.ssEdit.name,
            textAlignVertical: TextAlignVertical.bottom,
            decoration: inputDecoration.copyWith(labelText: "Display name"),
            validator: (value) {
              return (value != null && value.isNotEmpty) ? null : "Display name can't be empty";
            },
            onSaved: (value) {
              if (value != null) {
                widget.ssEdit.name = value;
              }
            },
          ),
          SizedBox(height: 20),
          // server address and port
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  initialValue: widget.ssEdit.address,
                  textAlignVertical: TextAlignVertical.bottom,
                  decoration: inputDecoration.copyWith(labelText: "Host address"),
                  validator: (value) {
                    return (value != null && isURL(value)) ? null : "Invalid host address";
                  },
                  onSaved: (value) {
                    if (value != null) {
                      widget.ssEdit.address = value;
                    }
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  keyboardType: TextInputType.number,
                  initialValue: "${widget.ssEdit.port}",
                  textAlignVertical: TextAlignVertical.bottom,
                  decoration: inputDecoration.copyWith(labelText: "Host port"),
                  validator: (value) {
                    return (value != null && isPort(value)) ? null : "Invalid port number";
                  },
                  onSaved: (value) {
                    if (value != null) {
                      widget.ssEdit.port = int.parse(value);
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // server password
          TextFormField(
            autovalidateMode: AutovalidateMode.always,
            obscureText: _obscureText,
            initialValue: widget.ssEdit.password,
            textAlignVertical: TextAlignVertical.bottom,
            decoration: inputDecoration.copyWith(
              labelText: "Password",
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscureText = !_obscureText);
                },
              ),
            ),
            validator: (value) {
              return (value != null && value.isNotEmpty) ? null : "Password can't be empty";
            },
            onSaved: (value) {
              if (value != null) {
                widget.ssEdit.password = value;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEncrypt() {
    String encryptSelection = widget.ssEdit.encrypt;
    StatefulBuilder dialogBuilder = StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        contentPadding: EdgeInsets.only(left: 10, right: 10, top: 20),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Encrypt Method"),
            Text(
              encryptSelection.toUpperCase(),
              style: Theme.of(context).textTheme.subtitle2?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
        content: Column(
          children: [
            Expanded(
              child: GridView.count(
                padding: EdgeInsets.only(bottom: 10),
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: ssEncryptMethods.map((encrypt) {
                  return TextButton(
                    onPressed: () => setState(() {
                      encryptSelection = encrypt;
                    }),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Theme.of(context).cardColor),
                    ),
                    child: Text(encrypt.toUpperCase()),
                  );
                }).toList(),
              ),
            ),
            Divider(height: 1),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(encryptSelection),
            child: Text("OK"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
        ],
      ),
    );

    return OutlinedButton(
      onPressed: () {
        showDialog<String>(
          context: context,
          builder: (context) => dialogBuilder,
        ).then((encrypt) {
          if (encrypt != null) {
            setState(() {
              widget.ssEdit.encrypt = encrypt;
              _isEncryptChanged = true;
            });
          }
        });
      },
      child: Row(
        children: [
          Icon(Icons.security_sharp),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(15),
              alignment: Alignment.center,
              child: Text(widget.ssEdit.encrypt.toUpperCase()),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

    // id value maybe negative
    if (widget.ssEdit.id != 0) {
      widgets.add(
        Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: QrImage(
            padding: EdgeInsets.all(20),
            data: widget.ssEdit.encodeBase64(),
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
      );
    }

    // server info
    widgets.add(Container(
      padding: EdgeInsets.all(10),
      child: _buildForm(),
    ));

    // server encrypt
    widgets.add(Container(
      padding: EdgeInsets.all(10),
      child: _buildEncrypt(),
    ));

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: _buildTitle(),
      ),
      body: ListView(
        children: widgets,
      ),
    );
  }
}
