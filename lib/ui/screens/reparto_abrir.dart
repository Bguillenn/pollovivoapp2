import 'package:flutter/material.dart';
import 'package:pollovivoapp/bloc/reparto_bloc.dart';
import 'package:pollovivoapp/model/reparto_buscar.dart';
import 'package:pollovivoapp/model/reparto_header.dart';
import 'package:pollovivoapp/util/utils.dart';

class RepartoAbrir extends StatefulWidget {
  RepartoAbrir({Key key,this.PuntoVenta,this.Vehiculo,this.Desde,this.Hasta,this.Reload}) : super(key: key);
  int PuntoVenta;
  int Vehiculo;
  DateTime Desde;
  DateTime Hasta;
  Function Reload;
  @override
  State<RepartoAbrir> createState() => _RepartoAbrirState();
}

class _RepartoAbrirState extends State<RepartoAbrir> {
  List<RepartoCabecera> listaRepartos;
  List<DataRow> viewData = [];
  @override
  void initState() {
    super.initState();
    cargarData();
  }



  Widget Estado(bool estado){
    if(estado) return Text('Cerrado');
    else return Text(
          'Abierto',
          style: TextStyle(color: Color.fromARGB(255, 0, 150, 0))
      );  
  }

  DataRow DatoToView(RepartoCabecera obj){
    return DataRow(
      cells: <DataCell>[
        DataCell(Text('${obj.NumeroReparto}')),
        DataCell(Text(FormatDate(obj.FechaRegistro))),
        DataCell(MaterialButton(
          child: Estado(obj.Cerrado),
          onPressed: (){
            obj.Cerrado = !obj.Cerrado;
            repartoBloc
                .actualizarEstadoReparto(obj.PuntoVenta,obj.NumeroReparto,obj.Cerrado)
                .then((response) {
                  widget.Reload();
            });
          },
        )),
      ],
    );
  }

  void cargarData(){
    RepartoBuscar resquet = RepartoBuscar(widget.PuntoVenta,widget.Vehiculo,widget.Desde,widget.Hasta);
    repartoBloc.listarReparto(resquet).then((response) => {
      setState(() {
        viewData = response.Repartos.map((e) => DatoToView(e)).toList();
      })
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
            'Fecha',
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

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: CargarLabelTable(),
      rows: viewData
    );
  }
}
