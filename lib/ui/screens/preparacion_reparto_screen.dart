import 'dart:convert';

import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollovivoapp/bloc/login_bloc.dart';
import 'package:pollovivoapp/bloc/reparto_bloc.dart';
import 'dart:math';
import 'package:pollovivoapp/model/login_response.dart';
import 'package:pollovivoapp/model/lote.dart';
import 'package:pollovivoapp/model/lote_cab.dart';
import 'package:pollovivoapp/model/reparto_header.dart';
import 'package:pollovivoapp/model/reparto_item.dart';
import 'package:pollovivoapp/model/reparto_save_request.dart';
import 'package:pollovivoapp/model/unidad_reparto.dart';
import 'package:pollovivoapp/ui/widgets/gridview_custom.dart';
import 'package:pollovivoapp/ui/widgets/input_custom.dart';
import 'package:pollovivoapp/ui/widgets/selectable_item.dart';
import 'package:pollovivoapp/ui/widgets/selectable_oneitem.dart';
import 'package:pollovivoapp/ui/widgets/selection_app_bar.dart';

class PreparacionRepartoScreen extends StatefulWidget {
  LoginResponse response;
  UnidadReparto VehiculoSelect;
  RepartoCabecera RepartoSelect;
  int codigoPuntoVenta;
  String rowPersonal, rowPuntoVenta;
  bool selectAnt, selectAct;
  int indexRetro = -1;
  PreparacionRepartoScreen(
      this.response, this.VehiculoSelect, this.RepartoSelect) {
    this.codigoPuntoVenta = response.loginData.dataUsuario.puntoVentaCodigo;
  }

  @override
  _InicioScreenState createState() => _InicioScreenState();
}

class _InicioScreenState extends State<PreparacionRepartoScreen> {
  int _numeroItems;
  final _jabasController = TextEditingController();
  final _unidadesController = TextEditingController();
  final controller = DragSelectGridViewController();
  Future<String> _strData;
  RepartoSaveRequest request;
  List<int> SelectedAnt = new List();
  List<LotePrincipal> loteCabList = new List();
  LotePrincipal LoteCabSelect;
  List<Lote> loteList = new List();
  Lote LoteSelect;
  List<RepartoItem> items = List();
  bool EditReparto = true;

  @override
  void initState() {
    items = widget.RepartoSelect.items;
    EditReparto =
        items.indexWhere((element) => element.disponible < element.unidades) >=
            0;
    super.initState();
    controller.addListener(scheduleRebuild);
    //requestCab= new RepartoCabecera(codigoPuntoVenta,);
    _numeroItems = items.length;
    int numant = 0, i = 0;
    //pintar ranfla
    for (Lote item in widget.response.loginData.lotes) {
      if (item.disponible <= 0 &&
          items.indexWhere((element) => element.loteNumero == item.numero) < 0)
        continue;
      if (numant != item.lotePrincipal) {
        LotePrincipal temp = LotePrincipal(item.lotePrincipal, item.placa);
        temp.index = i;
        loteCabList.add(temp);
      }
      numant = item.lotePrincipal;
      i++;
    }
    if (loteCabList.length > 0) {
      LoteCabSelect = loteCabList[0];
      loadLote();
    }
  }

  void loadLote() {
    loteList.clear();
    int i = 0;
    for (Lote item in widget.response.loginData.lotes) {
      /*if(item.LotePrincipal==LoteCabSelect.Numero)
          {*/
      item.colorLote = loginBloc.colors[i];
      loteList.add(item);
      /*  }*/
      i++;
    }
    for (var item in loteList) {
      if (item.disponible > 0) {
        LoteSelect = item;
        break;
      }
    }
  }

  void scheduleRebuild() => setState(() {
        if (LoteSelect == null) return;
        int jabas = controller.value.selectedIndexes.length *
            widget.VehiculoSelect.altura;
        _jabasController.text = jabas.toString();
        _unidadesController.text =
            (jabas * LoteSelect.cantidadPollosPorLote()).toString();
      });

  Widget listViewItem({int index, double itemsize, Lote item}) {
    double radio = 0, borders = 0;
    Color relleno = item.colorLote;
    if (LoteSelect != null && LoteSelect.numero == item.numero) {
      radio = 8;
      borders = 2;
      relleno = relleno.withOpacity(0.8);
    }
    return GestureDetector(
        onTap: () {
          if (LoteSelect != null && LoteSelect.numero != item.numero) {
            if (item.disponible > 0)
              setState(() {
                LoteSelect = item;
              });
            else
              Fluttertoast.showToast(
                msg:
                    "Lote sin unidades, consulte con el administrador en caso exista exceso.",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.amber,
                textColor: Colors.black,
                fontSize: 20.0,
              );
          } else if (LoteSelect.numero != item.numero)
            Fluttertoast.showToast(
              msg: "Lote sin unidades",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.amber,
              textColor: Colors.black,
              fontSize: 20.0,
            );
        },
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
                child: Text(
              item.codigo +
                  "\n" +
                  item.descripcion.replaceAll("POLLO VIVO", "PV") +
                  " " +
                  item.disponible.toString() +
                  " UND\n" +
                  item.numero.toString(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            )) // just for the demo, you can pass optionsChoices()
            ));
  }

  bool Unselected(bool selected, int i) {
    if (SelectedAnt.isEmpty) return selected;
    if (controller.value.selectedIndexes.length <= 1) return selected;
    if (SelectedAnt.contains(i) && controller.value.selectedIndexes.contains(i))
      return selected;
    else {
      if (selected) {
        return filaAntllena(i);
      } else {
        List<int> remov = List.of(SelectedAnt);
        remov.removeWhere(
            (element) => controller.value.selectedIndexes.contains(element));

        if (remov.isNotEmpty && remov.first == i) {
          int filaSelect = -1, filaIndex = -1;
          filaSelect = (controller.value.selectedIndexes.reduce(max) ~/
              widget.VehiculoSelect.columna);
          filaIndex = (i ~/ widget.VehiculoSelect.columna);
          return filaIndex < filaSelect;
        } else
          return selected;
      }
    }
  }

  bool filaAntllena(int index) {
    int contador = 0;
    int filamin = controller.value.selectedIndexes.reduce(min) ~/
        widget.VehiculoSelect.columna;
    if (controller.value.selectedIndexes.length > 3 &&
        (index == controller.value.selectedIndexes.reduce(max) ||
            index == controller.value.selectedIndexes.reduce(min))) {
      for (int item in controller.value.selectedIndexes)
        if (item ~/ widget.VehiculoSelect.columna ==
                (index ~/ widget.VehiculoSelect.columna) - 1 ||
            item ~/ widget.VehiculoSelect.columna ==
                (index ~/ widget.VehiculoSelect.columna) + 1) contador++;
      return (contador == widget.VehiculoSelect.columna ||
          filamin ==
              (index ~/ widget.VehiculoSelect.columna) -
                  1); // verificar si la ultima fila, en esecaso se acepta todo
    } else
      return true;
  }

  void addItemSubLote() async {
    if (LoteSelect == null) return;
    if (_jabasController.text == "0" || _unidadesController.text == "0") {
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
    int total = widget.VehiculoSelect.fila * widget.VehiculoSelect.columna;
    int totalSec =
        items.fold(0, (sum, item) => sum + item.rumas.split(',').length);
    if (total == totalSec) {
      Fluttertoast.showToast(
        msg: "Sin rumas disponibles para seleccionar",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.amber,
        textColor: Colors.black,
        fontSize: 20.0,
      );
      return;
    }
    int _javas = int.parse(_jabasController.text);
    int _unidades = int.parse(_unidadesController.text);
    if (_javas * 5 > _unidades || _javas * 11 < _unidades) {
      Fluttertoast.showToast(
        msg: "Rango Invalido de javas!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.amber,
        textColor: Colors.black,
        fontSize: 20.0,
      );
      return;
    }
    if (controller.value.selectedIndexes.length == 0) {
      Fluttertoast.showToast(
        msg: "Seleccione las rumas a agregar!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.amber,
        textColor: Colors.black,
        fontSize: 20.0,
      );
      return;
    }
    //int LoteDisp= LoteSelect.Disponible-items.where((element) => element.LoteNumero==LoteSelect.Numero).fold(0, (sum, item) => sum + item.Unidades);
    //int LoteDisp = LoteSelect.Disponible - _unidades;
    LoteSelect.disponible = LoteSelect.disponible - _unidades;
    if (LoteSelect.disponible + widget.response.loginData.dataUsuario.holgura <
        0) {
      // agregamos la cantidad de holgura para el lote de un Trailler
      LoteSelect.disponible = LoteSelect.disponible + _unidades;
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
    var tempitem = new RepartoItem(
        widget.RepartoSelect.NumeroReparto,
        _numeroItems + 1,
        LoteSelect.numero,
        controller.value.selectedIndexes.join(','),
        int.parse(_jabasController.text),
        int.parse(_unidadesController.text));
    tempitem.nuevo = true;
    items.add(tempitem);
    _numeroItems = items.length;
    _jabasController.clear();
    _unidadesController.clear();
    controller.value = Selection({});
  }

  void deleteItemSubLote(int index) {
    /*if(items.last.Item != items[index].Item) {
      //Fluttertoast.showToast( msg: "Elimine ordenadamente los Sub-Lotes!");
      return;
    }*/

    widget.response.loginData.lotes
        .firstWhere((element) => element.numero == items[index].loteNumero)
        .disponible += items[index].unidades;
    items.removeAt(index);
    loadLote();
/*    request = SaveRequest(requestCab, items);
    saveLocal.save(Shared_name, request.toJson());*/
    _numeroItems = items.length;
  }

  @override
  Widget build(BuildContext context) {
    var buttonListWidth = MediaQuery.of(context).size.width - 100;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<int> Select = controller.value.selectedIndexes.toList();
      for (var item in items)
        for (int index in item.rumas.split(',').map(int.parse).toList())
          if (Select.contains(index)) Select.remove(index);

      if (widget.indexRetro >= 0) {
        if (Select.contains(widget.indexRetro))
          Select.remove(widget.indexRetro);
        else
          Select.add(widget.indexRetro);
        widget.indexRetro = -1;
      }
      Select.sort();
      controller.value = Selection(List.of(Select).toSet());
      SelectedAnt = List.of(Select);
    });
    return Scaffold(
      appBar: SelectionAppBar(
          selection: controller.value,
          title: Text((widget.RepartoSelect.NumeroReparto < 0
                  ? "Nuevo"
                  : EditReparto
                      ? "Cerrar"
                      : "Editar") +
              " Reparto"),
          actions: <Widget>[
            if (widget.RepartoSelect.NumeroReparto > 0 && !EditReparto)
              Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: GestureDetector(
                  child: IconButton(
                    icon: Icon(
                      Icons.delete,
                      size: 32.0,
                    ),
                    onPressed: () => deleteDataReparto(),
                  ),
                ),
              ),
            if (EditReparto)
              Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: GestureDetector(
                  child: IconButton(
                    icon: Icon(
                      Icons.low_priority,
                      size: 32.0,
                    ),
                    onPressed: () => closeReparto(),
                  ),
                ),
              ),
            if (!EditReparto)
              Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: GestureDetector(
                  child: IconButton(
                    icon: Icon(
                      Icons.save,
                      size: 32.0,
                    ),
                    onPressed: () => saveDataReparto(),
                  ),
                ),
              ),
          ]),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          child: Column(
            children: <Widget>[
              if (LoteCabSelect != null)
                Container(
                    height: 100,
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                            onTap: () {
                              setState(() {
                                int index = loteCabList.indexWhere((element) =>
                                        element.index == LoteCabSelect.index) +
                                    1;
                                if (index >= loteCabList.length) index = 0;
                                LoteCabSelect = loteCabList[index];
                                loadLote();
                              });
                            },
                            child: Container(
                                width: 50.0,
                                color: Colors.black87,
                                child: RotatedBox(
                                  quarterTurns: 3,
                                  child: Center(
                                      child: Text(LoteCabSelect.Placa,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20))),
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
                    )),
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
                          'REPARTO ' + widget.VehiculoSelect.placa,
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                          ),
                        )),
                      ),
                    ],
                  )),
              Container(
                  padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                  height: widget.VehiculoSelect.fila * 47.5, //51.3,
                  color: Colors.white30,
                  child: DragSelectGridView(
                    gridController: controller,
                    padding: const EdgeInsets.all(8),
                    itemCount: widget.VehiculoSelect.fila *
                        widget.VehiculoSelect.columna,
                    itemBuilder: (context, index, selected) {
                      if (selected != Unselected(selected, index)) {
                        widget.indexRetro = index;
                        selected = Unselected(selected, index);
                      }
                      Color colorSublote = null;
                      for (var item in items) {
                        if (item.rumas.split(',')
                            .map(int.parse)
                            .toList()
                            .contains(index)) {
                          int indexColor = widget.response.loginData.lotes
                              .indexWhere((element) =>
                                  element.numero == item.loteNumero);
                          if (indexColor == -1) {
                            colorSublote = Colors.grey[800];
                          } else {
                            colorSublote = loginBloc.colors[indexColor];
                          }

                          selected = false;
                        }
                      }
                      return SelectableItem(
                        index: index,
                        color: colorSublote == null
                            ? Colors.black45
                            : colorSublote,
                        colorSel: LoteSelect != null
                            ? LoteSelect.colorLote
                            : Colors.black45,
                        selected: selected,
                      );
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      //  maxCrossAxisExtent: 100,
                      childAspectRatio: (2 / 1),
                      crossAxisCount: widget.VehiculoSelect.columna,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                  )),
              if (!EditReparto)
                Container(
                  padding: EdgeInsets.fromLTRB(20, 5, 10, 0),
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
                            addItemSubLote();
                            setState(() {});
                          },
                          onLongPress: () {
                            saveDataReparto();
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
                        "    Lote  ",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      //Text("Fila"),
                      Text("Jabas",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      Text("Und",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      if (EditReparto)
                        Text("Disponible",
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      if (!EditReparto)
                        Text("${_numeroItems} SubLotes",
                            style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              Container(
                height: items.length * 48.0,
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          items[index].loteNumero.toString(),
                          style: TextStyle(
                            height: 2.5,
                            color: () {
                              int colorIndex = widget.response.loginData.lotes
                                  .indexWhere((element) =>
                                      element.numero ==
                                      items[index].loteNumero);
                              if (colorIndex == -1)
                                return Colors.grey[800];
                              else
                                return loginBloc.colors[colorIndex];
                            }(),
                            //color: loginBloc.colors[],
                          ),
                        ),
                        //Text(items[index].Fila.toString()),
                        Text(
                          items[index].jabas.toString(),
                          style: TextStyle(height: 2.5),
                        ),
                        Text(items[index].unidades.toString(),
                            style: TextStyle(height: 2.5)),
                        if (EditReparto)
                          Text(
                              items[index]
                                  .disponible
                                  .toString()
                                  .padLeft(4, "  "),
                              style: TextStyle(height: 2.5)),
                        if (!EditReparto)
                          IconButton(
                            icon: Icon(Icons.delete,
                                color: //colors[widget.response.loginData.lotes.indexWhere((element) => element.Numero==items[index].LoteNumero)]
                                    Colors.blue
                                //index==items.length-1?Colors.blue:Colors.transparent,
                                ),
                            iconSize: 30.0,
                            onPressed: () {
                              setState(() {
                                deleteItemSubLote(index);
                              });
                            },
                          ),
                      ],
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

  List<RepartoItem> marcarSeleccionado(
      List<RepartoItem> listReparto, List<Lote> lotesSelecionados) {
    List<RepartoItem> innerResult = new List<RepartoItem>();
    listReparto.forEach((lp) {
      int index =
          lotesSelecionados.indexWhere((ls) => lp.loteNumero == ls.numero);
      bool temp = index != -1;
      RepartoItem clon = lp.clone();
      clon.nuevo = temp;
      innerResult.add(clon);
    });
    return innerResult;
  }

  void saveDataReparto() async {
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
            "Grabar Reparto",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 18.0,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text("¿Esta seguro de grabar el Reparto?"),
          actions: <Widget>[
            TextButton(
              child: Text(
                "ACEPTAR",
              ),
              onPressed: () async {
                //request = RepartoSaveRequest(widget.RepartoSelect,marcarSeleccionado(items,loteList));
                request = RepartoSaveRequest(widget.RepartoSelect, items);
                /*request.oCabecera.NumeroReparto=response.NumeroReparto;
                 for(var item in request.oDetalle) item.NumeroReparto=response.NumeroReparto;*/
                await loginBloc.conexion(true).then((response) {
                  if (response) {
                    repartoBloc.saveDataReparto(request).then((response) {
                      if (response.nCodError == 0) {
                        Fluttertoast.showToast(
                          msg: "Se grabó con éxito",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 20.0,
                        );
                        Navigator.of(context).pop();
                        Navigator.pop(context, response.NumeroReparto);
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

  void closeReparto() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(
            "Cerrar Reparto",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 18.0,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text("¿Esta seguro de cerrar el Reparto?"),
          actions: <Widget>[
            TextButton(
              child: Text(
                "ACEPTAR",
              ),
              onPressed: () async {
                await repartoBloc
                    .closeReparto(widget.codigoPuntoVenta,
                        widget.RepartoSelect.NumeroReparto)
                    .then((response) {
                  if (response.nCodError == 0) {
                    Fluttertoast.showToast(
                      msg: "Se grabó con éxito",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 20.0,
                    );
                    Navigator.of(context).pop();
                    Navigator.pop(context, response.NumeroReparto);
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
  }

  void deleteDataReparto() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(
            "Eliminar Reparto",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 18.0,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text("¿Esta seguro de eliminar el reparto?"),
          actions: <Widget>[
            TextButton(
              child: Text(
                "ACEPTAR",
              ),
              onPressed: () async {
                await repartoBloc
                    .deleteDataReparto(widget.codigoPuntoVenta,
                        widget.RepartoSelect.NumeroReparto)
                    .then((response) {
                  if (response.nCodError == 0) {
                    Fluttertoast.showToast(
                      msg: "Se elimino con éxito",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 20.0,
                    );
                    Navigator.of(context).pop();
                    Navigator.pop(context, response.NumeroReparto);
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

  @override
  void dispose() {
    controller.removeListener(scheduleRebuild);
    super.dispose();
  }
}
