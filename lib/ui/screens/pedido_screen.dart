import 'dart:io';

import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollovivoapp/bloc/login_bloc.dart';
import 'package:pollovivoapp/model/cliente.dart';
import 'package:pollovivoapp/model/login_response.dart';
import 'package:pollovivoapp/model/lote.dart';
import 'package:pollovivoapp/model/lote_cab.dart';
import 'package:pollovivoapp/model/pedido_item.dart';
import 'package:pollovivoapp/model/pedido_response.dart';
import 'package:pollovivoapp/model/reintegro_data.dart';
import 'package:pollovivoapp/model/reparto_header.dart';
import 'package:pollovivoapp/model/reparto_item.dart';
import 'package:pollovivoapp/model/repeso_item.dart';
import 'package:pollovivoapp/model/save_request.dart';
import 'package:pollovivoapp/model/tipo_repeso.dart';
import 'package:pollovivoapp/repository/login_api_provider.dart';
import 'package:pollovivoapp/ui/screens/pesaje_edit_screen.dart';
import 'package:pollovivoapp/ui/screens/pesaje_screen.dart';
import 'package:pollovivoapp/ui/widgets/progresRefresActionBar.dart';
import 'package:pollovivoapp/ui/widgets/selectable_oneitem.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class PedidoScreen extends StatefulWidget {
  PedidoResponse pedidoResponse;
  TipoRepeso tipoRepesoSelected;
  Cliente clienteSelected;
  RepartoCabecera repartoSelected;
  int puntoVenta;
  LoginResponse loginResponse;
  List<Cliente> _clienteTestaferro;
  TipoRepeso _repesoSelected;

  PedidoScreen(
      this.pedidoResponse,
      this.tipoRepesoSelected,
      this.clienteSelected,
      this.repartoSelected,
      this.puntoVenta,
      this.loginResponse,
      this._clienteTestaferro,
      this._repesoSelected);

  @override
  _PedidoScreenState createState() => _PedidoScreenState();
}

class _PedidoScreenState extends State<PedidoScreen> {
  final controller = DragSelectGridViewController();
  final Dio dio = Dio();
  List<PedidoItem> _detalles = new List.empty(growable: true);
  PedidoItem _detalleSelected;
  List<DropdownMenuItem<PedidoItem>> _itemsDetalles =
      new List.empty(growable: true);
  List<DropdownMenuItem<TipoRepeso>> _itemsTipoDev =
      new List.empty(growable: true);
  List<DropdownMenuItem<TipoRepeso>> _itemsMotivoDev =
      new List.empty(growable: true);
  List<LotePrincipal> loteCabList = new List.empty(growable: true);
  LotePrincipal loteCabSelect;

  List<Lote> loteList = new List.empty(growable: true);
  Lote loteSelect;

  int indexSubloteSelected = -1;
  bool descargando;
  TipoRepeso _devSelected, _motiSelected;

  String _motivoSelected;
  List<String> _motivos = [];

  bool productoSinPedido = false;

  bool blockButoon = false;

  @override
  void initState() {
    super.initState();
    _motivos = widget.loginResponse.loginData.motivos;
    _motivoSelected = _motivos[0];

    descargando = false;
    if (widget.pedidoResponse.nCodError == 0) {
      controller.addListener(scheduleRebuild);
      _detalles = widget.pedidoResponse.pedidoData.pedidoDetalles;

      //detalle --------- sin pedido

      //_lotes
      int numant = 0, i = 0;
      for (Lote item in widget.loginResponse.loginData.lotes) {
        // restriccion Producto
        //	if(!_detalles.any((element) => element.Producto==item.Codigo)) continue;
        if (numant != item.lotePrincipal) {
          LotePrincipal temp = LotePrincipal(item.lotePrincipal, item.placa);
          temp.index = i;
          loteCabList.add(temp);
        }
        numant = item.lotePrincipal;
        i++;
      }
      if (widget.tipoRepesoSelected.codigo != 1 && loteCabList.length > 0) {
        loteCabSelect = loteCabList[0];
        loadLote();
        for (var item in widget.loginResponse.loginData.tiposDevolucion) {
          _itemsTipoDev.add(DropdownMenuItem(
            value: item,
            child: Text(item.nombre),
          ));
        }
        _devSelected = _itemsTipoDev[0].value;

        for (var item in widget.loginResponse.loginData.motivosDevolucion) {
          _itemsMotivoDev.add(DropdownMenuItem(
            value: item,
            child: Text(item.nombre),
          ));
        }
        _motiSelected = _itemsMotivoDev[0].value;
      } else
        loadRepartos();
    }
  }

  void loadRepartos() {
    indexSubloteSelected = -1;
    loteSelect = null;
    RepartoItem itemReparto = null;
    for (var item in widget.repartoSelected.items) {
      if (item.disponible > 0) {
        indexSubloteSelected = int.parse(item.rumas.split(',')[0]);
        itemReparto = item;
      }
    }
    if (indexSubloteSelected >= 0) {
      loteSelect = widget.loginResponse.loginData.lotes.firstWhere(
          (element) => element.numero == itemReparto.loteNumero,
          orElse: () => null);

      if (!loadPedidosSelected()) indexSubloteSelected = -1;
    } else
      loadPedidosSelected();
  }

  Color colorLote(Lote lote, int index) {
    if (lote.codigo == '01102' || lote.codigo == '01103')
      return Colors.pink[700];
    else if (lote.codigo == '01120')
      return Colors.blue[900];
    else
      return loginBloc.colors[index];
  }

  void loadLote() {
    loteList.clear();
    loteSelect = null;
    int i = 0;
    for (Lote item in widget.loginResponse.loginData.lotes) {
      /*if (item.LotePrincipal == LoteCabSelect.Numero) {*/
      item.colorLote = colorLote(item, i);
      loteList.add(item);
      /*}*/
      i++;
    }
    for (var item in loteList) {
      if (loteSelect == null &&
          isSelected(item.numero) &&
          (item.disponible > 0 || widget.tipoRepesoSelected.codigo > 1))
        loteSelect = item;
    }
    loadPedidosSelected();
    //LoteSelect=loteList[0];
  }

// restriccion Producto
  bool isSelected(int Lote) {
    String CodProd = widget.loginResponse.loginData.lotes
        .firstWhere((element) => element.numero == Lote)
        .codigo;
    //return _detalles.any((element) => element.Producto==CodProd);
    return true;
  }

  bool alertaSinProducto() {
    bool existeProductoPedidoInLote = false;
    for (var lote in widget.loginResponse.loginData.lotes) {
      for (var pedido in _detalles) {
        if (lote.codigo == pedido.producto) existeProductoPedidoInLote = true;
      }
    }
    bool cantidadZero = false;
    for (var element in _detalles) {
      if (element.cantidad == 0) cantidadZero = true;
    }
    return (!existeProductoPedidoInLote) || cantidadZero;
  }

  bool loadPedidosSelected() {
    _detalleSelected = null;
    _itemsDetalles = List.empty(growable: true);
    if (loteSelect == null) return false;
    for (var item in _detalles) {
      if (item.producto == loteSelect.codigo) {
        _itemsDetalles.add(DropdownMenuItem(
          value: item,
          child: Text("Pedido ${item.numeroPedido}"),
        ));
      }
    }
    if (_itemsDetalles.length > 0) {
      _itemsDetalles.sort((a, b) => -(a.value.cantidad - a.value.cantidadRP));
      _detalleSelected = _itemsDetalles[0].value;
      return true;
    } else
      return false;
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  downloadFile() async {
    setState(() {
      descargando = true;
    });
    String fechaHoy = DateFormat("dd-MM-yyyy").format(DateTime.now());
    String Nombre = "Pesaje_${widget.clienteSelected.codigo}_$fechaHoy.pdf";
    bool downloaded = await saveToFile(
        LoginApiProvider.BASE_URL +
            "/DescargarPesadas?nPuntoVenta=${widget.puntoVenta}&nCliente=${widget.clienteSelected.codigo}&nTipo=${widget.tipoRepesoSelected.codigo}&dFecha=" +
            fechaHoy,
        Nombre);
    if (downloaded) {
      print("File Downloaded");
      Fluttertoast.showToast(
          msg: "Descarga Exitosa! revise su carpeta Descargas/PesajeRico",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 20.0);
      setState(() {
        descargando = false;
      });
    } else {
      print("Problem Downloading File");
      Fluttertoast.showToast(
          msg: "Ocurrio un problema al descargar",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 20.0);
      setState(() {
        descargando = false;
      });
    }
  }

  Future<bool> saveToFile(String url, String nombre) async {
    Directory directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = await getExternalStorageDirectory();
          String newPath = "";
          print(directory);
          List<String> paths = directory.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          newPath = newPath + "/Download/PesajeRico";
          directory = Directory(newPath);
        } else {
          return false;
        }
      }
      File saveFile = File(directory.path + "/${nombre}");
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        dio.options.headers["cookie"] =
            loginBloc.loginRepository.loginApiProvider.aToken;
        await dio.download(url, saveFile.path,
            onReceiveProgress: (received, total) {
          /*	setState(() {
								file.progress = (received / file.nSize).abs();
								print(file.progress);
							});*/
          print(received);
          print(total);
          if (received == total) print('FINALIZO');
        });

        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var buttonListWidth = MediaQuery.of(context).size.width - 100;
    return Scaffold(
      appBar: renderAppBar(),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          child: Column(
            children: <Widget>[
              renderClienteYTipo(),
              Expanded(
                flex: -5,
                child: renderTableHeader(),
              ),
              Container(
                height: _detalles.length * 28.0,
                child: renderTablePedidosContent(),
              ),
              if (widget.tipoRepesoSelected.codigo != 1 &&
                  loteCabSelect != null)
                renderRanflaSelect(buttonListWidth),
              if (widget.tipoRepesoSelected.codigo == 1)
                Container(
                    height: 60,
                    padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                    color: Colors.white30,
                    child: ListView(
                      padding: const EdgeInsets.all(8),
                      children: <Widget>[
                        Container(
                          height: 50,
                          color: Colors.black87,
                          child: Center(
                              child: Text(
                            'REPARTO ' + widget.repartoSelected.Nombre,
                            style: TextStyle(
                              fontSize: 23,
                              color: Colors.white,
                            ),
                          )),
                        ),
                      ],
                    )),
              if (widget.tipoRepesoSelected.codigo == 1)
                Container(
                    padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                    height: widget.repartoSelected.Filas * 47.5, //51.3,
                    color: Colors.white30,
                    child: DragSelectGridView(
                      gridController: controller,
                      padding: const EdgeInsets.all(8),
                      itemCount: widget.repartoSelected.Filas *
                          widget.repartoSelected.Columnas,
                      itemBuilder: (context, index, selected) {
                        Color colorSublote = null;
                        String title;
                        for (var item in widget.repartoSelected.items) {
                          if (item.rumas
                                  .split(',')
                                  .map(int.parse)
                                  .toList()
                                  .contains(index) &&
                              item.disponible > 0) {
                            int indexColor = widget
                                .loginResponse.loginData.lotes
                                .indexWhere((element) =>
                                    element.numero == item.loteNumero);
                            if (indexColor == -1)
                              colorSublote = Colors.grey[800];
                            else {
                              colorSublote = loginBloc.colors[indexColor];

                              selected = item.rumas
                                  .split(',')
                                  .map(int.parse)
                                  .toList()
                                  .contains(indexSubloteSelected);

                              int size = item.rumas.split(',').length;
                              var producto = widget
                                  .loginResponse.loginData.lotes
                                  .firstWhere((element) =>
                                      element.numero == item.loteNumero);
                              if (size == 1) {
                                title = producto.codigo +
                                    "\n" +
                                    item.disponible.toString();
                              } else if (size > 1 &&
                                  index.toString() ==
                                      item.rumas.split(',')[0]) {
                                title = producto.codigo + "\n" + "Producto";
                              } else if (size > 1 &&
                                  index.toString() ==
                                      item.rumas.split(',')[1]) {
                                title = item.disponible.toString() +
                                    "\n" +
                                    "Unidades";
                              } else if (size > 2 &&
                                  index.toString() ==
                                      item.rumas.split(',')[2]) {
                                title = producto.descripcion
                                    .replaceAll("POLLO VIVO", "");
                              }
                            }
                          }
                        }
                        return SelectableOneItem(
                            index: index,
                            color: colorSublote == null
                                ? Colors.black45
                                : colorSublote,
                            selected: !selected,
                            onTap: () {
                              int indexitem = widget.repartoSelected.items
                                  .indexWhere((element) => element.rumas
                                      .split(',')
                                      .map(int.parse)
                                      .contains(index));
                              if (indexitem >= 0 &&
                                  widget.repartoSelected.items[indexitem]
                                          .disponible >
                                      0)
                                setState(() {
                                  loteSelect = widget
                                      .loginResponse.loginData.lotes
                                      .firstWhere((element) =>
                                          element.numero ==
                                          widget.repartoSelected
                                              .items[indexitem].loteNumero);
                                  if (isSelected(loteSelect.numero)) {
                                    loadPedidosSelected();
                                    indexSubloteSelected = index;
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            "El Cliente no tiene ningun pedido con este Lote.",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.amber,
                                        textColor: Colors.black,
                                        fontSize: 20.0);
                                  }
                                  /* //Valida que solo pueda seleccionar el sublote de la cola del camion
														if(indexitem == widget.repartoSelected.items.length-1) indexSubloteSelected =index;
														else if(widget.repartoSelected.items[indexitem+1].Disponible != widget.repartoSelected.items[indexitem+1].Unidades) {
															indexSubloteSelected =index;
														}*/
                                });
                              //Fluttertoast.showToast( msg: "Cick en el item ${index+1}");
                            },
                            Title: title);
                      },
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        //  maxCrossAxisExtent: 100,
                        childAspectRatio: (2 / 1),
                        crossAxisCount: widget.repartoSelected.Columnas,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                    )),
              if (widget.tipoRepesoSelected.codigo == 2)
                Container(
                  padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                  child: DropdownButton<TipoRepeso>(
                    value: _devSelected,
                    items: _itemsTipoDev,
                    onChanged: (TipoRepeso value) {
                      setState(() => _devSelected = value);
                    },
                    iconSize: 30.0,
                    isExpanded: true,
                  ),
                ),
              if (widget.tipoRepesoSelected.codigo == 2 &&
                  _devSelected.codigo == 2)
                Container(
                  padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                  child: DropdownButton<TipoRepeso>(
                    value: _motiSelected,
                    items: _itemsMotivoDev,
                    onChanged: (TipoRepeso value) {
                      setState(() => _motiSelected = value);
                    },
                    iconSize: 30.0,
                    isExpanded: true,
                  ),
                ),
              if (widget.tipoRepesoSelected.codigo != 3 &&
                  _itemsDetalles.length > 1)
                Container(
                  padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                  child: DropdownButton<PedidoItem>(
                    value: _detalleSelected,
                    items: _itemsDetalles,
                    onChanged: (PedidoItem value) {
                      setState(() => _detalleSelected = value);
                    },
                    iconSize: 30.0,
                    isExpanded: true,
                  ),
                ),
              //? BOTON SIGUIENTE
              Container(
                margin: EdgeInsets.only(top: 7.0, left: 50.0, right: 50.0),
                child: MaterialButton(
                  onPressed: onPressedButtonSiguiente,
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: Text(
                    "Siguiente",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  minWidth: 350,
                  height: 45,
                ),
              ),
              if (alertaSinProducto())
                Container(
                  margin: EdgeInsets.fromLTRB(50, 50, 50, 50),
                  padding: EdgeInsets.fromLTRB(0, 50, 0, 50),
                  child: DropdownButton<String>(
                    value: _motivoSelected,
                    items: _motivos
                        .map(
                          (data) => DropdownMenuItem<String>(
                            child: Text('Motivo:  $data'),
                            value: data,
                          ),
                        )
                        .toList(),
                    onChanged: (String value) {
                      setState(() => {_motivoSelected = value});
                    },
                    iconSize: 30.0,
                    isExpanded: true,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  void loadRequestData(SaveRequest request) {
    // agregamos los pesos para su edicion:
    print('LoadRequestData entro doble');
    request.oDetalle =
        request.oDetalle.where((element) => element.nEstado == 1).toList();
    for (var item in request.oDetalle) {
      widget.pedidoResponse.pedidoData.repesoDetalle.add(new RepesoItem(
          request.oCabecera.Pedido,
          request.oCabecera.Numero,
          item.Item,
          request.oCabecera.LoteNumero,
          request.oCabecera.NumeroPR,
          request.oCabecera.ItemPR,
          item.Kilos,
          item.Jabas,
          item.Unidades,
          request.oCabecera.Tipo,
          null));
    }
    // actualizamos la cantidad de repesos de los pedidos
    // buscamos el codigo de producto mediante el lote del producto
    var producto = widget.loginResponse.loginData.lotes.firstWhere(
        (element) => element.numero == request.oCabecera.LoteNumero);
    var PedidoEdit = _detalles.where((item) =>
        item.numeroPedido == request.oCabecera.Pedido &&
        item.item == request.oCabecera.ItemPedido &&
        item.producto == producto.codigo);
    var sumaRP = request.oDetalle.fold(0, (sum, item) => sum + item.Unidades);
    print(sumaRP);
    if (PedidoEdit.length > 0) {
      PedidoEdit.first.cantidadRP += sumaRP;
      if (widget.tipoRepesoSelected.codigo == 0 ||
          (widget.tipoRepesoSelected.codigo == 10 &&
              widget._repesoSelected.codigo == 0))
        PedidoEdit.first.cantidadAcopio += sumaRP;
      if (widget.tipoRepesoSelected.codigo == 1 ||
          (widget.tipoRepesoSelected.codigo == 10 &&
              widget._repesoSelected.codigo == 1))
        PedidoEdit.first.cantidadReparto += sumaRP;
      if (widget.tipoRepesoSelected.codigo == 2 ||
          widget.tipoRepesoSelected == 4)
        PedidoEdit.first.cantidadDevolucion += sumaRP;
      if (widget.tipoRepesoSelected.codigo == 3)
        PedidoEdit.first.cantidad -= sumaRP;
    } else {
      var data =
          new PedidoItem(request.oCabecera.Pedido, 0, producto.codigo, sumaRP);
      data.initCantidad();
      if (widget.tipoRepesoSelected.codigo == 0 ||
          (widget.tipoRepesoSelected.codigo == 10 &&
              widget._repesoSelected.codigo == 0))
        data.cantidadAcopio += sumaRP;
      if (widget.tipoRepesoSelected.codigo == 1 ||
          (widget.tipoRepesoSelected.codigo == 10 &&
              widget._repesoSelected.codigo == 1))
        data.cantidadReparto += sumaRP;
      if (widget.tipoRepesoSelected.codigo == 2 ||
          widget.tipoRepesoSelected.codigo == 4) data.cantidadDevolucion += sumaRP;
      if (widget.tipoRepesoSelected.codigo == 3) data.cantidad -= sumaRP;
      _detalles.add(data);
      print(data.toString());
    }
    // actualizamos la cantidad disponible de los lotes
    if (request.oCabecera.Tipo == 0) {
      for (var item in widget.loginResponse.loginData.lotes) {
        if (item.numero == request.oCabecera.LoteNumero)
          item.disponible -=
              request.oDetalle.fold(0, (sum, item) => sum + item.Unidades);
      }
      loadLote();
    } else if (request.oCabecera.Tipo == 2) {
      for (var item in widget.loginResponse.loginData.lotes) {
        if (item.numero == request.oCabecera.LoteNumero)
          item.disponible +=
              request.oDetalle.fold(0, (sum, item) => sum + item.Unidades);
      }
      loadLote();
    } else {
      // actualizamos la cantidad disponible de los sublotes
      for (var item in widget.repartoSelected.items) {
        if (item.numeroReparto == request.oCabecera.NumeroPR &&
            item.item == request.oCabecera.ItemPR)
          item.disponible -=
              request.oDetalle.fold(0, (sum, item) => sum + item.Unidades);
      }
      loadRepartos();
    }
  }

  TextStyle styeLotesRanfla = TextStyle(
    fontSize: 14,
    color: Colors.white,
  );

  Widget listViewItem({int index, double itemsize, Lote item}) {
    double radio = 0, borders = 0;
    Color relleno = item.colorLote;
    if (loteSelect != null && loteSelect.numero == item.numero) {
      radio = 8;
      borders = 2;
      relleno = relleno.withOpacity(0.8);
    }
    return GestureDetector(
        child: Container(
            height: 100,
            width: itemsize - 2,
            margin: const EdgeInsets.only(left: 1, right: 1),
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radio),
                border: Border.all(color: item.colorLote, width: borders),
                color: relleno),
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Und: " + item.disponible.toString(),
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                Text(
                  item.codigo,
                  style: styeLotesRanfla,
                ),
                Text(item.descripcion.replaceAll("POLLO VIVO", "PV"),
                    style: styeLotesRanfla),
                Text(item.numero.toString(), style: styeLotesRanfla)
              ],
            )

                // Text(
                //   item.Codigo +
                //       "\n" +
                //       item.Descripcion.replaceAll("POLLO VIVO", "PV") +
                //       "\n" +
                //       item.Disponible.toString() +
                //       " UND\n" +
                //       item.Numero.toString(),
                //   style: TextStyle(
                //     fontSize: 14,
                //     color: Colors.white,
                //   ),
                // )
                ) // just for the demo, you can pass optionsChoices()
            ),
        onTap: () {
          if (loteSelect == null) {
            Fluttertoast.showToast(
                msg: "Lote no disponible",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.amber,
                textColor: Colors.black,
                fontSize: 20.0);
            return;
          }
          if (loteSelect.numero != item.numero) {
            if (isSelected(item.numero)) {
              if (item.disponible > 0 || widget.tipoRepesoSelected.codigo > 1)
                setState(() {
                  loteSelect = item;
                  loadPedidosSelected();
                });
              else
                Fluttertoast.showToast(
                    msg:
                        "Lote sin unidades, consulte con el administrador en caso exista exceso.",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.amber,
                    textColor: Colors.black,
                    fontSize: 20.0);
            } else {
              Fluttertoast.showToast(
                msg: "El Cliente no tiene ningun pedido con este Lote.",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.amber,
                textColor: Colors.black,
                fontSize: 20.0,
              );
            }
          }
        });
  }

  void scheduleRebuild() => setState(() {});

  Widget renderAppBar() {
    return AppBar(
      backgroundColor: loginBloc.online ? null : Colors.amber,
      title: Text(widget.loginResponse.loginData.tiposRepeso
          .firstWhere(
              (element) => element.codigo == widget.tipoRepesoSelected.codigo)
          .nombre),
      actions: [
        if (widget.tipoRepesoSelected.codigo != 3)
          ProgressRefreshAction(descargando, Icons.filter_frames, downloadFile)
      ],
    );
  }

  @override
  void dispose() {
    controller.removeListener(scheduleRebuild);
    super.dispose();
  }

  Widget renderClienteYTipo() {
    return Card(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: <Widget>[
            if (widget.tipoRepesoSelected.codigo != 3)
              Text("Cliente: ${widget.clienteSelected.nombre.trim()}"),
            if (widget.tipoRepesoSelected.codigo != 3) SizedBox(height: 10.0),
            Text("Tipo de Repeso: ${widget.tipoRepesoSelected.nombre.trim()}"),
          ],
        ),
      ),
    );
  }

  Widget renderTableHeader() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(widget.tipoRepesoSelected.codigo == 3 ? "   Lote" : "Pedido",
              style: TextStyle(fontWeight: FontWeight.w500)),
          Text("Producto", style: TextStyle(fontWeight: FontWeight.w500)),
          Text("Und", style: TextStyle(fontWeight: FontWeight.w500)),
          Text("RP T", style: TextStyle(fontWeight: FontWeight.w500)),
          if (widget.tipoRepesoSelected.codigo == 0 ||
              (widget.tipoRepesoSelected.codigo == 10 &&
                  widget._repesoSelected.codigo == 0))
            Text("RP A", style: TextStyle(fontWeight: FontWeight.w500)),
          if (widget.tipoRepesoSelected.codigo == 1 ||
              (widget.tipoRepesoSelected.codigo == 10 &&
                  widget._repesoSelected.codigo == 1))
            Text("RP R", style: TextStyle(fontWeight: FontWeight.w500)),
          if (widget.tipoRepesoSelected.codigo == 2)
            Text("RP D", style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget renderTablePedidosContent() {
    return ListView.builder(
      itemCount: _detalles.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
            onDoubleTap: () async {
              if (true) {
                var lotes = widget.loginResponse.loginData.lotes
                    .where((element) =>
                        element.codigo == _detalles[index].producto)
                    .toList();
                if (lotes.length == 0) {
                  Fluttertoast.showToast(
                      msg: "No se detectaron productos relacionados al lote",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.amber,
                      textColor: Colors.black,
                      fontSize: 20.0);
                  return;
                }
                if (widget.tipoRepesoSelected.codigo == 1) {
                  if (!widget.pedidoResponse.pedidoData.repesoDetalle.any(
                      (element) =>
                          element.NumeroPR ==
                              widget.repartoSelected.NumeroReparto &&
                          element.Pedido == _detalles[index].numeroPedido &&
                          lotes.any(
                              (item) => item.numero == element.LoteNumero))) {
                    Fluttertoast.showToast(
                        msg: "No se detectaron pesos relacionados para editar",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.amber,
                        textColor: Colors.black,
                        fontSize: 20.0);
                    return;
                  }
                }
                List<ReintegroLote> request = await Navigator.push(
                    context,
                    new MaterialPageRoute<List<ReintegroLote>>(
                        builder: (context) => PesajeEditScreen(
                            widget.tipoRepesoSelected,
                            widget.clienteSelected,
                            lotes,
                            widget.loginResponse,
                            _detalles[index],
                            widget.pedidoResponse.pedidoData.repesoDetalle,
                            widget.repartoSelected,
                            widget._clienteTestaferro,
                            widget._repesoSelected)));
                if (request != null)
                  setState(() {
                    for (ReintegroLote item in request) {
                      _detalles[index].cantidadRP += item.Unidades;
                      if (widget.tipoRepesoSelected.codigo == 0 ||
                          (widget.tipoRepesoSelected.codigo == 10 &&
                              widget._repesoSelected.codigo == 0)) {
                        _detalles[index].cantidadAcopio += item.Unidades;
                      } else if (widget.tipoRepesoSelected.codigo == 1 ||
                          (widget.tipoRepesoSelected.codigo == 10 &&
                              widget._repesoSelected.codigo == 1)) {
                        _detalles[index].cantidadReparto += item.Unidades;
                      } else if (widget.tipoRepesoSelected.codigo == 2) {
                        _detalles[index].cantidadDevolucion += item.Unidades;
                      }

                      if (widget.tipoRepesoSelected.codigo == 0 ||
                          (widget.tipoRepesoSelected.codigo == 10 &&
                              widget._repesoSelected.codigo == 0)) {
                        var obj = widget.loginResponse.loginData.lotes
                            .firstWhere(
                                (element) => element.numero == item.Numero,
                                orElse: () => null);
                        if (obj != null) obj.disponible -= item.Unidades;
                      } else if (widget.tipoRepesoSelected.codigo == 1 ||
                          (widget.tipoRepesoSelected.codigo == 10 &&
                              widget._repesoSelected.codigo == 1)) {
                        var obj = widget.repartoSelected.items.firstWhere(
                            (element) => element.loteNumero == item.Numero,
                            orElse: () => null);
                        if (obj != null) obj.disponible -= item.Unidades;
                      }
                    }
                    if (widget.tipoRepesoSelected.codigo != 2)
                      widget.tipoRepesoSelected.codigo == 0
                          ? loadLote()
                          : loadRepartos();
                  });
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(_detalles[index].numeroPedido.toString().padLeft(5, "  "),
                    style: TextStyle(
                        height: 2,
                        color: _detalles[index].cantidad >
                                _detalles[index].cantidadRP
                            ? Colors.black
                            : Colors.red)),
                Text(_detalles[index].producto.toString(),
                    style: TextStyle(
                        height: 2,
                        color: _detalles[index].cantidad >
                                _detalles[index].cantidadRP
                            ? Colors.black
                            : Colors.red)),
                Text(_detalles[index].cantidad.toString().padLeft(4, "  "),
                    style: TextStyle(
                        height: 2,
                        color: _detalles[index].cantidad >
                                _detalles[index].cantidadRP
                            ? Colors.black
                            : Colors.red)),
                Text(_detalles[index].cantidadRP.toString().padLeft(4, "  "),
                    style: TextStyle(
                        height: 2,
                        color: _detalles[index].cantidad >
                                _detalles[index].cantidadRP
                            ? Colors.black
                            : Colors.red)),
                if (widget.tipoRepesoSelected.codigo == 0 ||
                    (widget.tipoRepesoSelected.codigo == 10 &&
                        widget._repesoSelected.codigo == 0))
                  Text(
                      _detalles[index]
                          .cantidadAcopio
                          .toString()
                          .padLeft(4, "  "),
                      style: TextStyle(
                          height: 2,
                          color: _detalles[index].cantidad >
                                  _detalles[index].cantidadRP
                              ? Colors.black
                              : Colors.red)),
                if (widget.tipoRepesoSelected.codigo == 1 ||
                    (widget.tipoRepesoSelected.codigo == 10 &&
                        widget._repesoSelected.codigo == 1))
                  Text(
                      _detalles[index]
                          .cantidadReparto
                          .toString()
                          .padLeft(4, "  "),
                      style: TextStyle(
                          height: 2,
                          color: _detalles[index].cantidad >
                                  _detalles[index].cantidadRP
                              ? Colors.black
                              : Colors.red)),
                if (widget.tipoRepesoSelected.codigo == 2)
                  Text(
                      _detalles[index]
                          .cantidadDevolucion
                          .toString()
                          .padLeft(4, "  "),
                      style: TextStyle(
                          height: 2,
                          color: _detalles[index].cantidad >
                                  _detalles[index].cantidadRP
                              ? Colors.black
                              : Colors.red)),
              ],
            ));
      },
    );
  }

  Widget renderRanflaSelect(double buttonListWidth) {
    return Container(
        height: 100,
        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  if (loteCabList.length > 1)
                    setState(() {
                      int index = loteCabList.indexWhere((element) =>
                              element.index == loteCabSelect.index) +
                          1;
                      if (index >= loteCabList.length) index = 0;
                      loteCabSelect = loteCabList[index];
                      loadLote();
                    });
                },
                child: Container(
                    width: 50.0,
                    color: Colors.black87,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Center(
                          child: Text(loteCabSelect.Placa.trim(),
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20))),
                    ))),
            ListView.builder(
              itemCount: loteList.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) {
                return listViewItem(
                    index: i,
                    itemsize: buttonListWidth / loteList.length,
                    item: loteList[i]); // item layout
              },
            ),
          ],
        ));
  }

  void onPressedButtonSiguiente() async {
    if (!blockButoon) {
      blockButoon = true;
      RepartoItem _repartoSelect;
      TipoRepeso _repesoSelect = new TipoRepeso(
          widget.tipoRepesoSelected.codigo, widget.tipoRepesoSelected.nombre);
      
      //? NO ES PARA VENTA
      if (widget.tipoRepesoSelected.codigo == 1) {
        if (_detalles.indexWhere(
                (element) => element.producto == loteSelect.codigo) ==
            -1) {
          Fluttertoast.showToast(
            msg: "Producto no asocioado al pedido y al reparto",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.amber,
            textColor: Colors.black,
            fontSize: 20.0,
          );
          return;
        }
        if (indexSubloteSelected < 0) {
          Fluttertoast.showToast(
            msg: "Seleccione un Sublote de reparto",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 20.0,
          );
          return;
        }
        _repartoSelect = widget.repartoSelected.items.firstWhere((element) =>
            element.rumas
                .split(',')
                .map(int.parse)
                .contains(indexSubloteSelected));
      //? TAMPOCO ES PARA VENTA
      } else if (widget.tipoRepesoSelected.codigo == 2) {
        /*if (widget.pedidoResponse.pedidoData.repesoDetalle.any(
                          (element) =>
                              element.LoteNumero == LoteSelect.Numero &&
                              element.Tipo < 2))
                        _RepesoSelect = new TipoRepeso(
                            _devSelected.Codigo,
                            widget.tipoRepesoSelected.Nombre +
                                (_devSelected.Codigo != 2
                                    ? ""
                                    : " " + _devSelected.Nombre));
                      else {
                        Fluttertoast.showToast(
                            msg: "No existe pesadas de dicho lote",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 20.0
                        );
                        return;
                      }*/
      //? TAMPOCO ES PARA VENTA
      } else if (widget.tipoRepesoSelected.codigo == 3) {
        if (loteSelect.unidades == loteSelect.disponible) {
          Fluttertoast.showToast(
              msg: "Lote sin pesajes para aceptar devoluciones",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 20.0);
          return;
        }
      }

      //? ACA ACTUA PARA TODOS SI NO HAY UN LOTE SELECCIONADO
      if (loteSelect == null) {
        Fluttertoast.showToast(
          msg: "Seleccione un Lote",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 20.0,
        );
        return;
      }
      //? SELECCIONA EL PRIMERO PEDIDO SI NO SE SELECCIONO ALGUNO
      if (_detalleSelected == null && _detalles.length > 0)
        _detalleSelected = _detalles[0];

      //? PARA VENTA VALIDAR SI EL LOTE SELECCIONADO CONTIENE PEDIDOS
      if (widget.tipoRepesoSelected.codigo == 0 ||
          widget.tipoRepesoSelected.codigo == 10) {
        int data = widget.pedidoResponse.pedidoData.pedidoDetalles
            .indexWhere((element) => element.producto == loteSelect.codigo);
        
        if (data == -1) {
          productoSinPedido = true;
          int numeroPedio = _detalleSelected != null
              ? _detalleSelected.numeroPedido
              : _detalles[0].numeroPedido;
          _detalleSelected = PedidoItem(numeroPedio, 0, loteSelect.codigo, 0);
          _detalleSelected.initCantidad();
          Fluttertoast.showToast(
              msg: "Lote no tiene pedidos",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 20.0);
          // return;
        }
      }

      // if(widget.tipoRepesoSelected.Codigo != 3)
      //   if(_detalleSelected != null && _detalleSelected.Cantidad < _detalleSelected.CantidadRP){
      //     Fluttertoast.showToast(
      //         msg: "Pedido ha sido completado",
      //         toastLength: Toast.LENGTH_LONG,
      //         gravity: ToastGravity.BOTTOM,
      //         backgroundColor: Colors.amber,
      //         textColor: Colors.black,
      //         fontSize: 20.0
      //     );
      //     return;
      //   }

      //* Navegamos a PesajeScreen y esperamos la respuesta 
          SaveRequest request = await Navigator.push(
          context,
          new MaterialPageRoute<SaveRequest>(
              builder: (context) => PesajeScreen(
                  _repesoSelect,
                  widget.clienteSelected,
                  loteSelect,
                  widget.puntoVenta,
                  _detalleSelected,
                  widget.loginResponse,
                  _repartoSelect,
                  _motivoSelected,
                  productoSinPedido,
                  widget._clienteTestaferro,
                  widget._repesoSelected)));
      blockButoon = false;
      setState(() {
        if (request != null) {
          loadRequestData(request);
        }
        //if(widget.tipoRepesoSelected.Codigo==0 || widget.tipoRepesoSelected.Codigo==2)	loadLote();									 else
      });
    }
  }
}
