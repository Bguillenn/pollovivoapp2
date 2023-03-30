import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollovivoapp/balanza/bloc/balanza_bloc.dart';
import 'package:pollovivoapp/balanza/bloc/bluetooth_bloc.dart';
import 'package:pollovivoapp/balanza/ui/widgets/BluetoothDeviceListEntry.dart';

class SelectBondedDevicePage extends StatefulWidget {
  /// If true, on page start there is performed discovery upon the bonded devices.
  /// Then, if they are not avaliable, they would be disabled from the selection.
  final bool checkAvailability;

  const SelectBondedDevicePage({this.checkAvailability = true});

  @override
  _SelectBondedDevicePage createState() => new _SelectBondedDevicePage();
}

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class _DeviceWithAvailability extends BluetoothDevice {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi = -1]);
}

class _SelectBondedDevicePage extends State<SelectBondedDevicePage> {
  List<_DeviceWithAvailability> devices =
      List<_DeviceWithAvailability>.empty(growable: true);

  // Availability
  StreamSubscription<BluetoothDiscoveryResult> _discoveryStreamSubscription;
  bool _isDiscovering;
  bool stateBluetooth = false;
  _SelectBondedDevicePage();

  StreamSubscription<BluetoothDiscoveryResult> _streamSubscription;
  List<BluetoothDiscoveryResult> results =
      List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isDiscoveringNew = true;

  @override
  void initState() {
    super.initState();
    _isDiscovering = widget.checkAvailability;

    if (_isDiscovering) {
      _startDiscovery();
    }

    if (isDiscoveringNew) {
      startDiscovery();
      _startDiscoveryNew();
    }

    //* Llamada a bluetooh BLOC
    bluetoothBloc.flutterBlue.state.then((state) {
      setState(() {
        stateBluetooth = state == BluetoothState.STATE_ON;
      });
    });
  }

  void startDiscovery() {
    //* Llamada a bluetoohBLOC
    bluetoothBloc.flutterBlue
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
            setState(() {
              devices = bondedDevices
                  .map(
                    (device) => _DeviceWithAvailability(
                      device,
                      widget.checkAvailability
                          ? _DeviceAvailability.maybe
                          : _DeviceAvailability.yes,
                    ),
                  )
                  .toList();
              if(balanzaBloc.AvailableManual)
                devices.insert(
                    0,
                    _DeviceWithAvailability(
                      BluetoothDevice(
                        name: 'BALANZA MANUAL',
                        address: "0",
                        type: null,
                        bondState: BluetoothBondState.none,
                      ),
                      widget.checkAvailability
                          ? _DeviceAvailability.maybe
                          : _DeviceAvailability.yes,
                    ));
              _isDiscovering = false;
            });
    });
  }

  void _restartDiscovery() {
    setState(() {
      results.clear();
      devices.clear();
      _isDiscovering = true;
      isDiscoveringNew = true;
    });
    startDiscovery();
    _startDiscoveryNew();
  }

  void _startDiscoveryNew() {
    _streamSubscription =
        bluetoothBloc.flutterBlue.startDiscovery().listen((r) {
      if (r.device.name != null &&
          !results.any((element) =>
              idBalaza(element.device.address) == idBalaza(r.device.address)) &&
          !devices.any((item) =>
              idBalaza(item.device.address) == idBalaza(r.device.address)))
        setState(() {
          results.add(r);
        });
    });

    _streamSubscription.onDone(() {
      setState(() {
        isDiscoveringNew = false;
      });
    });
  }

  void _startDiscovery() {
    _discoveryStreamSubscription =
        bluetoothBloc.flutterBlue.startDiscovery().listen((r) {
      setState(() {
        Iterator i = devices.iterator;
        while (i.moveNext()) {
          var _device = i.current;
          if (_device.device == r.device) {
            _device.availability = _DeviceAvailability.yes;
            _device.rssi = r.rssi;
          }
        }
      });
    });

    _discoveryStreamSubscription.onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _streamSubscription.cancel();
    _discoveryStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<BluetoothDeviceListEntry> list = devices
        .map((result) => BluetoothDeviceListEntry(
              device: result.device,
              rssi: result.rssi,
              enabled: result.availability == _DeviceAvailability.yes,
              onTap: () {
                Navigator.of(context).pop(result.device);
              },
              onLongPress: () async {
                try {
                  await bluetoothBloc.flutterBlue
                      .removeDeviceBondWithAddress(result.device.address);
                  setState(() {
                    devices.remove(result);
                    results.add(BluetoothDiscoveryResult(
                        device: BluetoothDevice(
                          name: result.device.name ?? '',
                          address: result.device.address,
                          type: result.device.type,
                          bondState: BluetoothBondState.none,
                        ),
                        rssi: result.rssi));
                    Fluttertoast.showToast(
                        msg: "Se desconecto correctamente",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 20.0);
                  });
                } catch (ex) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error occured while bonding'),
                        content: Text("${ex.toString()}"),
                        actions: <Widget>[
                          new TextButton(
                            child: new Text("Close"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ))
        .toList();
    print("$_isDiscovering - $isDiscoveringNew");
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar balanza'),
        actions: <Widget>[
          (_isDiscovering || isDiscoveringNew) && stateBluetooth
              ? Stack(
                  children: [
                    FittedBox(
                      child: Container(
                        margin: new EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(4.0),
                      child: IconButton(
                        icon: Icon(Icons.close),
                        iconSize: 25,
                        onPressed: () {
                          if (stateBluetooth)
                            setState(() {
                              _streamSubscription.cancel();
                              _discoveryStreamSubscription?.cancel();
                              isDiscoveringNew = false;
                            });
                        },
                      ),
                    ),
                  ],
                )
              : IconButton(
                  icon: Icon(Icons.replay),
                  onPressed: _restartDiscovery,
                )
        ],
      ),
      body: SingleChildScrollView(
          child: Container(
        child: Column(
          children: [
            Container(
                decoration: BoxDecoration(color: Colors.black12),
                padding: EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [Text("Dispositivos Emparejados")],
                )),
            ...list,
            Container(
                decoration: BoxDecoration(color: Colors.black12),
                padding: EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [Text("Dispositivos Disponibles")],
                )),
            FutureBuilder<BluetoothState>(
              future: bluetoothBloc.bluetoothState,
              initialData: BluetoothState.UNKNOWN,
              builder: (context, snapshotBLE) {
                final state = snapshotBLE.data;
                stateBluetooth = state == BluetoothState.STATE_ON;
                if (state == BluetoothState.STATE_ON) {
                  return Container(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: results.length,
                      itemBuilder: (BuildContext context, index) {
                        BluetoothDiscoveryResult result = results[index];
                        return BluetoothDeviceListEntry(
                          device: result.device,
                          rssi: result.rssi,
                          emparejar: true,
                          onTap: () {
                            Navigator.of(context).pop(result.device);
                            //Fluttertoast.showToast( msg: "Empareje el dispositivo para poder seleccionar!");
                          },
                          onLongPress: () async {
                            try {
                              bool bonded = false;
                              bonded = await bluetoothBloc.flutterBlue
                                  .bondDeviceAtAddress(result.device.address);
                              if (bonded)
                                Fluttertoast.showToast(
                                  msg: "Se emparejo correctamente",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 20.0,
                                );
                              setState(() {
                                results.remove(result);
                                devices.add(_DeviceWithAvailability(
                                    BluetoothDevice(
                                      name: result.device.name ?? '',
                                      address: result.device.address,
                                      type: result.device.type,
                                      bondState: bonded
                                          ? BluetoothBondState.bonded
                                          : BluetoothBondState.none,
                                    ),
                                    widget.checkAvailability
                                        ? _DeviceAvailability.maybe
                                        : _DeviceAvailability.yes,
                                    result.rssi));
                              });
                            } catch (ex) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                        'Error occured while bonding'),
                                    content: Text("${ex.toString()}"),
                                    actions: <Widget>[
                                      new TextButton(
                                        child: new Text("Close"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                        );
                      },
                    ),
                  );
                } else {
                  return Card(
                    margin: EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 20.0, right: 20.0),
                    elevation: 10.0,
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 4,
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.bluetooth_disabled,
                            color: Colors.grey,
                            size: 50.0,
                          ),
                          SizedBox(height: 20.0),
                          Text(
                            "Bluetooth DESACTIVADO!!",
                            style: TextStyle(
                              color: Colors.black38,
                              fontWeight: FontWeight.w800,
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            "Por favor, active el Bluetooth \n y refresque la busqueda",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      )),
    );
  }
}
