import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:pollovivoapp/balanza/bloc/balanza_bloc.dart';
import 'package:pollovivoapp/balanza/ui/widgets/scan_result_tile.dart';
import 'package:pollovivoapp/model/cliente.dart';
import 'package:pollovivoapp/model/login_response.dart';
import 'package:pollovivoapp/model/lote.dart';
import 'package:pollovivoapp/model/pedido_item.dart';
import 'package:pollovivoapp/model/reparto_item.dart';
import 'package:pollovivoapp/model/save_request.dart';
import 'package:pollovivoapp/model/shared_pref.dart';
import 'package:pollovivoapp/model/tipo_repeso.dart';
//import 'package:pollovivoapp/ui/screens/pesaje_screen_on.dart';
import 'package:pollovivoapp/ui/screens/pesaje_screen_on_bloc.dart';

class FindDevicesScreenBloc extends StatefulWidget {
  TipoRepeso tipoRepesoSelected;
  Cliente clienteSelected;
  Lote loteSelected;
  int puntoVenta;
  PedidoItem pedidoItem;
  LoginResponse loginResponse;
  RepartoItem repartoSelected;
  // SharedPref saveLocal;
  // String Shared_name;
  FindDevicesScreenBloc(
    this.tipoRepesoSelected,
    this.clienteSelected,
    this.loteSelected,
    this.puntoVenta,
    this.pedidoItem,
    this.loginResponse,
    this.repartoSelected
  );

  @override
  _FindDevicesScreenBlocState createState() => _FindDevicesScreenBlocState();
}

class _FindDevicesScreenBlocState extends State<FindDevicesScreenBloc> {
  @override
  void initState() {
    super.initState();
    print('list of paired devices');
    balanzaBloc.flutterBlue.connectedDevices.asStream().listen((paired) {
      print('paired device: $paired');
    });
        balanzaBloc.flutterBlue.scan(timeout: Duration(seconds: 20)).listen((scanResult) {
          var device = scanResult.device;
          print('${device.id} found! rssi: ${scanResult.rssi}');
        }//, onDone: _stopScan
        );

    // widget.saveLocal = new SharedPref();
    // widget.Shared_name= "Pesos_"+widget.clienteSelected.toString()+"_"+widget.pedidoItem.NumeroPedido.toString()+"_"+widget.pedidoItem.Item.toString();
  }
  int idBalaza(String IdDevice){
    List<int> data= new List<int>.empty(growable: true);
    IdDevice.split(':').forEach((element)=>{
      data.add(int.parse(element, radix: 16))
    });
    return data.reduce((a, b) => a + b);
  }

  Widget showBluetoothOFF() {
    return Card(
      margin: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20.0, right: 20.0),
      elevation: 10.0,
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height / 4,
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              color: Colors.grey,
              size: 60.0,
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
              "Por favor, active el Bluetooth",
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

  Widget showPesadaManual() {
    return ExpansionTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Pesado manual",//result.device.name.contains("HF22")?:result.device.name,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "Ingrese manualmente el peso",
            style: Theme.of(context).textTheme.caption,
          )
        ],
      ),
      leading: Text("0"),
      trailing: RaisedButton(
        padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
        color: Colors.blue,
        textColor: Colors.white,
        disabledTextColor: Colors.white,
        child: Text('Ingresar'),
        onPressed: () async {
          /*Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                balanzaBloc.Manual = true;
                if (balanzaBloc.bluetoothDevice != null)
                  balanzaBloc.bluetoothDevice.disconnect();
                return PesajeScreenONBloc(
                    widget.tipoRepesoSelected,
                    widget.clienteSelected,
                    widget.loteSelected,
                    widget.puntoVenta,
                    widget.pedidoItem,
                    widget.loginResponse,
                    widget.repartoSelected
                );
              },
            )
          );*/
          balanzaBloc.Manual = true;
          if (balanzaBloc.bluetoothDevice != null)
            balanzaBloc.bluetoothDevice.disconnect();
            SaveRequest request = await Navigator.push(context, new MaterialPageRoute<SaveRequest>(
              builder: (context) => PesajeScreenONBloc(
                  widget.tipoRepesoSelected,
                  widget.clienteSelected,
                  widget.loteSelected,
                  widget.puntoVenta,
                  widget.pedidoItem,
                  widget.loginResponse,
                  widget.repartoSelected
              )
          )
          );
          Navigator.pop(context, request);
        },
        //onPressed: (result.advertisementData.serviceUuids.isNotEmpty) ? onTap : null,
      ),
      children: <Widget>[],
    );
  }


  Widget makeListBluetoothDevices() {
    return StreamBuilder<List<BluetoothDevice>>(
      stream: balanzaBloc.getDevices(),
      initialData: [],
      builder: (context, snapshot) => Column(
        children: snapshot.data
            .map(
              (device) => ListTile(
                title: Text("Rico Pollo " + idBalaza(device.id.toString()).toString()),
                subtitle: Text("ID: " + device.id.toString()),
                trailing: StreamBuilder<BluetoothDeviceState>(
                  stream: device.state,
                  initialData: BluetoothDeviceState.disconnected,
                  builder: (context, snapshot) {
                    if (snapshot.data == BluetoothDeviceState.connected) {
                      return ElevatedButton(
                        child: Text("Abrir"),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              balanzaBloc.bluetoothDevice = device;
                              balanzaBloc.bluetoothDevice.connect();

                              return PesajeScreenONBloc(
                                widget.tipoRepesoSelected,
                                widget.clienteSelected,
                                widget.loteSelected,
                                widget.puntoVenta,
                                widget.pedidoItem,
                                widget.loginResponse,
                                widget.repartoSelected
                              );
                            },
                          ),
                        ),
                      );
                    }
                    return Text("DATA: " + snapshot.data.toString());
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget makeListScanResults() {
    return StreamBuilder<List<ScanResult>>(
      stream: balanzaBloc.scanResults,
      initialData: [],
      builder: (context, snapshot) => Column(
        children: snapshot.data
           // .where((result) => result.device.name.length > 0 ) //&& result.device.name.contains("HF22")
            .map(
              (result) => ScanResultTile(
                result: result,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        try {
                          balanzaBloc.bluetoothDevice = result.device;
                          balanzaBloc.bluetoothDevice.connect();
                          balanzaBloc.Uuid=result.advertisementData.serviceUuids.join(', ').toUpperCase();
                          balanzaBloc.Manual=false;
                        } catch (e) {
                          print("Error: Connect Device $e");  // Not printed when error . Why error not catched ??
                        }

                        return PesajeScreenONBloc(
                          widget.tipoRepesoSelected,
                          widget.clienteSelected,
                          widget.loteSelected,
                          widget.puntoVenta,
                          widget.pedidoItem,
                          widget.loginResponse,
                          widget.repartoSelected
                        );
                      },
                    ),
                  );
                },
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothState>(
      stream: balanzaBloc.bluetoothState,
      initialData: BluetoothState.unknown,
      builder: (context, snapshotBLE) {
        final state = snapshotBLE.data;

        if (state == BluetoothState.on) {
          try{ balanzaBloc.startScan(); } catch(e){ print(e);}
          return Scaffold(
            appBar: AppBar(
              title: Text('Encontrar dispositivos ...'),
            ),
            body: RefreshIndicator(
              onRefresh: () => balanzaBloc.startScan(),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    showPesadaManual(),
                    makeListBluetoothDevices(),
                   // makeListScanResults(),
                  ],
                ),
              ),
            ),
            floatingActionButton: StreamBuilder<bool>(
              stream: balanzaBloc.isScanning,
              initialData: false,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return FloatingActionButton(
                    child: Icon(Icons.stop),
                    onPressed: () => balanzaBloc.stopScan(),
                    backgroundColor: Colors.red,
                  );
                } else {
                  return FloatingActionButton(
                    child: Icon(Icons.search),
                    onPressed: () => balanzaBloc.startScan(),
                    backgroundColor: Colors.blue,
                  );
                }
              },
            ),
          );
        }
        else {
          return Scaffold(
            appBar: AppBar(
              title: Text('Bluetooth desactivado'),
            ),
            body: showBluetoothOFF(),
          );
        }
      },
    );
  }
}
