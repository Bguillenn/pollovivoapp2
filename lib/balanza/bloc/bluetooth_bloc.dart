import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';

class BluetoothBloc {
  FlutterBluetoothSerial flutterBlue;

  BluetoothDevice bluetoothDevice;
  BluetoothState _bluetoothState;
  String Uuid;
  bool Manual = false;
  bool AvailableManual = true;

  StreamSubscription<BluetoothDiscoveryResult> _streamSubscription;
  List<BluetoothDiscoveryResult> results = List<BluetoothDiscoveryResult>.empty(growable: true);

  BluetoothConnection connection;
  bool get isConnected => connection != null && connection.isConnected;

  BluetoothBloc() {
    flutterBlue = FlutterBluetoothSerial.instance;
    _bluetoothState = BluetoothState.UNKNOWN;
    Uuid = "";

    flutterBlue.setPairingRequestHandler((BluetoothPairingRequest request) {
      print("Trying to auto-pair with Pin 1234");
      if (request.pairingVariant == PairingVariant.Pin) {
        return Future.value("1234");
      }
      return null;
    });
  }

  Future<BluetoothState> get bluetoothState => flutterBlue.state;
  BluetoothBondState get bluetoothDeviceState => bluetoothDevice.bondState;
  Future<dynamic> stopScan() => connection.finish();
}

final bluetoothBloc = BluetoothBloc();
