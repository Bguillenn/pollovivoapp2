import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollovivoapp/bloc/pedido_bloc.dart';
import 'package:pollovivoapp/model/lote.dart';
import 'package:pollovivoapp/model/pesaje_detalle_item.dart';
import 'package:pollovivoapp/model/save_request_cab.dart';
import 'package:pollovivoapp/model/transferencia_obtener_response.dart';

class TransferenciaHistorialScreen extends StatefulWidget {
  final List<Lote> lotes;
  final int puntoVenta;
  const TransferenciaHistorialScreen({@required this.lotes, @required this.puntoVenta});

  @override
  _TransferenciaHistorialScreenState createState() => _TransferenciaHistorialScreenState();
}

class _TransferenciaHistorialScreenState extends State<TransferenciaHistorialScreen> {
  final String title = 'Historial de transferencias';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppBar(context),
      body: FutureBuilder<TransferenciaObtenerResponse>(
        future: pedidoBloc.obtenerTransferencias(widget.puntoVenta, this.widget.lotes.map((lote) => lote.numero).toList().join(',')),
        builder: (context, snapshot) {
          if(!snapshot.hasData) return Center(child: CircularProgressIndicator());
          if(snapshot.hasError) return Center(child: Text('ERROR'));
          if(snapshot.data.repesosCabecera.length == 0) return Center(child: Text('No hay transferencias a planta registradas'));
          return renderBody(context, snapshot.data);
        }
      ),
    );
  }

  Widget renderAppBar(BuildContext context) {
    return AppBar(
          title: Text(this.title),
    );
  } 

  Widget renderBody(BuildContext context, TransferenciaObtenerResponse data) {
    return ListView.separated(
      itemCount: data.repesosCabecera.length,
      separatorBuilder: (context, i) => Divider(color: Colors.black26, height: 2), 
      itemBuilder: (context, i) => ListTile(
        dense: true,
        title: Text('Transferencia Repeso: ${data.repesosCabecera[i].Numero}'),
        subtitle: Text('Lote: ${data.repesosCabecera[i].LoteNumero}'),
        leading: Image.asset(
        'assets/images/' + (data.repesosCabecera[i].Tipo == 12 ? 'pollomuerto' : 'pollovivo') + '.png',
          height: 36.0,
          width: 36.0,
          fit: BoxFit.fitWidth
      ),
        trailing: Icon(Icons.more_vert_rounded),
        onTap: () => openBottomModal(context, data.repesosCabecera[i], data.repesosDetalle.where((repeso) => repeso.Numero == data.repesosCabecera[i].Numero).toList()),
      ), 
    );
  }

  void openBottomModal(BuildContext context, SaveRequestCab repeso ,List<PesajeDetalleItem> repesos) {
    showModalBottomSheet(context: context, 
      builder: (BuildContext context) {
              return Container(
                child: Column(
                  children: [
                    buildHeaderBottomModal(context, repeso),
                    Divider(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: buildDetalleBottomModal(context, repesos, repeso.LoteNumero),
                      ),
                    ),
                    Divider(),
                    buildBotonesBottomModal(context, repeso, repesos)
                  ],
                )
              );
            },
    );
  }

  Widget buildHeaderBottomModal(BuildContext context, SaveRequestCab repeso){
    String codigoProducto = this.widget.lotes.firstWhere((lote) => lote.numero == repeso.LoteNumero).codigo;
    String descripcionProducto = this.widget.lotes.firstWhere((lote) => lote.numero == repeso.LoteNumero).descripcion.replaceAll("POLLO VIVO", "PV");
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
                      Text('Transferencia a planta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                      Text('Pollo transferido:  $codigoProducto - $descripcionProducto'),
                      Text('Estado del pollo:   ${repeso.Tipo == 12 ? 'POLLO MUERTO': 'POLLO VIVO'}'),
                      Text('Lote:                       ${repeso.LoteNumero}'),
                      Text('Repeso N°:            ${repeso.Numero}')
                    ],
                  ),
                  Image.asset(
                    'assets/images/' + (repeso.Tipo == 12 ? 'pollomuerto' : 'pollovivo') + '.png',
                    height: 60.0,
                    width: 60.0,
                    fit: BoxFit.fitWidth
                  ),
                ],
              ),
            );
  }

  Widget buildDetalleBottomModal(BuildContext context, List<PesajeDetalleItem> repesos, int loteNumero) {
    TextStyle styleDeleteRecord = TextStyle(decoration: TextDecoration.lineThrough, color: Colors.black26);
    TextStyle styleNormalRecord = TextStyle(decoration: TextDecoration.none);
    int repesosRestantes = repesos.where((repeso) => repeso.nEstado == 1).toList().length;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(width: 1.0, color: Colors.black26),
        borderRadius: BorderRadius.circular(10.0)
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 46.0,
            columns: <DataColumn>[
              DataColumn(label: Text('#')),
              DataColumn(label: Text('Jabas')),
              DataColumn(label: Text('Und.')),
              DataColumn(label: Text('Kg.')),
              DataColumn(label: Text(''))
            ],
            rows: repesos.map((repeso) => DataRow(cells: <DataCell>[
                DataCell(Text('${repeso.Item}', style: repeso.nEstado == 1 ? styleNormalRecord : styleDeleteRecord)),
                DataCell(Text('${repeso.Jabas}', style: repeso.nEstado == 1 ? styleNormalRecord : styleDeleteRecord)),
                DataCell(Text('${repeso.Unidades}', style: repeso.nEstado == 1 ? styleNormalRecord : styleDeleteRecord)),
                DataCell(Text('${repeso.Kilos}', style: repeso.nEstado == 1 ? styleNormalRecord : styleDeleteRecord)),
                DataCell(
                  repeso.nEstado == 1 
                    ? IconButton(onPressed: () => onTapDeleteTransferenciaItem(context, repeso, repesosRestantes, loteNumero), icon: Icon(Icons.delete), color: Colors.red)
                     : Container())
              ])).toList()
          ),
        ),
      ),
    );
  }

  Widget buildBotonesBottomModal(BuildContext context, SaveRequestCab repeso, List<PesajeDetalleItem> repesos){
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              primary: Colors.red
            ),
            onPressed: () => onTapDeleteTransferencia(context, repeso, repesos), 
            icon: Icon(Icons.delete_forever), 
            label: Text('Anular transferencia')
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

  void onTapDeleteTransferenciaItem(BuildContext context, PesajeDetalleItem repeso, int repesosRestantes, int loteNumero) async {
    await mostrarDialogoConfirmacion(context,
      message: (repesosRestantes <= 1 )
        ? 'CUIDADO! Eliminar este repeso anulara la transferencia en general ya que es el ultimo ¿Estas seguro de continuar?' 
        : 'Eliminar el repeso no se puede revertir ¿Estas seguro de continuar?',
      onPressedConfirm: () async {
        try{
          await pedidoBloc.eliminarTransferenciaDetalle(widget.puntoVenta, repeso.Numero, repeso.Item);
          Fluttertoast.showToast(
                msg: "Se elimino correctamente el detalle de la transferencia",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 18.0);
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context, <int>[loteNumero, repeso.Unidades]);
          setState(() {});
        }catch(e) {
          Fluttertoast.showToast(
                msg: "Ocurrio un error al eliminar, intentalo nuevamente",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 18.0);
        }
      }
    );
  }

  void onTapDeleteTransferencia(BuildContext context, SaveRequestCab repeso, List<PesajeDetalleItem> repesos) async{
    await mostrarDialogoConfirmacion(context,
      message: 'Esta accion no puede revertirse una vez realizada ¿Estas seguro de continuar?',
      onPressedConfirm: () => deleteTransferencia(context, repeso, repesos)
    );
  }

  void deleteTransferencia(BuildContext context,SaveRequestCab repeso, List<PesajeDetalleItem> repesos) async {
      try{
        await pedidoBloc.eliminarTransferencia(widget.puntoVenta, repeso.Numero);
        Fluttertoast.showToast(
                msg: "Se elimino correctamente la transferencia",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 18.0);
        Navigator.pop(context);
        Navigator.pop(context);
        int totalUnidades =  repesos.fold(0, (previousValue, element) => previousValue += element.Unidades);
        Navigator.pop(context, <int>[repeso.LoteNumero, totalUnidades]);
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
  }


  Future<dynamic> mostrarDialogoConfirmacion(BuildContext context, {VoidCallback onPressedConfirm, String message}) async{
    return await showDialog(
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
          child: Text('$message'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: onPressedConfirm,
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
}