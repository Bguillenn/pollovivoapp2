import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollovivoapp/bloc/login_bloc.dart';
import 'package:pollovivoapp/bloc/pedido_bloc.dart';
import 'package:pollovivoapp/model/cliente.dart';
import 'package:pollovivoapp/model/login_response.dart';
import 'package:pollovivoapp/model/lote.dart';
import 'package:pollovivoapp/model/pedido_item.dart';
import 'package:pollovivoapp/model/pesaje_detalle_item.dart';
import 'package:pollovivoapp/model/reintegro_data.dart';
import 'package:pollovivoapp/model/reparto_header.dart';
import 'package:pollovivoapp/model/reparto_item.dart';
import 'package:pollovivoapp/model/repeso_item.dart';
import 'package:pollovivoapp/model/save_request.dart';
import 'package:pollovivoapp/model/save_request_cab.dart';
import 'package:pollovivoapp/model/tipo_repeso.dart';
import 'package:pollovivoapp/ui/widgets/input_custom.dart';

class PesajeEditScreen extends StatefulWidget {
  LoginResponse response;
  Cliente clienteSelected;
  List<Lote> lotesSelected;
  TipoRepeso tipoRepesoSelected;
  PedidoItem pedidoSelected;
  List<RepesoItem> repesoPedidoSelect;
  RepartoCabecera repartoSelected;
  int puntoVenta;
  List<Cliente> _clienteTestaferros;
  TipoRepeso _tipoRepesoSelected10;

  PesajeEditScreen(
      this.tipoRepesoSelected,
      this.clienteSelected,
      this.lotesSelected,
      this.response,
      this.pedidoSelected,
      this.repesoPedidoSelect,
      this.repartoSelected,
      this._clienteTestaferros,
      this._tipoRepesoSelected10) {
    puntoVenta = response.loginData.dataUsuario.puntoVentaCodigo;
  }

  @override
  _PesajeEditScreenState createState() => _PesajeEditScreenState();
}

class _PesajeEditScreenState extends State<PesajeEditScreen> {
  final _jabasController = TextEditingController();
  final _unidadesController = TextEditingController();
  final _PesoControles = TextEditingController();
  int _numeroItems, indexEdit = -1;
  List<RepesoItem> items = List.empty(growable: true);
  List<RepesoItem> Copia = List.empty(growable: true);
  SaveRequest request;
  SaveRequestCab requestCab;
  List<Cliente> _testaferros;
  Cliente _selectedTestaferro;
  @override
  void initState() {
    super.initState();
    if (widget.lotesSelected.length > 0) {
      for (var element
          in widget.repesoPedidoSelect) //widget.tipoRepesoSelected.Codigo<2 &&
      {
        /*
          var lote= widget.lotesSelected.where((item) => item.Numero == element.LoteNumero);
          if(lote.isEmpty || element.Pedido != widget.pedidoSelected.NumeroPedido) continue;
          else if(widget.tipoRepesoSelected.Codigo==1 && element.NumeroPR!= widget.repartoSelected.NumeroReparto) continue;
          else if(widget.tipoRepesoSelected.Codigo==2 && element.Tipo<2) continue;
          else //if(lote.first.Codigo== widget.pedidoSelected.Producto)
            {*/
        if (widget.pedidoSelected.numeroPedido == element.Pedido &&
            element.LoteNumero == widget.lotesSelected[0].numero) {
          items.add(new RepesoItem(
              element.Pedido,
              element.NumeroReparto,
              element.Item,
              element.LoteNumero,
              element.NumeroPR,
              element.ItemPR,
              element.Kilos,
              element.Jabas,
              element.Unidades,
              element.Tipo,
              element.Ttra));
          Copia.add(new RepesoItem(
              element.Pedido,
              element.NumeroReparto,
              element.Item,
              element.LoteNumero,
              element.NumeroPR,
              element.ItemPR,
              element.Kilos,
              element.Jabas,
              element.Unidades,
              element.Tipo,
              element.Ttra));
        }
        /* }*/
      }
    }
    _numeroItems = items.length;
    int NumeroReparto;
    int itemReparro;
    if (widget.tipoRepesoSelected.codigo == 1) {
      NumeroReparto = widget.repartoSelected.NumeroReparto;
    }

    TipoRepeso tipoRepeso;
    if (widget.tipoRepesoSelected.codigo == 10) {
      if (widget._tipoRepesoSelected10.codigo == 0)
        tipoRepeso = widget._tipoRepesoSelected10;
      else if (widget._tipoRepesoSelected10.codigo == 1)
        tipoRepeso = widget._tipoRepesoSelected10;
    } else {
      tipoRepeso = widget.tipoRepesoSelected;
    }

    requestCab = SaveRequestCab(
        widget.puntoVenta,
        widget.tipoRepesoSelected.codigo != 3
            ? widget.clienteSelected.codigo
            : 0,
        -1, //loteselect
        widget.pedidoSelected.numeroPedido,
        widget.pedidoSelected.item,
        tipoRepeso.codigo,
        NumeroReparto,
        itemReparro);
    _testaferros = widget._clienteTestaferros;
    _selectedTestaferro = _testaferros.firstWhere(
        (tes) => tes.codigo == widget.clienteSelected.codigo,
        orElse: null);
    // pedidoBloc.getTestaferros(widget.puntoVenta.toString(), widget.clienteSelected.Codigo.toString()).then((resp) {
    //   _testaferros = resp;
    //   _selectedTestaferro = _testaferros.firstWhere((tes) => tes.Codigo==widget.clienteSelected.Codigo,orElse: null);
    // });
  }

  List<int> _colorIndex = [];
  Color getColorPaleta(int index) {
    int index_color = _colorIndex.indexWhere((element) => index == element);
    if (index_color == -1) _colorIndex.add(index);
    return loginBloc
        .colors[_colorIndex.indexWhere((element) => index == element)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Pesaje"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.save,
              size: 32.0,
            ),
            onPressed: () => saveDataPesajes(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
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
                      /*if(widget.lotesSelected.length==1)
                        Text(
                          "Lote: ${widget.lotesSelected[0].Numero.toString()} - ${widget.lotesSelected[0].Placa.trim()}",
                        ),*/
                      Text(
                          "Pedido: ${widget.pedidoSelected.numeroPedido.toString()}"),
                      Text(
                          "Tipo de Repeso: ${widget.tipoRepesoSelected.nombre.trim()}"),
                      Text(
                        "Producto: ${widget.lotesSelected[0].codigo.trim()} - ${widget.lotesSelected[0].descripcion.trim()}",
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 5, 8, 0),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 10.0,
                      height: 0,
                    ),
                    InputCustom("Jabas", "#Jabas", _jabasController, false),
                    SizedBox(width: 10.0),
                    InputCustom(
                        "Unidades", "#Unidades", _unidadesController, false),
                    SizedBox(width: 10.0),
                    InputCustom("Kilos", "#Kilos", _PesoControles, true),
                    SizedBox(width: 10.0),
                    Flexible(
                      child: MaterialButton(
                        color: Colors.blue,
                        textColor: Colors.white,
                        child: Text(
                          "Editar",
                          style: TextStyle(fontSize: 18.0),
                        ),
                        padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                        onPressed: () {
                          updateItemPesaje();
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: -5,
                child: Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        "Lote ",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        "#P       ",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        "#           ",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text("Jabas  ",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      Text("     Und      ",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      Text("      Kg",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      Text("${_numeroItems} Pesajes",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              Container(
                height: items.length * 45.0,
                child: ListView.builder(
                  itemCount: items.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        if (items[index].Ttra == null) {
                          _jabasController.text = items[index].Jabas.toString();
                          _unidadesController.text =
                              items[index].Unidades.toString();
                          _PesoControles.text = items[index].Kilos.toString();
                          setState(() {
                            indexEdit = index;
                          });
                        } else
                          Fluttertoast.showToast(
                            msg:
                                "Peso ya fue procesado en venta, no es posible su edición!",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.amber,
                            textColor: Colors.black,
                            fontSize: 20.0,
                          );
                      },
                      child: Container(
                        //color: indexEdit!=index?Colors.white:Colors.blue,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: indexEdit != index
                                  ? Colors.white12
                                  : Colors.blue,
                              width: 2),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Text(
                                    items[index].LoteNumero.toString(),
                                    style: TextStyle(
                                      height: 2.5,
                                      color: color(index),
                                    ),
                                  ),
                                  //Text(items[index].Fila.toString()),
                                  Text(
                                    items[index]
                                        .NumeroReparto
                                        .toString()
                                        .padLeft(4, "  "),
                                    style: TextStyle(
                                        height: 2,
                                        color: getColorPaleta(
                                            items[index].NumeroReparto),
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    items[index]
                                        .Item
                                        .toString()
                                        .padLeft(4, "  "),
                                    style: TextStyle(height: 2),
                                  ),
                                  Text(
                                    items[index]
                                        .Jabas
                                        .toString()
                                        .padLeft(8, "  "),
                                    style: TextStyle(height: 2),
                                  ),
                                  Text(
                                      items[index]
                                          .Unidades
                                          .toString()
                                          .padLeft(8, "  "),
                                      style: TextStyle(height: 2)),
                                  Text(
                                      items[index]
                                          .Kilos
                                          .toString()
                                          .padLeft(10, "  "),
                                      style: TextStyle(
                                          height: 2)), //.padLeft(4, "  ")
                                  GestureDetector(
                                    onTap: () {
                                      if (indexEdit < 0 &&
                                          items[index].Ttra == null)
                                        setState(() {
                                          items.removeAt(index);
                                        });
                                    },
                                    child: Container(
                                      height: 30.0,
                                      padding:
                                          EdgeInsets.fromLTRB(20, 0, 10, 0),
                                      decoration: new BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.delete,
                                              color: items[index].Ttra == null
                                                  ? Colors.blue
                                                  : Colors.transparent,
                                              size: 30.0,
                                            ),
                                            Text(
                                              items[index].Tipo == 2
                                                  ? "V"
                                                  : items[index].Tipo == 4
                                                      ? "M"
                                                      : "",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  /*IconButton(
                                  icon: Icon(
                                      Icons.delete,
                                      color:indexEdit<0?Colors.blue:Colors.grey
                                  ),
                                  iconSize: 30.0,
                                  onPressed: () {
                                    if(indexEdit<0)
                                      setState(() {
                                        items.removeAt(index);
                                      });
                                  },
                                ),
                                Text(items[index].Tipo==2? "V":"M",style: TextStyle(height: 2)),*/
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void updateItemPesaje() {
    if (indexEdit >= 0) {
      var item = items[indexEdit];
      item.Jabas = int.parse(_jabasController.text);
      item.Unidades = int.parse(_unidadesController.text);
      item.Kilos = double.parse(_PesoControles.text);

      _jabasController.text = "";
      _unidadesController.text = "";
      _PesoControles.text = "";
      indexEdit = -1;
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    }
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
    return false;
    // return (widget.tipoRepesoSelected.Codigo == 0 || widget.tipoRepesoSelected.Codigo == 1)&&items.length>0;
  }

  Color color(index) {
    int num = widget.response.loginData.lotes
        .indexWhere((element) => element.numero == items[index].LoteNumero);
    if (num == -1)
      return Colors.black;
    else
      return loginBloc.colors[num];
  }

  void saveDataPesajes() {
    List<PesajeDetalleItem> saveRequest = List.empty(growable: true);
    List<ReintegroLote> requestLote = List.empty(growable: true);
    List<int> sublotes = List.empty(growable: true);
    for (RepesoItem original in Copia) {
      int index = items.indexWhere((element) =>
          element.NumeroReparto == original.NumeroReparto &&
          element.Item == original.Item);
      if (index < 0) { // Si el original ya no esta en la nueva lista
        PesajeDetalleItem item = new PesajeDetalleItem(
            original.NumeroReparto, original.Item, original.Jabas, original.Unidades, original.Kilos);
        item.Estado = true; // sera eliminado
        saveRequest.add(item);
        requestLote.add(new ReintegroLote(original.LoteNumero, -original.Unidades));
      } else if (original.Jabas != items[index].Jabas ||
          original.Unidades != items[index].Unidades ||
          original.Kilos != items[index].Kilos) { // Si sufrio algun cambio en sus items
        saveRequest.add(new PesajeDetalleItem(original.NumeroReparto, original.Item,
            items[index].Jabas, items[index].Unidades, items[index].Kilos));
        requestLote.add(new ReintegroLote(
            original.LoteNumero, items[index].Unidades - original.Unidades));
        if (items[index].Unidades - original.Unidades > 0)
          sublotes.add(items[index].ItemPR);
      }
    }
    if (saveRequest.length == 0) {
      Fluttertoast.showToast(
        msg: "No se detectaron cambios",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.amber,
        textColor: Colors.black,
        fontSize: 20.0,
      );
      return;
    }

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
          content: Container(
              height: 150,
              child: Column(
                children: [
                  if (soloVenta()) Text("Selecione cliente"),
                  if (soloVenta())
                    Container(height: 60, child: ddTestaferros(setState)),
                  Text("¿Esta seguro de grabar todos los pesajes?")
                ],
              )),
          actions: <Widget>[
            TextButton(
              child: Text(
                "ACEPTAR",
              ),
              onPressed: () async {
                await loginBloc.conexion(true).then((response) {
                  if (response) {
                    List<int> lotes = List.empty(growable: true);
                    for (var item in requestLote) {
                      if (item.Unidades > 0 && !lotes.contains(item.Numero))
                        lotes.add(item.Numero);
                    }
                    requestCab.LotesNumero = lotes.toSet().toList().join(',');
                    requestCab.ItemsPR = sublotes.join(',');
                    if (soloVenta() && request != null)
                      request.oCabecera.ClienteTestaferro =
                          _selectedTestaferro.codigo;
                    request = SaveRequest(requestCab, saveRequest);
                    pedidoBloc.updateDataPesajes(request).then((response) {
                      if (response.nCodError == 0) {
                        Fluttertoast.showToast(
                          msg: "Se actualizo con éxito",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 20.0,
                        );
                        for (var item in saveRequest) {
                          if (item.Estado)
                            widget.repesoPedidoSelect.removeWhere((element) =>
                                element.NumeroReparto == item.Numero &&
                                element.Item == item.Item);
                          else {
                            var repart = widget.repesoPedidoSelect.firstWhere(
                                (element) =>
                                    element.NumeroReparto == item.Numero);
                            repart.Jabas = item.Jabas;
                            repart.Unidades = item.Unidades;
                            repart.Kilos = item.Kilos;
                          }
                        }
                        Navigator.of(context).pop();
                        Navigator.pop(context, requestLote);
                      } else {
                        Fluttertoast.showToast(
                          msg: response.cMsjError,
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 20.0,
                        );
                        Navigator.of(context).pop();
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
/*
     setState(() {
       widget.repesoPedidoSelect = [];
     });*/
  }
}
