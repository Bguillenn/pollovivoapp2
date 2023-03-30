import 'package:flutter_blue/flutter_blue.dart';

abstract class BlocBase {
  void dispose();
}

class BalanzaBloc implements BlocBase {
  FlutterBlue flutterBlue;
  BluetoothDevice bluetoothDevice;
  String Uuid;
  bool Manual = false;
  bool AvailableManual = false;
  BalanzaBloc() {
    flutterBlue = FlutterBlue.instance;
    Uuid = "";
  }

  Stream<BluetoothState> get bluetoothState => flutterBlue.state;

  Future<dynamic> startScan() =>
      flutterBlue.startScan(timeout: Duration(seconds: 8));

  Future<dynamic> stopScan() => flutterBlue.stopScan();

  Stream<List<BluetoothDevice>> getDevices() =>
      Stream.periodic(Duration(seconds: 2))
          .asyncMap((_) => flutterBlue.connectedDevices);

  Stream<List<ScanResult>> get scanResults => flutterBlue.scanResults;

  Stream<bool> get isScanning => flutterBlue.isScanning;

  Stream<BluetoothDeviceState> get bluetoothDeviceState =>
      bluetoothDevice.state;

  @override
  void dispose() {}
}

final balanzaBloc = BalanzaBloc();
