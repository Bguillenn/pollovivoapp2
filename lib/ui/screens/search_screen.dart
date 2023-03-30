import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollovivoapp/bloc/login_bloc.dart';
import 'package:pollovivoapp/bloc/pedido_bloc.dart';
import 'package:pollovivoapp/model/cliente.dart';
import 'package:pollovivoapp/model/login_response.dart';
import 'package:pollovivoapp/model/lote.dart';
import 'package:pollovivoapp/model/pedido_item.dart';
import 'package:pollovivoapp/model/pedido_request.dart';
import 'package:pollovivoapp/model/repeso_item.dart';
import 'package:pollovivoapp/model/tipo_repeso.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class SearchScreen extends StatefulWidget {
  LoginResponse response;
  SearchScreen(this.response);
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Cliente _clienteSelected;
  TipoRepeso _tipoRepesoSelected;
  List<Cliente> _clientes;
  List<TipoRepeso> _tiposRepeso;
  List<PedidoItem> PedidosCab;
  int _numeroItems;
  bool loading;
  @override
  void initState() {
    super.initState();
    _numeroItems = 0;
    loading = false;
    _clientes = widget.response.loginData.clientes;
    _tiposRepeso = widget.response.loginData.tiposRepeso
        .where((element) => element.codigo < 3)
        .toList();
    PedidosCab = List();
  }

  getData() async {
    loading = true;
    PedidosCab.clear();
    PedidoRequest req = PedidoRequest(
        widget.response.loginData.dataUsuario.puntoVentaCodigo,
        _clienteSelected.codigo,
        _tipoRepesoSelected.codigo);

    await pedidoBloc.fetchDataPedido(req).then((response) {
      if (response.nCodError == 0) {
        //_numeroItems = response.pedidoData.repesoDetalle.length;
        //  repesoDet = response.pedidoData.repesoDetalle;
        //PedidosCab = response.pedidoData.pedidoDetalles;
        for (var item in response.pedidoData.pedidoDetalles) {
          if (item.cantidadRP > 0) {
            try {
              item.nombre = widget.response.loginData.lotes
                  .firstWhere((element) => element.codigo == item.producto)
                  .descripcion;

              item.repesos = response.pedidoData.repesoDetalle
                  .where((element) => element.Pedido == item.numeroPedido)
                  .toList();
              PedidosCab.add(item);
            } catch (e) {}
          }
        }
        loading = false;
      } else {
        Fluttertoast.showToast(
            msg: response.cMensaje,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 20.0);
      }
      setState(() {
        loading = false;
      });
    });
  }

  Widget DetalleTree() {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: PedidosCab.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              constraints: BoxConstraints(
                maxHeight: double.infinity,
              ),
              child: ExpansionTile(
                initiallyExpanded: true,
                title: Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(PedidosCab[index].nombre,
                              style: TextStyle(
                                fontSize: 14,
                              )),
                        ],
                      ),
                      Row(
                        children: [
                          Text("PEDIDO ${PedidosCab[index].numeroPedido}",
                              style: TextStyle(
                                fontSize: 12,
                              )),
                          Expanded(
                              child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                                "${PedidosCab[index].repesos.length} Pesajes",
                                style: TextStyle(
                                  fontSize: 12,
                                )),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: double.infinity,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          "#",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          "Lote      ",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text("Jabas  ",
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        Text("     Und      ",
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        Text("      Kg",
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        //Text(,style: TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  Container(
                    height: (PedidosCab[index].repesos.length) * 28.0,
                    /*constraints: BoxConstraints(
                      maxHeight: double.infinity,
                    ),*/
                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: PedidosCab[index].repesos.length,
                        itemBuilder: (BuildContext context, int item) {
                          return Container(
                            color:
                                item % 2 == 0 ? Colors.black12 : Colors.white,
                            height: 28,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text((item + 1).toString()),
                                Text(PedidosCab[index]
                                    .repesos[item]
                                    .LoteNumero
                                    .toString()
                                    .padLeft(0, "  ")),
                                Text(PedidosCab[index]
                                    .repesos[item]
                                    .Jabas
                                    .toString()
                                    .padLeft(6, "  ")),
                                Text(PedidosCab[index]
                                    .repesos[item]
                                    .Unidades
                                    .toString()
                                    .padLeft(8, "  ")),
                                Text(PedidosCab[index]
                                    .repesos[item]
                                    .Kilos
                                    .toString()
                                    .padLeft(10, "  ")),
                                //Text(,style: TextStyle(fontWeight: FontWeight.w700)),
                              ],
                            ),
                          );
                        }),
                  )
                ],
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Consultas"),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                  child: Column(
                    children: [
                      SearchableDropdown<Cliente>(
                        items: _clientes
                            .map(
                              (data) => DropdownMenuItem<Cliente>(
                                child: Text(data.nombre),
                                value: data,
                              ),
                            )
                            .toList(),
                        onChanged: (Cliente value) {
                          setState(() {
                            _clienteSelected = value;
                            _tipoRepesoSelected = _tiposRepeso[0];
                            getData();
                          });
                        },
                        value: _clienteSelected,
                        hint: 'Seleccione Cliente',
                        searchHint: 'Busque cliente',
                        iconSize: 30.0,
                        isExpanded: true,
                        isCaseSensitiveSearch: false,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: DropdownButton<TipoRepeso>(
                          value: _tipoRepesoSelected,
                          items: _tiposRepeso
                              .map(
                                (data) => DropdownMenuItem<TipoRepeso>(
                                  child: Text(data.nombre),
                                  value: data,
                                ),
                              )
                              .toList(),
                          onChanged: (TipoRepeso value) {
                            if (_tipoRepesoSelected != value)
                              setState(() {
                                _tipoRepesoSelected = value;
                                getData();
                              });
                          },
                          iconSize: 30.0,
                          isExpanded: true,
                        ),
                      ),
                      if (PedidosCab.length > 0)
                        Container(
                            //padding:  EdgeInsets.fromLTRB(0, 10, 0, 0),
                            constraints: BoxConstraints(
                              maxHeight: double.infinity,
                            ),
                            child: DetalleTree()),
                    ],
                  )),
            ),
            if (loading)
              Center(
                child: CircularProgressIndicator(),
              )
          ],
        ));
  }
}
