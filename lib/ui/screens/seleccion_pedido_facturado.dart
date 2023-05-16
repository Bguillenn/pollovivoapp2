import 'package:flutter/material.dart';
import 'package:pollovivoapp/bloc/pedido_bloc.dart';
import 'package:pollovivoapp/model/login_response.dart';
import 'package:pollovivoapp/model/lote.dart';
import 'package:pollovivoapp/model/pedido_buscar.dart';
import 'package:pollovivoapp/model/pedido_item.dart';
import 'package:pollovivoapp/model/solicitud_devolucion.dart';
import 'package:pollovivoapp/model/tipo_repeso.dart';
import 'package:pollovivoapp/ui/screens/seleccion_factura_screen.dart';
import 'package:pollovivoapp/ui/screens/solicitudes_devolucion_screen.dart';

class SeleccionPedidoFacturado extends StatelessWidget {
  final String title = 'Seleccion de pedido';
  final TipoRepeso tipoRepeso;
  final List<TipoRepeso> motivoDevoluciones;
  final List<TipoRepeso> tipoDevoluciones;
  final LoginResponse loginResponse;
  final List<Lote> lotes;
  final int puntoVenta;

  const SeleccionPedidoFacturado(
    this.tipoRepeso,
    this.motivoDevoluciones, 
    this.tipoDevoluciones,
    this.loginResponse,
    this.lotes,
    this.puntoVenta);


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: renderAppBar(context, this.title),
      body: FutureBuilder(
        future: pedidoBloc.obtenerPedidosConFacturacion('39'),
        builder: (context, snapshot) {
          if(!snapshot.hasData) return Center(child: CircularProgressIndicator());
          if(snapshot.data.length == 0) return Center(child: Text('No hay pedidos facturados'));
          if(snapshot.hasError) return Center(child: Text('Ocurrio un error obteniendo los datos'));
          return renderBody(context, snapshot.data);
        },
      ),
      floatingActionButton: renderFloatingActionButton(context),
    );
  }

  AppBar renderAppBar(BuildContext context, String title) {
    return AppBar(
      title: Text(title),
      actions: [
        TextButton(
          //textColor: Colors.white,
          onPressed: () {Navigator.pop(context);},
          child: Text("Cancelar", style: TextStyle(color: Colors.white)),
          //shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
        ),
      ],
    );
  }

  Widget renderFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        await Navigator.push(
              context,
              new MaterialPageRoute<int>(
                  builder: (context) => SolicitudesDevolucionScreen(this.puntoVenta)));
      },
      icon: Icon(Icons.library_books_outlined),
      label: Text('Ver solicitudes')
    );
  }

  Widget renderBody(BuildContext context, List<EstadoPedido> pedidos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: renderListView(context, pedidos)
        )
      ],
    );
  }

  Widget renderListView(BuildContext context, List<EstadoPedido> pedidos) {
    return Center(
      child: ListView.builder(
        itemCount: pedidos.length,
        itemBuilder: (_, i) => buildListTile(context, pedidos[i])
      ),
    );
  }

  Widget buildListTile(BuildContext context, EstadoPedido pedido) {
    return ListTile(
      title: Text('Pedido ${pedido.nNumero}'),
      subtitle: Text('${pedido.nCliente} - ${pedido.cCliente}'),
      leading: Icon(Icons.link_sharp),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () async{
        Navigator.push(
              context,
              new MaterialPageRoute<int>(
                  builder: (context) => SeleccionFactura(
                    pedido, 
                    this.tipoRepeso,
                    this.motivoDevoluciones, 
                    this.tipoDevoluciones,
                    this.loginResponse,
                    this.lotes,
                    this.puntoVenta)));
      }, //Navigate
    );
  }
}