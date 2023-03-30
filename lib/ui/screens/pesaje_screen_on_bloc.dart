import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollovivoapp/balanza/bloc/balanza_bloc.dart';
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

class PesajeScreenONBloc extends StatefulWidget {
  TipoRepeso tipoRepesoSelected;
  Cliente clienteSelected;
  Lote loteSelected;
  int puntoVenta;
  PedidoItem pedidoItem;
  LoginResponse loginResponse;
  RepartoItem repartoSelected;
  PesajeScreenONBloc(
    this.tipoRepesoSelected,
    this.clienteSelected,
    this.loteSelected,
    this.puntoVenta,
    this.pedidoItem,
    this.loginResponse,
    this.repartoSelected,
  );

  @override
  State<StatefulWidget> createState() {
    return _PesajeScreenONBlocState();
  }
}

class _PesajeScreenONBlocState extends State<PesajeScreenONBloc> {
  List<PesajeDetalleItem> items = List();
  bool _isLoadData = false;

  String _pesoBalanza, _numeroPesajes;
  SaveRequestCab requestCab;
  SaveRequest request;
  SharedPref saveLocal;
  List<double> AllPesos;
  String Shared_name;
  Future<String> _strData;
  int incidenciasNULL;
  double PrecioLoteProducto;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final _jabasController = TextEditingController();
  final _unidadesController = TextEditingController();
  final _PesoControles = TextEditingController();
  var ListObject;
  @override
  void initState() {
    super.initState();

    _pesoBalanza = "0";
    _numeroPesajes = "0";
    AllPesos = new List<double>();
    incidenciasNULL = 0;
    var descuentoProducto = widget.clienteSelected.descuento
        .firstWhere((element) => element.item1 == widget.pedidoItem.producto);
    PrecioLoteProducto = widget.loginResponse.loginData.lotes
            .firstWhere(
                (element) => element.codigo == widget.loteSelected.codigo)
            .precio -
        (descuentoProducto != null ? descuentoProducto.item2 : 0);
    int NumeroReparto;
    int itemReparro;
    if (widget.tipoRepesoSelected.codigo == 1) {
      NumeroReparto = widget.repartoSelected.numeroReparto;
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
        NumeroReparto,
        itemReparro); //Pesos_398_5_1
    saveLocal = new SharedPref();
    Shared_name = "Pesos_" +
        requestCab.Tipo.toString() +
        "_" +
        requestCab.Cliente.toString() +
        "_" +
        requestCab.Pedido.toString() +
        "_" +
        requestCab.ItemPedido.toString();

    _prefs.then((SharedPreferences prefs) {
      String strData = prefs.getString(Shared_name) ?? "";
      if (strData != "")
        setState(() {
          json.decode(strData)["oDetalle"].forEach((value) {
            items.add(PesajeDetalleItem.fromJson(value));
          });
        });
    });
    /*saveLocal.read(Shared_name).then((dynamic value) {
      return ( SaveRequest.fromJson(value).oDetalle);
    });*/

    if (balanzaBloc.bluetoothDevice != null)
      balanzaBloc.bluetoothDevice.discoverServices();
  }

  int getMaxItemPesaje() {
    int maximo = 0;
    for (PesajeDetalleItem item in items) {
      if (item.Item > maximo) maximo = item.Item;
    }
    return maximo;
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
    if (balanzaBloc.Manual) {
      if (_PesoControles.text == "") {
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
      moda = double.parse(_PesoControles.text.toString());
      _PesoControles.text = "";
    } else {
      if (AllPesos.length == 0) return;
      double promedio = 0.0;
      double ultimopeso = AllPesos.last;
      Map<double, int> m = new HashMap();

      for (var elemento in AllPesos) {
        if (elemento > ultimopeso - ultimopeso * 0.1) {
          promedio += elemento;
          if (m.containsKey(elemento))
            m[elemento] += 1;
          else
            m[elemento] = 1;
        }
      }
      promedio = promedio / AllPesos.length;

      int repeticiones = 1;
      //List<double> Modas= new List<double>();
      double Moda1 = 0.0;
      m.forEach((key, value) {
        if (key >= promedio) {
          if (value >= repeticiones) {
            repeticiones = value;
            Moda1 = moda;
            moda = key;
          }
        }
      });

      if (Moda1 != 0.0) moda = (moda + Moda1) / 2;
      moda = double.parse(moda.toStringAsFixed(2));
      AllPesos.clear();
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
      int total = items.fold(0, (sum, item) => sum + item.Unidades);
      if (widget.tipoRepesoSelected.codigo == 0) {
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
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.amber,
          textColor: Colors.black,
          fontSize: 20.0,
        );
      PesajeDetalleItem item = PesajeDetalleItem(
          1,
          getMaxItemPesaje() + 1,
          int.parse(_jabasController.text),
          int.parse(_unidadesController.text),
          moda);
      print(items.length.toString());
      item.SubTotal = (item.Kilos -
              item.Jabas *
                  widget.loginResponse.loginData.dataUsuario.taraJava) *
          PrecioLoteProducto;
      items.add(item);
      items.sort((a, b) => b.Item.compareTo(a.Item));

      request = SaveRequest(requestCab, items);
      saveLocal.save(Shared_name, request.toJson());
      _numeroPesajes = items.length.toString();
    } else {
      _PesoControles.text = moda.toString();
      Fluttertoast.showToast(
        msg: promedioPollo.toStringAsFixed(2) + " Promedio fuera de rango",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 20.0,
      );
    }
  }

  void deleteItemPesaje(int index) {
    items.removeAt(index);
    items.sort((a, b) => b.Item.compareTo(a.Item));
    request = SaveRequest(requestCab, items);
    saveLocal.save(Shared_name, request.toJson());
    _numeroPesajes = items.length.toString();
  }

  void deletePesajes() async {
    items.clear();
    saveLocal.remove(Shared_name);
    _numeroPesajes = items.length.toString();
    _jabasController.clear();
    _unidadesController.clear();
  }

  void saveDataPesajes() async {
    if (items.length == 0) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
          content: Text("¿Esta seguro de grabar todos los pesajes?"),
          actions: <Widget>[
            TextButton(
              child: Text(
                "ACEPTAR",
              ),
              onPressed: () async {
                await loginBloc.conexion(true).then((response) {
                  if (response) {
                    request = SaveRequest(requestCab, List.from(items));
                    pedidoBloc.saveDataPesajes(request).then((response) {
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
                        request.oCabecera.Numero = response.oContenido.Numero;
                        Navigator.of(context).pop();
                        Navigator.pop(context, request);
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
                });
              },
            ),
            TextButton(
              child: Text(
                "CANCELAR",
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
    setState(() {});
  }

  Future<List<int>> valueList(Stream<List<int>> value) async {
    return await value.first;
  }

  List<Widget> _buildIndicator(
      List<BluetoothService> services, double w, double h) {
    List<Widget> widgets = new List<Widget>();

    if (services.length <= 0) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            'Actualizar servicios bluetooth',
          ),
        ),
      );
      return widgets;
    }

    try {
      BluetoothService service = services.firstWhere((s) =>
          s.uuid.toString().toUpperCase().trim() ==
          balanzaBloc.Uuid); //"0000FF12-0000-1000-8000-00805F9B34FB"
      BluetoothCharacteristic char = service.characteristics.firstWhere((c) =>
          c.uuid.toString().toUpperCase().trim() ==
          "0000FF02-0000-1000-8000-00805F9B34FB");
      if (service != null && char != null) {
        widgets.addAll(_buildWidgetIndicator(char, w, h));
      }

      return widgets;
    } catch (e) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            'servicios bluetooth no adecuados',
          ),
        ),
      );
      return widgets;
    }
  }

  List<Widget> _buildWidgetIndicator(
      BluetoothCharacteristic characteristic, double w, double h) {
    List<Widget> widgets = new List<Widget>();

    if (!characteristic.isNotifying) characteristic.setNotifyValue(true);

    widgets.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.all(Radius.circular(5))),
          child: Center(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                // padding: EdgeInsets.fromLTRB(0.040 * w, 0.026 * w, 0.040 * w, 0.026 * w),
                child: StreamBuilder<List<int>>(
                  stream: characteristic.value,
                  initialData: [48, 46, 48, 48], //48, 46, 48, 48
                  builder: (c, snapshot) {
                    final value = snapshot.data;
                    if (value.length == 0) {
                      incidenciasNULL++;
                      print("Valor nulo de servicio");
                      if (incidenciasNULL > 1) {
                        Navigator.pop(context, false);
                        Fluttertoast.showToast(
                          msg: "!Conecion perdida con la balanza",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 20.0,
                        );
                        balanzaBloc.bluetoothDevice.disconnect();
                        balanzaBloc.stopScan();
                        balanzaBloc.bluetoothDevice = null;
                      }
                    } else {
                      incidenciasNULL = 0;
                      _pesoBalanza = String.fromCharCodes(value);
                      var peso = double.parse(_pesoBalanza);
                      if (peso < 0.05)
                        AllPesos.clear();
                      else
                        AllPesos.add(peso);
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          new String.fromCharCodes(value),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 60.0,
                              //height: 4.0,
                              fontWeight: FontWeight.bold),
                        ),
                        Text("   Kg     ",
                            textAlign: TextAlign.left,
                            style:
                                TextStyle(color: Colors.black, fontSize: 26.0))
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return widgets;
  }

  Widget reloadService() {
    if (balanzaBloc.Manual) {
      balanzaBloc.stopScan();
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 10.0,
                    height: 0,
                  ),
                  Flexible(
                    child: TextFormField(
                        inputFormatters: [
                          DecimalTextInputFormatter(decimalRange: 2)
                        ],
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.right,
                        controller: _PesoControles,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        //keyboardType: TextInputType.number,
                        style: TextStyle(
                            fontSize: 50.0,
                            //height: 4.0,
                            fontWeight: FontWeight.bold)),
                  ),
                  /*Text( "0.00",
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 60.0,
                  //height: 4.0,
                  fontWeight: FontWeight.bold
              ),
            ),*/
                  Text("   Kg     ",
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.black, fontSize: 26.0))
                ],
              )));
    } else {
      sleep(Duration(
          milliseconds:
              1500)); //if(balanzaBloc.bluetoothDevice.getSizeService()==0)
      return Card(
        margin: EdgeInsets.all(5.0),
        child: Container(
          width: double.infinity,
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothService>>(
                stream: balanzaBloc.bluetoothDevice.services,
                initialData: [],
                builder: (context, snapshot) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildIndicator(
                      snapshot.data,
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height,
                    ),
                    //children: _buildWidgetIndicatorCopy(),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
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
    await balanzaBloc.stopScan();
    Navigator.pop(context, null);
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext c) {
        return WillPopScope(
          onWillPop: () => onWillPopApp(c),
          child: Scaffold(
            appBar: AppBar(
              title: Text("Pesaje Pollo Vivo"),
              actions: <Widget>[
                if (!balanzaBloc.Manual)
                  Padding(
                    padding: EdgeInsets.only(right: 0),
                    child: GestureDetector(
                      child: IconButton(
                        icon: Icon(
                          Icons.refresh,
                          size: 32.0,
                        ),
                        onPressed: () =>
                            balanzaBloc.bluetoothDevice.discoverServices(),
                      ),
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
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      color: Colors.amberAccent.withOpacity(0.15),
                      child: Column(
                        children: <Widget>[
                          if (widget.tipoRepesoSelected.codigo != 3)
                            Text(
                                "Cliente: ${widget.clienteSelected.nombre.trim()}"),
                          Text(
                            "Lote: ${widget.loteSelected.numero.toString()} - ${widget.loteSelected.placa.trim()}",
                          ),
                          Text(
                              "Tipo de Repeso: ${widget.tipoRepesoSelected.nombre.trim()}"),
                          Text(
                            "Producto: ${widget.loteSelected.codigo.trim()} - ${widget.loteSelected.descripcion.trim()}",
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 2),
                    //color: Colors.black26,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "TOTAL:",
                          style: TextStyle(
                            fontSize: 14,
                            //fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "     S/." +
                              items
                                  .fold(0, (sum, item) => sum + item.SubTotal)
                                  .toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                          "${_numeroPesajes} pesajes",
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
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text(items[index].Jabas.toString()),
                            Text(items[index].Unidades.toString()),
                            Text(items[index].Kilos.toString()),
                            Text(items[index].SubTotal.toStringAsFixed(2)),
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
                            ),
                          ],
                        );
                      },
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
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange})
      : assert(decimalRange == null || decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}
