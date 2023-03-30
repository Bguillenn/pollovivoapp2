import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class SyncTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic;

  const SyncTile({this.characteristic}) : super();

  @override
  State<StatefulWidget> createState() {
    return _SyncTileState(characteristic: characteristic);
  }
}

class _SyncTileState extends State<SyncTile> {
  final BluetoothCharacteristic characteristic;

  _SyncTileState({this.characteristic});

  void _syncClick() {
    characteristic.setNotifyValue(!characteristic.isNotifying).then((val) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: RaisedButton.icon(
        icon: Icon(
          characteristic.isNotifying ? Icons.sync_disabled : Icons.sync,
          color: Colors.white,
        ),
        label: Text(""),
        color: Colors.blue,
        textColor: Colors.white,
        disabledTextColor: Colors.white,
        onPressed: () {
          _syncClick();
        },
      ),
    );
  }
}
