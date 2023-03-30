import 'package:flutter/material.dart';
import 'package:pollovivoapp/bloc/pedido_bloc.dart';
import 'package:pollovivoapp/model/pedido_item.dart';
import 'package:pollovivoapp/model/pedido_response.dart';
import "package:collection/collection.dart";

class ResumenPedido extends StatefulWidget {
  ResumenPedido({Key key, this.puntoVenta, this.pedido}) : super(key: key);

  int puntoVenta;
  PedidoItem pedido;
  @override
  State<ResumenPedido> createState() => _ResumenPedidoState();
}

class _ResumenPedidoState extends State<ResumenPedido> {
  var informarcion;
  List<DataRow> viewData = [];
  var newMapGrupoTipo;
  List<PedidoItem> pedidos;
  double totalJabas = 0;
  double totalUnidades = 0;
  double totalKilos = 0;
  int totalPedidos = 0;
  double taraJabas = 0;
  double kiloNeto = 0;

  @override
  void initState() {
    CargarData(widget.puntoVenta, widget.pedido.numeroPedido);
  }

  void CargarData(int puntoVenta, int pedido) {
    pedidoBloc.fetchDataPedidoDetalle(puntoVenta, pedido).then((resp) {
      setState(() {
        sumTotales(resp.oPedido);
        pedidos = resp.oPedido.listPedidos;
        newMapGrupoTipo =
            groupBy(resp.oPedido.listDetalle, (DetallePedio obj) => obj.cTipo);
      });
    });
  }

  void sumTotales(var list) {
    list.listPedidos.forEach((lp) {
      totalPedidos += lp.cantidadPollosPorLote;
    });
    list.listDetalle.forEach((ld) {
      totalJabas += ld.nJabas;
      totalKilos += ld.nKilos;
      totalUnidades += ld.nUnidades;
    });
    taraJabas = totalJabas * 6.85;
    kiloNeto = totalKilos - taraJabas;
  }

  Color rowColor(int index) {
    if (index % 2 == 0)
      return Colors.white;
    else
      return Colors.grey[350];
  }

  DataRow DatoToView(DetallePedio obj, int index) {
    return DataRow(
      color: MaterialStateProperty.all(rowColor(index)),
      cells: <DataCell>[
        DataCell(Text('${obj.nLoteNumero}')),
        DataCell(Text('${obj.cProducto}')),
        DataCell(Text('${obj.nJabas}')),
        DataCell(Text('${obj.nUnidades}')),
        DataCell(Text('${obj.nKilos}')),
      ],
    );
  }

  List<DataColumn> CargarLabelTable() {
    return const <DataColumn>[
      DataColumn(
        label: Expanded(
          child: Text('Lote'),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Producto',
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Jabas',
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Unidades',
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Kilos',
          ),
        ),
      ),
    ];
  }

  List<Widget> crearTabla(data, strTitle) {
    Color titleColor = Colors.grey;
    var table = DataTable(
        columnSpacing: 10.0,
        dataRowHeight: 28,
        headingRowColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          return titleColor; // Use the default value.
        }),
        headingRowHeight: 28.0,
        columns: CargarLabelTable(),
        rows: data);
    var title = Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(bottom: 1.0, top: 5.0),
      margin: const EdgeInsets.only(top: 10.0),
      // color: titleColor,
      child: Text(
        "      $strTitle",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
    return [title, table];
  }

  List<Widget> CargarLista() {
    List<Widget> list = new List<Widget>();
    if (newMapGrupoTipo != null)
      newMapGrupoTipo.forEach((k, v) {
        int indexColor = 0;
        List<DataRow> data =
            v.map((e) => DatoToView(e, indexColor++)).toList().cast<DataRow>();
        list += [...crearTabla(data, k)];
      });
    return list;
  }

  List<Widget> listPedidos() {
    List<Widget> list = new List<Widget>();
    if (pedidos != null)
      for (PedidoItem item in pedidos) {
        list.add(Row(
          children: [
            Text("Pedido Unidades ${item.producto}: "),
            Spacer(),
            Text(" ${item.cantidad}")
          ],
        ));
      }
    list.add(Row(
      children: [
        Text("Total Pedidos Unidades  ",
            style: TextStyle(fontWeight: FontWeight.bold)),
        Spacer(),
        Text(" ${totalPedidos}", style: TextStyle(fontWeight: FontWeight.bold))
      ],
    ));

    return list;
  }

  Widget resumenWidget() {
    return Container(
        margin: const EdgeInsets.only(top: 20.0),
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          children: [
            ...listPedidos(),
            Row(
              children: [Text("                 ")],
            ),
            Row(
              children: [
                Text("Total Jabas :",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text(" $totalJabas")
              ],
            ),
            Row(
              children: [
                Text("Total Unidades :",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text(" $totalUnidades")
              ],
            ),
            Row(
              children: [
                Text("Total Kilo Bruto:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text(" $totalKilos")
              ],
            ),
            Row(
              children: [
                Text("Total Tara Jabas:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text(" $taraJabas")
              ],
            ),
            Row(
              children: [
                Text("Total Kilo Neto:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text(" $kiloNeto")
              ],
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [resumenWidget(), ...CargarLista()]));
  }
}
