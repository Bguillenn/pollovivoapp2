import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:pollovivoapp/balanza/bloc/bluetooth_bloc.dart';

class BluetoothDeviceListEntry extends ListTile {
  BluetoothDeviceListEntry({
    @required BluetoothDevice device,
    int rssi,
    bool emparejar=false,
    GestureTapCallback onTap,
    GestureTapCallback onLongPress,
    bool enabled = true,
  }) : super(
    onTap: onTap,
    //onLongPress: onLongPress,
    enabled: enabled,
    leading: Icon(Icons.devices), // @TODO . !BluetoothClass! class aware icon
    title: Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text((device.name ?? "Unknown device") + (device.address!="0"? " [${idBalaza(device.address)}]":"")),
        ),
        if(device.address!="0")
          Align(
            alignment: Alignment.centerLeft,
            child: Text(device.address.toString(), style: TextStyle(
              color: Colors.black26,
              fontSize: 14.0,
            ))
          ),
      ],
    ),
    //subtitle: Text(),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        rssi != null
            ? Container(
          margin: new EdgeInsets.all(8.0),
          child: DefaultTextStyle(
            style: _computeTextStyle(rssi),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(rssi.toString()),
                Text('dBm'),
              ],
            ),
          ),
        )
            : Container(width: 0, height: 0),
        device.isConnected|| (bluetoothBloc.bluetoothDevice!= null && idBalaza(bluetoothBloc.bluetoothDevice.address)== idBalaza(device.address) )
            ? Icon(Icons.import_export)
            : Container(width: 0, height: 0),
      /*  device.isBonded
            ? Icon(Icons.link)
            : Container(width: 0, height: 0),*/
          if(device.address!="0")
            IconButton(icon: Icon(emparejar?Icons.bluetooth_connected_sharp:Icons.bluetooth_disabled_sharp), onPressed: onLongPress
        ),
      ],
    ),
  );

  static TextStyle _computeTextStyle(int rssi) {
    /**/ if (rssi >= -35)
      return TextStyle(color: Colors.greenAccent[700]);
    else if (rssi >= -45)
      return TextStyle(
          color: Color.lerp(
              Colors.greenAccent[700], Colors.lightGreen, -(rssi + 35) / 10));
    else if (rssi >= -55)
      return TextStyle(
          color: Color.lerp(
              Colors.lightGreen, Colors.lime[600], -(rssi + 45) / 10));
    else if (rssi >= -65)
      return TextStyle(
          color: Color.lerp(Colors.lime[600], Colors.amber, -(rssi + 55) / 10));
    else if (rssi >= -75)
      return TextStyle(
          color: Color.lerp(
              Colors.amber, Colors.deepOrangeAccent, -(rssi + 65) / 10));
    else if (rssi >= -85)
      return TextStyle(
          color: Color.lerp(
              Colors.deepOrangeAccent, Colors.redAccent, -(rssi + 75) / 10));
    else
      /*code symetry*/
      return TextStyle(color: Colors.redAccent);
  }
}

int idBalaza(String IdDevice){
  List<int> data= new List<int>.empty(growable: true);
  IdDevice.split(':').forEach((element)=>{
    data.add(int.parse(element, radix: 16))
  });
  return data.reduce((a, b) => a + b);
}