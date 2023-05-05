import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollovivoapp/balanza/bloc/balanza_bloc.dart';
import 'package:pollovivoapp/balanza/bloc/bluetooth_bloc.dart';
import 'package:pollovivoapp/balanza/ui/screens/SelectBondedDevicePage.dart';
import 'package:pollovivoapp/balanza/ui/widgets/BluetoothDeviceListEntry.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:pollovivoapp/bloc/login_bloc.dart';
import 'package:pollovivoapp/bloc/pedido_bloc.dart';
import 'package:pollovivoapp/model/cliente.dart';
import 'package:pollovivoapp/model/login_response.dart';
import 'package:pollovivoapp/model/lote.dart';
import 'package:pollovivoapp/model/pedido_item.dart';
import 'package:pollovivoapp/model/pesaje_detalle_item.dart';
import 'package:pollovivoapp/model/reparto_item.dart';
import 'package:pollovivoapp/model/save_request.dart';
import 'package:pollovivoapp/model/save_request_cab.dart';
import 'package:pollovivoapp/model/shared_pref.dart';
import 'package:pollovivoapp/model/tipo_repeso.dart';
import 'package:pollovivoapp/ui/widgets/input_custom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class PesajeScreen extends StatefulWidget {
  TipoRepeso tipoRepesoSelected;
  Cliente clienteSelected;
  Lote loteSelected;
  int puntoVenta;
  PedidoItem pedidoItem;
  LoginResponse loginResponse;
  RepartoItem repartoSelected;
  String motivoSelected;
  bool productoSinPedido;
  List<Cliente> _clienteTestaferro;
  TipoRepeso _repesoVentaDirecta;
  PesajeScreen(
      this.tipoRepesoSelected,
      this.clienteSelected,
      this.loteSelected,
      this.puntoVenta,
      this.pedidoItem,
      this.loginResponse,
      this.repartoSelected,
      this.motivoSelected,
      this.productoSinPedido,
      this._clienteTestaferro,
      this._repesoVentaDirecta);

  @override
  State<StatefulWidget> createState() {
    return _PesajeScreenState();
  }
}

class _PesajeScreenState extends State<PesajeScreen> {
  List<PesajeDetalleItem> items = List.empty(growable: true);
  bool _isLoadData = false;

  String _numeroPesajes;
  SaveRequestCab requestCab;
  SaveRequest request;
  SharedPref saveLocal;
  List<double> allPesos;
  String sharedName;
  double precioLoteProducto;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final _jabasController = TextEditingController();
  final _unidadesController = TextEditingController();
  final _pesoControles = TextEditingController();
  var listObject;
  List<Cliente> _testaferros;
  Cliente _selectedTestaferro;

  //? Para manejar el bluetooh
  bool isDisconnecting = false;
  bool isConnecting = true;
  String _messageBuffer = '';
  String pesoBalaza = "00.0";
  bool reconectedactive = false;
  Timer timeractive;
  String stableText = "";
  double descuentoPorProducto = 0.0;
  var uuid;

  @override
  Future<void> initState() {
    super.initState();
    uuid = Uuid();
    _numeroPesajes = "0";
    allPesos = new List<double>.empty(growable: true);
    double descuentoProducto = 0;
    if(widget.pedidoItem.totalActual == null) widget.pedidoItem.totalActual = 0;
    if (widget.clienteSelected != null &&
        widget.clienteSelected.descuento.length > 0 &&
        widget.clienteSelected.descuento
            .any((element) => element.item1 == widget.pedidoItem.producto))
      descuentoProducto = widget.clienteSelected.descuento
          .firstWhere((element) => element.item1 == widget.pedidoItem.producto)
          .item2;


    this.descuentoPorProducto = descuentoProducto;
    if(this.widget.tipoRepesoSelected.codigo != 2 && this.widget.tipoRepesoSelected.codigo != 4) {
      precioLoteProducto = widget.loginResponse.loginData.lotes
                .firstWhere(
                    (element) => element.codigo == widget.loteSelected.codigo)
                .precio  *
            100 -
        descuentoProducto * 100;
    }else {
      precioLoteProducto = this.widget.loteSelected.precio * 100 - descuentoProducto * 100;
    }
    precioLoteProducto = precioLoteProducto / 100;
    int numeroReparto;
    int itemReparro;
    if (widget.tipoRepesoSelected.codigo == 1) {
      numeroReparto = widget.repartoSelected.numeroReparto;
      itemReparro = widget.repartoSelected.item;
    }
    requestCab = SaveRequestCab(
        widget.puntoVenta,
        widget.tipoRepesoSelected.codigo != 3
            ? widget.clienteSelected.codigo
            : 0,
        widget.loteSelected.numero,
        widget.pedidoItem.numeroPedido,
        widget.pedidoItem.item,
        widget.tipoRepesoSelected.codigo,
        numeroReparto,
        itemReparro);
    //Pesos_398_5_1
    saveLocal = new SharedPref();
    sharedName = "Pesos_" +
        requestCab.Tipo.toString() +
        "_" +
        requestCab.Cliente.toString() +
        "_" +
        requestCab.Pedido.toString() +
        "_" +
        requestCab.ItemPedido.toString();

    _prefs.then((SharedPreferences prefs) {
      String strData = prefs.getString(sharedName) ?? "";
      if (strData != "")
        setState(() {
          json.decode(strData)["oDetalle"].forEach((value) {
            items.add(PesajeDetalleItem.fromJson(value));
          });
        });
    });

    //? Manda a la pantalla para seleccionar dispositivo bluetooh o cargar el metodo cuando se conecta un dispositivo
    if (bluetoothBloc.Uuid != "") {
      _onConectDevice();
    } else {
      Future(() {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return SelectBondedDevicePage(checkAvailability: false);
            },
          ),
        ).then((value) {
          if (value == null && bluetoothBloc.Uuid == "") {
            Navigator.pop(context);
            return;
          }
          connectDevice(value);
        });
      });
    }

    Timer.periodic(Duration(seconds: 30), (timer) {
      timeractive = timer;
      if (bluetoothBloc.Uuid != "" &&
          bluetoothBloc.Uuid != "0" &&
          !bluetoothBloc.isConnected &&
          !reconectedactive) {
        print("Tratando de reconectar");
        _onConectDevice();
        reconectedactive = true;
      }
    });

    _testaferros = widget._clienteTestaferro;
    _selectedTestaferro = _testaferros.firstWhere(
        (tes) => tes.codigo == widget.clienteSelected.codigo,
        orElse: () => this.widget.clienteSelected);
    // pedidoBloc.getTestaferros(widget.puntoVenta.toString(), widget.clienteSelected.Codigo.toString()).then((resp) {
    //   _testaferros = resp;
    //   _selectedTestaferro = _testaferros.firstWhere((tes) => tes.Codigo==widget.clienteSelected.Codigo,orElse: null);
    // });

    defaultUnidadesJabas();
  }

  void defaultUnidadesJabas() {
    int default_Jabas = 10;
    _jabasController.text = default_Jabas.toString();
    _unidadesController.text =
        (default_Jabas * widget.loteSelected.unidadesPorJaba).toString();
    _jabasController.addListener(() {
      int jabas = 0;
      if (_jabasController.text == "")
        jabas = 0;
      else
        jabas = int.parse(_jabasController.text);
      _unidadesController.text =
          (jabas * widget.loteSelected.unidadesPorJaba).toString();
    });
  }

  void connectDevice(BluetoothDevice device) {
    if (device != null) {
      if (bluetoothBloc.connection != null) {
        if (device.address != bluetoothBloc.Uuid)
          bluetoothBloc.connection.dispose();
        else {
          isConnecting = false;
          return;
        }
      }
      setState(() {
        isConnecting = true;
        bluetoothBloc.bluetoothDevice = device;
      });
      bluetoothBloc.Uuid = bluetoothBloc.bluetoothDevice.address;
      bluetoothBloc.Manual = bluetoothBloc.bluetoothDevice.address == "0";
      if (!bluetoothBloc.Manual)
        _onConectDevice();
      else
        setState(() {
          bluetoothBloc.Manual = true;
        });
    } else if (bluetoothBloc.connection.isConnected) {
      isConnecting = false;
      _onConectDevice();
    }
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (bluetoothBloc.isConnected) {
      isDisconnecting = true;
      bluetoothBloc.stopScan();
      bluetoothBloc.connection = null;
    }
    if (timeractive != null) timeractive.cancel();
    super.dispose();
  }

  void _onConectDevice() {
    BluetoothConnection.toAddress(bluetoothBloc.Uuid).then((_connection) {
      print('Connected to the device');
      bluetoothBloc.connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
        reconectedactive = false;
      });

      bluetoothBloc.connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
      if (this.mounted) {
        setState(() {
          isConnecting = false;
          isDisconnecting = false;
          reconectedactive = false;
        });
      }
    });
  }

  //* Lee la data recibida a travez de bluetooth
  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);

    int index = buffer.indexOf(13);
    if (~index != 0) {
      String data = backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString.substring(0, index);

      try {
        //var pesoBalanza = data.split('   ')[data.split('   ').length-2]+data.split('   ')[data.split('   ').length-1];
        var pesoBalanza = data.trim(); //.split(',')[data.split(',').length-1];
        //var pesoBalanza = data.split(pattern);
        // ignore: non_constant_identifier_names
        var peso = data.trim().split(',')[data.trim().split(',').length - 1];
        var negativo = false;
        if (data.trim().contains('-')) {
          negativo = true;
        }

        final intInStr = RegExp(r'\d+');
        var pesoString = intInStr.allMatches(peso).map((m) => m.group(0));

        double pesoConvert = negativo
            ? -double.parse(pesoString.join('.'))
            : double.parse(pesoString.join('.'));
        if (pesoBalanza.contains("ST") &&
            pesoConvert > widget.loginResponse.loginData.dataUsuario.minimo) {
          // PesoConvert = redondeo1(PesoConvert);
          print("ANTES ${pesoConvert}");
          String pesoRoundedString = pesoConvert.toStringAsFixed(1);
          print("STRING DOUBLE ${pesoRoundedString}");
          pesoConvert = double.parse(pesoRoundedString);
          allPesos.add(pesoConvert);
          // print(PesoConvert);
        }

        if (allPesos.length > 2 && pesoConvert == allPesos[allPesos.length - 2])
          return;
        else
          setState(() {
            double rounded = double.parse(pesoString.join('.'));
            rounded = double.parse(rounded.toStringAsFixed(1));

            stableText = pesoBalanza.contains("ST") ? "ST" : "";
            //pesoBalaza = (negativo ? "-" : "") + pesoString.join('.');
            pesoBalaza = (negativo ? "-" : "") + rounded.toString();
            _messageBuffer = dataString.substring(index);
          });
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Error: " + e.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 20.0,
        );
      }
      //

    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  int getMaxItemPesaje() {
    int maximo = 0;
    for (PesajeDetalleItem item in items) {
      if (item.Item > maximo) maximo = item.Item;
    }
    return maximo;
  }

  double redondeo1(double input) {
    String inString = input.toStringAsFixed(1); // '2.35'
    return double.parse(inString);
  }

  void addItemPesaje() async {
    double moda = 0.0;

    if (_jabasController.text == "" || _unidadesController.text == "") {
      Fluttertoast.showToast(
        msg: "Ingrese Jabas y unidades!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.amber,
        textColor: Colors.black,
        fontSize: 20.0,
      );
      return;
    }
    if (_unidadesController.text.trim() == "0") {
      Fluttertoast.showToast(
        msg: "Unidades invalidas",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.amber,
        textColor: Colors.black,
        fontSize: 20.0,
      );
      return;
    }
    if (items.length > 0 &&
        DateTime.now().difference(items.first.FechaRegistro).inSeconds < 3) {
      Fluttertoast.showToast(
        msg: "Nuevo pesaje muy seguido al anterior",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.amber,
        textColor: Colors.black,
        fontSize: 20.0,
      );
      return;
    }
    if (bluetoothBloc.Manual) {
      if (_pesoControles.text == "") {
        Fluttertoast.showToast(
          msg: "Ingrese el Peso",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.amber,
          textColor: Colors.black,
          fontSize: 20.0,
        );
        return;
      }
      moda = double.parse(_pesoControles.text.toString());
      _pesoControles.text = "";
    } else {
      if (allPesos.length == 0) return;
      double promedio = 0.0;
      double ultimopeso = allPesos.last;
      Map<double, int> m = new HashMap();
      int contPesos = 0;
      /* for(var elemento in AllPesos)
      {
        if(elemento>ultimopeso-ultimopeso*0.1)
        {
          contPesos++;
          promedio+=elemento;
          if (m.containsKey(elemento))
            m[elemento]+=1;
          else
            m[elemento]=1;
        }
      }
      promedio= promedio/contPesos;

      int repeticiones=1;
      //List<double> Modas= new List<double>();
      double Moda1=0.0;
      m.forEach((key, value) {
        if(key>=promedio){
          if(value>=repeticiones) {
            repeticiones = value;
            Moda1=moda;
            moda=key;
          }
        }
      });

      if(Moda1!=0.0) moda= (moda+Moda1)/2;*/
      moda = allPesos.last; //double.parse(moda.toStringAsFixed(2));
      allPesos.clear();
      //peso= double.parse(Pesobalaza);
    }
    if (moda <= 0) {
      Fluttertoast.showToast(
        msg: "Peso tiene que ser mayor a 0",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.amber,
        textColor: Colors.black,
        fontSize: 20.0,
      );
      return;
    }
    //validadores restrictivos
    var promedioPollo = (moda -
            (int.parse(_jabasController.text) *
                widget.loginResponse.loginData.dataUsuario.taraJava)) /
        int.parse(_unidadesController.text);
    var maximo, minimo;
    if (widget.pedidoItem.pesoPromedio != null) {
      maximo =
          widget.pedidoItem.pesoPromedio + widget.pedidoItem.rangoPermitido;
      minimo =
          widget.pedidoItem.pesoPromedio - widget.pedidoItem.rangoPermitido;
    }
    if (promedioPollo < widget.loginResponse.loginData.dataUsuario.maximo &&
        promedioPollo > widget.loginResponse.loginData.dataUsuario.minimo) {
      int total = items.fold(
          0, (sum, item) => sum + (item.nEstado == 1 ? item.Unidades : 0));
      if (widget.tipoRepesoSelected.codigo == 0 ||
          widget.tipoRepesoSelected.codigo == 10) {
        int LoteDisp = widget.loteSelected.disponible - total;
        if (int.parse(_unidadesController.text) >
            LoteDisp + widget.loginResponse.loginData.dataUsuario.holgura) {
          // agregamos la cantidad de holgura para el lote de un Trailler
          Fluttertoast.showToast(
            msg: "Cantidad a agregar excede a la cantidad disponible del lote",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.amber,
            textColor: Colors.black,
            fontSize: 20.0,
          );
          return;
        }
      } else if (widget.tipoRepesoSelected.codigo == 1 &&
          int.parse(_unidadesController.text) >
              widget.repartoSelected.disponible - total) {
        Fluttertoast.showToast(
          msg: "Cantidad a agregar excede a la cantidad disponible del Sublote",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.amber,
          textColor: Colors.black,
          fontSize: 20.0,
        );
        return;
      }
      if (widget.pedidoItem.pesoPromedio != null &&
          (promedioPollo > maximo || promedioPollo < minimo))
        Fluttertoast.showToast(
          msg: promedioPollo.toStringAsFixed(2) +
              " Promedio de pollo no coincide con el producto",
          toastLength: Toast.LENGTH_LONG,
          fontSize: 20.0,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.amber,
          textColor: Colors.black,
        );

      //? Se crea el objeto del nuevo pesaje
      PesajeDetalleItem item = PesajeDetalleItem(
          1,
          getMaxItemPesaje() + 1,
          int.parse(_jabasController.text),
          int.parse(_unidadesController.text),
          moda);

      print(items.length.toString());
      item.KilosSinTara = item.Kilos -
          item.Jabas * widget.loginResponse.loginData.dataUsuario.taraJava;
      item.SubTotal = (item.KilosSinTara) * precioLoteProducto;
      item.nTipoBalanza = 1;

      items.add(item);
      items.sort((a, b) => b.Item.compareTo(a.Item));

      request = SaveRequest(requestCab, items);
      saveLocal.save(sharedName, request.toJson());
    _numeroPesajes = items.length.toString();
    } else {
      _pesoControles.text = moda.toString();
      Fluttertoast.showToast(
        msg: promedioPollo.toStringAsFixed(2) + " Promedio fuera de rango",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.amber,
        textColor: Colors.black,
        fontSize: 20.0,
      );
    }
  }

  void deleteItemPesaje(int index) {
    // items.removeAt(index);
    items[index].nEstado = 0;
    items.sort((a, b) => b.Item.compareTo(a.Item));
    request = SaveRequest(requestCab, items);
    saveLocal.save(sharedName, request.toJson());
    _numeroPesajes = items.length.toString();
  }

  void deletePesajes() async {
    items.clear();
    saveLocal.remove(sharedName);
    _numeroPesajes = items.length.toString();
    _jabasController.clear();
    _unidadesController.clear();
  }

  DropdownButton<Cliente> ddTestaferros(setState) {
    return DropdownButton<Cliente>(
      value: _selectedTestaferro,
      items: _testaferros
          .map(
            (data) => DropdownMenuItem<Cliente>(
              child: Text(data.toString2()),
              value: data,
            ),
          )
          .toList(),
      onChanged: (Cliente value) {
        setState(() => {
              _selectedTestaferro = value,
            });
      },
      iconSize: 30.0,
      isExpanded: true,
    );
  }

  bool soloVenta() {
    return widget.tipoRepesoSelected.codigo == 0 ||
        widget.tipoRepesoSelected.codigo == 1 ||
        widget.tipoRepesoSelected.codigo == 10;
  }

  void mostarPedido(
      int numeroPesada, String cliente, String PV, String Pedido) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: Text(
                "Se creo el Pedido",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: Container(
                  height: 100,
                  child: Column(
                    children: [
                      Text("Numero de pesada : ${numeroPesada}"),
                      Text(""),
                      Text("Cliente : ${cliente}"),
                    ],
                  )),
              actions: <Widget>[
                TextButton(
                    child: Text(
                      "IMPRIMIR",
                    ),
                    onPressed: () async {
                      try {
                        int intResp = await pedidoBloc.fetchImprimirPesadas(
                            PV, numeroPesada.toString());
                        if (intResp == 1) {
                          Fluttertoast.showToast(
                            msg: "Se mando a imprimir correctamente.",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            backgroundColor: Colors.green,
                            textColor: Colors.black,
                            fontSize: 20.0,
                          );
                        } else {
                          Fluttertoast.showToast(
                            msg: "Error al imprimir",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 20.0,
                          );
                        }
                      } catch (e) {
                        Fluttertoast.showToast(
                          msg: "Error al imprimir",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 20.0,
                        );
                      }
                    }),
                TextButton(
                    child: Text(
                      "ACEPTAR",
                    ),
                    onPressed: () async {
                      //Cierra los dualogos
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      //Regresa a pedido Screen
                      Navigator.pop(context, request);
                    })
              ]);
        });
  }

  void saveDataPesajes() async {
    int sumUnidades = 0;
    for (var item in items) {
      sumUnidades += item.Unidades;
    }
    // if(widget.pedidoItem.CantidadRP+sumUnidades > widget.pedidoItem.Cantidad) {
    //   Fluttertoast.showToast(
    //     msg: "cantidad de unidades supera el pedido ",
    //     toastLength: Toast.LENGTH_LONG,
    //     gravity: ToastGravity.BOTTOM,
    //     backgroundColor: Colors.amber,
    //     textColor: Colors.black,
    //     fontSize: 20.0,
    //   );
    //   return;
    // }
    if (items.length == 0) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            title: Text(
              "Grabar pesajes",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18.0,
                fontWeight: FontWeight.w900,
              ),
            ),
            content: Container(
                height: 60.0,
                child: Column(
                  children: [Text("¿Esta seguro de grabar todos los pesajes?")],
                )),
            //,
            actions: <Widget>[
              TextButton(
                child: Text(
                  "ACEPTAR",
                ),
                onPressed: onPressedAceptarSave,
              ),
              TextButton(
                child: Text(
                  "CANCELAR",
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
      },
    );
    setState(() {});
  }

  Widget reloadService() {
    return Card(
        margin: EdgeInsets.all(5.0),
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.all(Radius.circular(5))),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //if(!bluetoothBloc.Manual)
                bluetoothBloc.isConnected
                    ? GestureDetector(
                        onTap: () {
                          if (items.length > 0) {
                            //Solo si tiene registros anteriores de pesadas
                            var TotalUnidades = items.fold(
                                0,
                                (sum, item) => sum + item.nEstado == 1
                                    ? item.Unidades
                                    : 0);
                            var TotalJavas = items.fold(
                                0,
                                (sum, item) =>
                                    sum + item.nEstado == 1 ? item.Jabas : 0);
                            var TotalPeso = items.fold(
                                0,
                                (sum, item) =>
                                    sum + item.nEstado == 1 ? item.Kilos : 0);

                            var Promedio = TotalPeso / TotalJavas;
                            var undxjava = TotalUnidades / TotalJavas;
                            print(TotalJavas.toString() +
                                "-" +
                                TotalUnidades.toString() +
                                "-" +
                                undxjava.toString());
                            var javas =
                                (double.parse(pesoBalaza) / Promedio).round();
                            var unidades = (javas * undxjava).round();
                            _jabasController.text = javas.toString();
                            _unidadesController.text = unidades.toString();
                          }
                        },
                        child: Text(" ST",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: stableText == "ST"
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30.0)),
                      )
                    : GestureDetector(
                        onTap: () {
                          // Fluttertoast.showToast(msg:"Click");
                          _onConectDevice();
                          setState(() {
                            isConnecting = true;
                          });
                        },
                        child: FutureBuilder<BluetoothState>(
                            future: bluetoothBloc.bluetoothState,
                            initialData: BluetoothState.UNKNOWN,
                            builder: (context, snapshotBLE) {
                              return Icon(
                                snapshotBLE.data == BluetoothState.STATE_ON
                                    ? Icons.refresh
                                    : Icons.bluetooth_disabled,
                                size: 50,
                                color:
                                    snapshotBLE.data == BluetoothState.STATE_ON
                                        ? Colors.red
                                        : Colors.grey,
                              );
                            }),
                      ),
                Flexible(
                  child: bluetoothBloc.Manual
                      ? TextFormField(
                          inputFormatters: [
                              DecimalTextInputFormatter(decimalRange: 2)
                            ],
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.right,
                          controller: _pesoControles,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          //keyboardType: TextInputType.number,
                          style: TextStyle(
                              fontSize: 50.0,
                              //height: 4.0,
                              fontWeight: FontWeight.bold))
                      : Text(
                          pesoBalaza,
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 70.0,
                              //height: 4.0,
                              fontWeight: FontWeight.bold),
                        ),
                ),
                Text("Kg  ",
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.black, fontSize: 26.0))
              ],
            )));
  }

  onWillPopApp(BuildContext c) {
    if (items.length > 0)
      return showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Advertencia'),
          content: Text('Esta seguro de salir, sin guardar datos?'),
          actions: [
            TextButton(
              child: Text('Si'),
              onPressed: () {
                deletePesajes();
                Navigator.of(context).pop();
                _exitApp(c);
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () => Navigator.pop(c, false),
            ),
          ],
        ),
      );
    else
      _exitApp(c);
  }

  Future<bool> _exitApp(BuildContext context) async {
    //await balanzaBloc.bluetoothDevice.disconnect();
    if (bluetoothBloc.isConnected) await bluetoothBloc.stopScan();
    Navigator.pop(context, null);
    return Future.value(true);
  }

  double PesoPromedio() {
    if(items == null) return 0.0;
    double nTotalKilos = items.fold(
        0, (sum, item) => sum + (item.nEstado == 1 ? item.KilosSinTara?.toDouble()?? 0.0 : 0.0));
    double nTotalUnidades = items.fold(
        0, (sum, item) => sum + (item.nEstado == 1 ? item.Unidades?.toDouble()??0.0 : 0.0));
    return nTotalKilos / nTotalUnidades;
  }

  @override
  Widget build(BuildContext context) {
    //Contamos los items que todavia son validos para extraer el index
    List<PesajeDetalleItem> itemsValidos =
        items.where((item) => item.nEstado == 1).toList();
    int currentIndex = itemsValidos.length;

    //Si utilizar balanza manual no esta permitido y la balanza seleccionada es manual entonces
    if (!balanzaBloc.AvailableManual && balanzaBloc.Manual) {
      showDialog<int>(
          context: context,
          builder: (c) => AlertDialog(
                title: Text('BALANZA NO VALIDA'),
                content: Text(
                    'El sistema no esta habilitado para utilizar balanza manual, seleccione una bluetooth'),
                actions: [
                  TextButton(
                    child: Text('Salir'),
                    onPressed: () {
                      deletePesajes();
                      Navigator.of(context).pop(0);
                      _exitApp(c);
                    },
                  ),
                  TextButton(
                    child: Text('Elegir otra'),
                    onPressed: () => Navigator.pop(c, 1),
                  ),
                ],
              )).then((value) => print("DIALOOGGG ${value}"));
    }

    return Builder(
      builder: (BuildContext c) {
        return WillPopScope(
          onWillPop: () => onWillPopApp(c),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: loginBloc.online ? null : Colors.amber,
              toolbarHeight: 45,
              title: Text("Pesaje Pollo Vivo"),
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 0),
                  child: GestureDetector(
                    child: IconButton(
                        icon: Icon(
                          Icons.import_export,
                          size: 32.0,
                        ),
                        onPressed: () async {
                          var device = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return SelectBondedDevicePage(
                                    checkAvailability: false);
                              },
                            ),
                          );
                          connectDevice(device);
                        }),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: GestureDetector(
                    child: IconButton(
                      icon: Icon(
                        Icons.save,
                        size: 32.0,
                      ),
                      onPressed: () => saveDataPesajes(),
                    ),
                  ),
                ),
              ],
            ),
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Card(
                    child: Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                      color: Colors.amberAccent.withOpacity(0.15),
                      child: Column(
                        children: <Widget>[
                          if (widget.tipoRepesoSelected.codigo != 3)
                            Row(
                              children: [
                                Container(
                                  width: 115,
                                  child: Text("Cliente:"),
                                ),
                                Text(widget.clienteSelected.nombre.trim()),
                              ],
                            ),
                          Row(
                            children: [
                              Container(
                                width: 115,
                                child: Text("Lote:"),
                              ),
                              Text(
                                  "${widget.loteSelected.numero.toString()} - ${widget.loteSelected.placa.trim()}"),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 115,
                                child: Text("Tipo de Repeso:"),
                              ),
                              Text(widget.tipoRepesoSelected.nombre.trim()),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 115,
                                child: Text("Producto:"),
                              ),
                              Text(
                                  "${widget.loteSelected.codigo.trim()} - ${widget.loteSelected.descripcion.trim()}"),
                            ],
                          ),
                          if (bluetoothBloc.bluetoothDevice != null)
                            Row(
                              children: [
                                Container(
                                  width: 115,
                                  child: Text("Balanza:"),
                                ),
                                Text("${bluetoothBloc.bluetoothDevice.name}" +
                                    (bluetoothBloc.bluetoothDevice.address !=
                                            "0"
                                        ? " [${idBalaza(bluetoothBloc.bluetoothDevice.address)}]"
                                        : "")),
                                if (bluetoothBloc.bluetoothDevice.address !=
                                    "0")
                                  Expanded(
                                      child: Text(
                                    isConnecting
                                        ? "Conectando..."
                                        : (bluetoothBloc.isConnected
                                            ? "Conectado"
                                            : "Sin conexión"),
                                    style: TextStyle(
                                      color: isConnecting
                                          ? Colors.blue
                                          : (bluetoothBloc.isConnected
                                              ? Colors.green
                                              : Colors.red),
                                    ),
                                    textAlign: TextAlign.right,
                                  ))
                              ],
                            )
                        ],
                      ),
                    ),
                  ),

                  //  if(balanzaBloc.bluetoothDevice.getsize()>0)
                  reloadService(), //detalle de peso de balanza
                  Container(
                    margin: EdgeInsets.all(5.0),
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10.0,
                          height: 0,
                        ),
                        InputCustom("Jabas", "#Jabas", _jabasController, false),
                        SizedBox(width: 10.0),
                        InputCustom("Unidades", "#Unidades",
                            _unidadesController, false),
                        SizedBox(width: 20.0),
                        Flexible(
                          child: MaterialButton(
                            color: Colors.blue,
                            textColor: Colors.white,
                            child: Text(
                              "Añadir",
                              style: TextStyle(fontSize: 18.0),
                            ),
                            padding: EdgeInsets.all(20.0),
                            onPressed: () {
                              addItemPesaje();
                              setState(() {});
                            },
                            onLongPress: () {
                              saveDataPesajes();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          "   Jabas    ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "  Und        ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          " Kg         ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "SubTotal        ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${items.where((element) => element.nEstado == 1).length}/${items.length} pesajes",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (BuildContext context, int index) {
                        int tempIndex = currentIndex;
                        currentIndex = (items[index].nEstado == 1)
                            ? currentIndex - 1
                            : currentIndex;
                        return Container(
                            //color: indexEdit!=index?Colors.white:Colors.blue,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: index == 0
                                      ? Colors.blue
                                      : Colors
                                          .white12, //items.length==index?Colors.blue:Colors.white12,
                                  width: 2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text(
                                    items[index]
                                        .Jabas
                                        .toString()
                                        .padLeft(5, "  "),
                                    style: TextStyle(
                                        color: items[index].nEstado == 1
                                            ? Colors.black
                                            : Colors.red)),
                                Text(
                                    items[index]
                                        .Unidades
                                        .toString()
                                        .padLeft(5, "  "),
                                    style: TextStyle(
                                        color: items[index].nEstado == 1
                                            ? Colors.black
                                            : Colors.red)),
                                Text(
                                  items[index].Kilos.toString().padLeft(
                                        8,
                                        "  ",
                                      ),
                                  style: TextStyle(
                                      fontWeight: index == 0
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 18,
                                      color: items[index].nEstado == 1
                                          ? Colors.black
                                          : Colors.red),
                                ),
                                Text(
                                    items[index]
                                        .SubTotal
                                        .toStringAsFixed(2)
                                        .padLeft(10, "  "),
                                    style: TextStyle(
                                        color: items[index].nEstado == 1
                                            ? Colors.black
                                            : Colors.red)),
                                Row(
                                  children: [
                                    Text(
                                      /*  (items.length - index)
                                          .toString()
                                          .padLeft(5, "  ") */
                                      items[index].nEstado == 1
                                          ? '${tempIndex}'
                                          : 'X',
                                      style: TextStyle(
                                          fontWeight: index == 0
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 18),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.blue,
                                      ),
                                      iconSize: 30.0,
                                      onPressed: () {
                                        setState(() {
                                          deleteItemPesaje(index);
                                        });
                                      },
                                    )
                                  ],
                                ),
                              ],
                            ));
                      },
                    ),
                  ),
                  Container(
                    color: Colors.blue,
                    height: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          "Peso Promedio     " +
                              PesoPromedio().toStringAsFixed(2) +
                              " Kg",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18),
                        ),
                        Text("Total P. S/${calculateTotalPedido()}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white60,
                                fontSize: 12)),

                        // Text(items.fold(0, (sum, item) => sum + (item.nEstado==1?item.Jabas:0)).toStringAsFixed(0)+" J",
                        //   style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18),
                        // ),
                        // Text(items.fold(0, (sum, item) => sum + (item.nEstado==1?item.Unidades:0)).toStringAsFixed(0)+" u",
                        //   style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18),
                        // ),
                        // Text( items.fold(0, (sum, item) => sum + (item.nEstado==1?item.Kilos:0)).toStringAsFixed(2)+" Kg",
                        //   style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18),
                        // ),
                        // Text(" TOTAL: S/."+items.fold(0, (sum, item) => sum + (item.nEstado==1?item.SubTotal:0)).toStringAsFixed(2),
                        //   style: TextStyle(
                        //     fontSize: 16
                        //     ,color: Colors.blue,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.blue,
                    height: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          items
                                  .fold(
                                      0,
                                      (sum, item) =>
                                          sum +
                                          (item.nEstado == 1 ? item.Jabas : 0))
                                  .toStringAsFixed(0) +
                              " J",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18),
                        ),
                        Text(
                          items
                                  .fold(
                                      0,
                                      (sum, item) =>
                                          sum +
                                          (item.nEstado == 1
                                              ? item.Unidades
                                              : 0))
                                  .toStringAsFixed(0) +
                              " u",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18),
                        ),
                        Text(
                          items
                                  .fold(
                                      0,
                                      (sum, item) =>
                                          sum +
                                          (item.nEstado == 1
                                              ? item?.KilosSinTara ?? 0.0
                                              : 0.0))
                                  .toStringAsFixed(2) +
                              " Kg",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18),
                        ),
                        Text(
                          " TOTAL: S/." +
                              calculateTotalActualRepeso(),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  calculateTotalActualRepeso() {
    if(this.widget.tipoRepesoSelected.codigo != 2 && this.widget.tipoRepesoSelected.codigo != 4) {
      return items
            .fold(
                widget.pedidoItem.totalActual - (descuentoPorProducto * widget.pedidoItem.cantidadAcopio),
                (sum, item) =>
                    sum +
                    (item.nEstado == 1
                        ? item.SubTotal
                        : 0))
            .toStringAsFixed(2);
    }else {
      return '0.00';
    }
  }

  calculateTotalPedido() {
    if(this.widget.tipoRepesoSelected.codigo != 2 && this.widget.tipoRepesoSelected.codigo != 4) {
      return (widget.pedidoItem.totalActual - (descuentoPorProducto * widget.pedidoItem.cantidadAcopio)).toStringAsFixed(2);
    } else {
      return '0.0';
    }
  }

  void onPressedAceptarSave() async {
    requestCab.Uuid = uuid.v1();
    requestCab.Estado = "N";
    requestCab.Observacion =
        widget.productoSinPedido ? widget.motivoSelected : null;
    requestCab.nTipoBalanza = bluetoothBloc.Manual ? 0 : 1;
    if (soloVenta()) requestCab.ClienteTestaferro = requestCab.Cliente;
    for (var item in items) {
      item.Uuid = requestCab.Uuid;
    }

    //? TIPO DE VENTA (DIRECTA / REPARTO)
    if (widget.tipoRepesoSelected.codigo == 10) {
      if (widget._repesoVentaDirecta.codigo == 0)
        requestCab.Tipo = 0;
      else if (widget._repesoVentaDirecta.codigo == 1) requestCab.Tipo = 10;
    }
    //Request para guardar
    request = SaveRequest(requestCab, List.from(items));
    //* Llamada a Pedido BLOC

    //* PARA DEVOLUCIONES RETORNARNOS EL SAVE REQUEST Y SE EJECUTARA LA LLAMADA AL BACK EN LA VISTA ANTERIOR
    if(widget.tipoRepesoSelected.codigo == 4 || widget.tipoRepesoSelected.codigo == 2) {
      Navigator.of(context).pop();
      Navigator.pop(context, request);
      deletePesajes();
      return;
    }

    pedidoBloc.saveDataPesajes(request).then((response) async {
      if (response.nCodError == 0) {
        deletePesajes();

        Fluttertoast.showToast(
          msg: "Se grabó con éxito",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 20.0,
        );
        //* LLamada a pedido BLOC
        bool temp = await pedidoBloc.saveDataChangue(false);

        String uuid = response.oContenido.Uuid;

        //* Llamada a pedido BLOC
        List<SaveRequestCab> resp = await pedidoBloc.getPesajeCabesera(uuid);

        if (resp.isEmpty) {
          request.oCabecera.Numero = response.oContenido.Numero;
        } else {
          request.oCabecera.Numero = resp[0].Numero;
          request.oCabecera.nPedidoTestaferro = resp[0].nPedidoTestaferro;
        }
        if (soloVenta())
          mostarPedido(
              request.oCabecera.Numero,
              _selectedTestaferro.nombre,
              request.oCabecera.PuntoVenta.toString(),
              request.oCabecera.Pedido.toString());
        else {
          Navigator.of(context).pop();
          Navigator.pop(context, request);
        }
      } else {
        Fluttertoast.showToast(
          msg: response.cMsjError,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 20.0,
        );
      }
    });
  }
}
