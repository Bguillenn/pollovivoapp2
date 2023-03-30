import 'package:flutter/material.dart';
import 'package:pollovivoapp/bloc/pedido_bloc.dart';
import 'package:pollovivoapp/bloc/reparto_bloc.dart';
import 'package:pollovivoapp/model/pedido_buscar.dart';
import 'package:pollovivoapp/model/reparto_buscar.dart';
import 'package:pollovivoapp/model/reparto_header.dart';
import 'package:pollovivoapp/util/utils.dart';
import "package:collection/collection.dart";
class PedidoAbrir extends StatefulWidget {
  PedidoAbrir({Key key,this.PuntoVenta,this.Desde,this.Hasta,this.Reload}) : super(key: key);
  int PuntoVenta;
  int CodigoCliente = 0;
  DateTime Desde;
  DateTime Hasta;
  Function Reload;
  @override
  State<PedidoAbrir> createState() => _PedidoAbrirState();
}

class _PedidoAbrirState extends State<PedidoAbrir> {
  List<EstadoPedido> listaPedidos;
  //List<DataRow> viewData = [];
  var newMapGrupoCliente;
  @override
  void initState() {
    super.initState();
    cargarData();
  }

  int cambioEstado(int estado){
    if(estado == 4) return 0;
    else if(estado == 0) return 4;
    else return 0;
  }

  Widget Estado(int estado){
    if(estado==4) return Text('Cerrado');
    else if(estado ==0 )return Text(
          'Abierto',
          style: TextStyle(color: Color.fromARGB(255, 0, 150, 0))
      );  
  }

  DataRow DatoToView(EstadoPedido obj){
    return DataRow(
      cells: <DataCell>[
        DataCell(Text('${obj.nNumero}')),
        DataCell(Text(FormatDate(obj.dFechaEntrega))),
        DataCell(MaterialButton(
          child: Estado(obj.nEstado),
          onPressed: (){
            actualizarData(obj);
          },
        )),
      ],
    );
  }
  void actualizarData(EstadoPedido obj){
    obj.nEstado = cambioEstado(obj.nEstado);
    pedidoBloc
        .actualizarPedido(obj.nPuntoVenta,obj.nNumero,obj.nEstado)
        .then((resp) => widget.Reload());
  }

  void cargarData(){
    PedidoEstadoBuscar obj = PedidoEstadoBuscar(widget.PuntoVenta,widget.CodigoCliente,widget.Desde,widget.Hasta);
    pedidoBloc.getDataPedidosBucar(obj).then((response) {
      setState(() {
        //viewData = response.Pedidos.map((e) => DatoToView(e)).toList();
        newMapGrupoCliente = groupBy(response.Pedidos, (EstadoPedido obj) => obj.cCliente);
      });
    });
  }

  List<DataColumn> CargarLabelTable(){
    return const <DataColumn>[
      DataColumn(
        label: Expanded(
          child: Text(
            'Numero',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Fecha de\nEntrega',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Abrir/Cerrar',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ),
    ];
  }

  List<Widget> crearTabla(data,strTitle){
    Color titleColor = Colors.grey;
    var table = DataTable(
        //columnSpacing: 10.0,
        //dataRowHeight: 28,
        headingRowColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          return titleColor;  // Use the default value.
        }),
        //headingRowHeight: 28.0,
        columns: CargarLabelTable(),
        rows: data
    );
    var title = Container(
      width : MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(bottom: 1.0, top: 5.0),
      margin: const EdgeInsets.only(top: 20.0,left: 3,right: 3),
      color: titleColor,
      child: Text("      $strTitle",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
    return [title,table];
  }

  List<Widget> CargarLista(){
    List<Widget> list = new List<Widget>();
    if(newMapGrupoCliente != null)
      newMapGrupoCliente.forEach((k, v)  {
        //int indexColor = 0;
        List<DataRow> data = v.map((e) => DatoToView(e)).toList().cast<DataRow>();
        list += [...crearTabla(data,k)];
      });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
            children:CargarLista()
        )
    );
    /*return DataTable(
      columns: CargarLabelTable(),
      rows: viewData
    );*/
  }
}
