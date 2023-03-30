import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollovivoapp/bloc/login_bloc.dart';
import 'package:pollovivoapp/bloc/pedido_bloc.dart';
import 'package:pollovivoapp/model/pedido_cliente.dart';
import "package:collection/collection.dart";

class PedidoTestaferro extends StatefulWidget {
  int puntoVenta;
  int codigoCliente;
  Key key;
  double nTaraJaba;
  PedidoTestaferro(
      this.key,
      this.puntoVenta,
      this.codigoCliente,
      this.nTaraJaba
      ) : super(key:key);

  @override
  State<PedidoTestaferro> createState() => _PedidoTestaferroState();
}

class _PedidoTestaferroState extends State<PedidoTestaferro> {
  List<PedidoCliente> listaPedidos;
  //List<DataRow> viewData = [];
  var newMapGrupoCliente = [];
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

  Widget estado(int estado){
    if(estado==4) return Text('Cerrado');
    else if(estado ==0 )return Text(
        'Abierto',
        style: TextStyle(color: Color.fromARGB(255, 0, 150, 0))
    );
  }

  DataRow datoToView(PedidoCliente obj){
    return DataRow(
      cells: <DataCell>[
        DataCell(
            Text('${obj.nNumero}')
        ),
        DataCell(Text('${obj.nPedido}')),
        // DataCell(Text('${obj.nJabas}')),
        DataCell(Align(
          alignment: Alignment.centerRight,
          child: Text('${obj.nJabas }'),
        ),),
        // DataCell(Text('${obj.nPedidoFacturacion}')),
        DataCell(Align(
          alignment: Alignment.centerRight,
          child: Text('${obj.nZisePedido }'),
        ),),
        // DataCell(Text('${obj.nKilosTotal}')),
        DataCell(Align(
          alignment: Alignment.centerRight,
          child: Text('${obj.nKilosTotal }'),
        ),),
        DataCell(Align(
          alignment: Alignment.centerRight,
          child: Text('${obj.nKilosTotal - (obj.nJabas*widget.nTaraJaba) }',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),),
        DataCell(MaterialButton(
          child: Icon(
            Icons.print,
            size: 32.0,
          ),
          onPressed: () async {
            try{
              int intResp = await pedidoBloc.fetchImprimirPesadas(widget.puntoVenta.toString(),obj.nNumero.toString());
              if(intResp == 1){
                Fluttertoast.showToast(
                  msg: "Se mando a imprimir correctamente.",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.green,
                  textColor: Colors.black,
                  fontSize: 20.0,
                );

              }else{
                Fluttertoast.showToast(
                  msg: "error al imprimir",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 20.0,
                );
              }
            }catch(e){
              Fluttertoast.showToast(
                msg: "error al imprimir",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 20.0,
              );
            }
          },
        )),
      ],
    );
  }
  void actualizarData(PedidoCliente obj){
    // obj.nEstado = cambioEstado(obj.nEstado);
    // pedidoBloc
    //     .actualizarPedido(obj.nPuntoVenta,obj.nNumero,obj.nEstado)
    //     .then((resp) => widget.Reload());
  }

  void cargarData(){
    pedidoBloc.getPedidoTestaferros(widget.puntoVenta.toString(),widget.codigoCliente.toString()).then((response) {
      setState(() {
        //viewData = response.Pedidos.map((e) => DatoToView(e)).toList();
        newMapGrupoCliente = response;
      });
    });
  }

  List<DataColumn> CargarLabelTable(){
    return const <DataColumn>[
      DataColumn(
        label: Expanded(
          child: Text(
            'N°\nPesa',
            style: TextStyle(fontStyle: FontStyle.italic),
            textAlign: TextAlign.right,
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Pedido',
            style: TextStyle(fontStyle: FontStyle.italic),
            textAlign: TextAlign.right,
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Num\nJabas',
            style: TextStyle(fontStyle: FontStyle.italic),
            textAlign: TextAlign.right,
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Num\nPes',
            style: TextStyle(fontStyle: FontStyle.italic),
            textAlign: TextAlign.right,
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Kilos\nNeto',
            style: TextStyle(fontStyle: FontStyle.italic),
            textAlign: TextAlign.right,
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Kilos',
            style: TextStyle(fontStyle: FontStyle.italic),
            textAlign: TextAlign.right,
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            '',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ),
    ];
  }

  List<Widget> crearTabla(data){
    Color titleColor = Colors.grey;
    var table = DataTable(
      columnSpacing: 10.0,
      dataRowHeight: 28,
        headingRowColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          return titleColor;  // Use the default value.
        }),
        //headingRowHeight: 28.0,
        columns: CargarLabelTable(),
        rows: data
    );
    return [table];
  }

  List<Widget> CargarLista(){
    
    if(newMapGrupoCliente != null){
      List<DataRow> data = newMapGrupoCliente.map((e) => datoToView(e)).toList().cast<DataRow>();
      return [...crearTabla(data)];
    }else{
      return [Text("vacio")];
    }

  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
            children:CargarLista()
        )
    );
  }
}
