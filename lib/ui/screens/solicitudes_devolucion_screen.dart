import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollovivoapp/bloc/pedido_bloc.dart';
import 'package:pollovivoapp/model/pesaje_detalle_item.dart';
import 'package:pollovivoapp/model/solicitud_devolucion.dart';
import 'package:pollovivoapp/model/solicitud_response.dart';

class SolicitudesDevolucionScreen extends StatefulWidget {
  final puntoVenta;
  const SolicitudesDevolucionScreen(this.puntoVenta);

  @override
  _SolicitudesDevolucionScreenState createState() => _SolicitudesDevolucionScreenState();
}

class _SolicitudesDevolucionScreenState extends State<SolicitudesDevolucionScreen> {
  final title = 'Solicitudes de devolucion';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppBar(),
      body: renderBody(context)
    );
  }

  Widget renderAppBar(){
    return AppBar(
      title: Text(this.title),
    );
  }

  Widget renderBody(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Solicitudes de devolucion', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              Text('Esta es la lista de las solicitudes de devolucion presiona una para abrir su detalle'),
            ],
          ),
        ),
        Divider(),
        Expanded(child: renderListView(context))
      ],
    );
  }

  Widget renderListView(BuildContext context) {
    return FutureBuilder<SolicitudResponse>(
      future: pedidoBloc.obtenerSolicitudesDevolucion(this.widget.puntoVenta),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return Center(child: CircularProgressIndicator());
        if(snapshot.data.solicitudes.length == 0) return Center(child: Text('No hay solicitudes de devolucion'));
        return ListView.builder(
          itemCount: snapshot.data.solicitudes.length,
          itemBuilder: (_, i) => buildListTile(
                                    context, 
                                    snapshot.data.solicitudes[i],
                                    snapshot.data.repesos.where((repeso) => repeso.Numero == snapshot.data.solicitudes[i].repeso).toList()
                                  )
        );
      }
    );
  }
  
  Widget buildListTile(BuildContext context, SolicitudDevolucion solicitud, List<PesajeDetalleItem> repesos) {
    return ListTile(
      title: Text('Solicitud ${getLetterDoc(solicitud.tipoDoc)}${solicitud.serieDoc}-${solicitud.numeroDoc}'),
      subtitle: Text('Repeso N° ${solicitud.repeso}'),
      leading: Image.asset(
        'assets/images/' + (solicitud.devMuerto ? 'pollomuerto' : 'pollovivo') + '.png',
          height: 36.0,
          width: 36.0,
          fit: BoxFit.fitWidth
      ),
      trailing: Icon(Icons.more_vert_rounded),
      onTap: () => openBottomModal(context, solicitud, repesos),
    );
  }

  void openBottomModal(BuildContext context, SolicitudDevolucion solicitud, List<PesajeDetalleItem> repesos) {
    showModalBottomSheet(context: context, 
      builder: (BuildContext context) {
              return Container(
                child: Column(
                  children: [
                    buildHeaderBottomModal(context, solicitud),
                    Divider(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: buildDetalleBottomModal(context, repesos),
                      ),
                    ),
                    Divider(),
                    buildBotonesBottomModal(context, solicitud)
                  ],
                )
              );
            },
    );
  }

  Widget buildHeaderBottomModal(BuildContext context, SolicitudDevolucion solicitud) {
    return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              decoration: BoxDecoration(color: Colors.amber[50]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Solicitud de Devolucion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                      Text('Pollo devuelto:  ${solicitud.producto} - ${solicitud.devMuerto ? 'POLLO MUERTO': 'POLLO VIVO'}'),
                      Text('Documento:       ${getLetterDoc(solicitud.tipoDoc)}${solicitud.serieDoc}-${solicitud.numeroDoc}'),
                      Text('Repeso N°:         ${solicitud.repeso}')
                    ],
                  ),
                  Image.asset(
                    'assets/images/' + (solicitud.devMuerto ? 'pollomuerto' : 'pollovivo') + '.png',
                    height: 60.0,
                    width: 60.0,
                    fit: BoxFit.fitWidth
                  ),
                ],
              ),
            );
  }

  Widget buildDetalleBottomModal(BuildContext context, List<PesajeDetalleItem> repesos) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(width: 1.0, color: Colors.black26),
        borderRadius: BorderRadius.circular(10.0)
      ),
      child: SingleChildScrollView(
        child: DataTable(
      
          columns: <DataColumn>[
            DataColumn(label: Text('#')),
            DataColumn(label: Text('Jabas')),
            DataColumn(label: Text('Unidades')),
            DataColumn(label: Text('Kilos')),
          ],
          rows: repesos.map((repeso) => DataRow(cells: <DataCell>[
              DataCell(Text('${repeso.Item}')),
              DataCell(Text('${repeso.Jabas}')),
              DataCell(Text('${repeso.Unidades}')),
              DataCell(Text('${repeso.Kilos}')),
            ])).toList()
        ),
      ),
    );
  }

  Widget buildBotonesBottomModal(BuildContext context, SolicitudDevolucion solicitud){
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              primary: Colors.red
            ),
            onPressed: () => deleteSolicitud(context, solicitud), 
            icon: Icon(Icons.delete_forever), 
            label: Text('Eliminar Solicitud')
          ),
          SizedBox(width: 8.0),
          ElevatedButton(
              child: const Text('Cerrar Detalle'),
              onPressed: () => {Navigator.pop(context)},
          )
        ],
      ),
    );
  }

  void deleteSolicitud(BuildContext context, SolicitudDevolucion solicitud) async{
    await showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.dangerous_outlined, color: Colors.red),
            SizedBox(width: 8.0),
            Text('Advertencia', style: TextStyle(color: Colors.red, fontSize: 18.0, fontWeight: FontWeight.bold),),
          ],
        ),
        content: Container(
          child: Text('Esta accion no puede revertirse una vez realizada ¿Estas seguro de continuar?'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async{
              try{
                await pedidoBloc.eliminarSolicitudDevolucion(solicitud);
                Fluttertoast.showToast(
                        msg: "Se elimino correctamente la solicitud",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 18.0);
                Navigator.pop(context);
                Navigator.pop(context);
                setState(() {});
              }catch(e){
                Fluttertoast.showToast(
                        msg: "Ocurrio un error al eliminar, intentalo nuevamente",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 18.0);
              }
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red),),
          ),
          TextButton(
            onPressed: () => {Navigator.pop(context)},
            child: Text('Cancelar', style: TextStyle(color: Colors.green),),
          ),
        ],
      )
    );
  }

  String getLetterDoc(int type) {
    return type == 1 ? 'F' : 'B';
  }
}