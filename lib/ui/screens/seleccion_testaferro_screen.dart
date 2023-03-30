import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollovivoapp/bloc/pedido_bloc.dart';
import 'package:pollovivoapp/model/cliente.dart';
import 'package:pollovivoapp/model/grupo_cliente.dart';
import 'package:pollovivoapp/model/login_response.dart';
import 'package:pollovivoapp/model/lote.dart';
import 'package:pollovivoapp/model/pedido_item.dart';
import 'package:pollovivoapp/model/pedido_request.dart';
import 'package:pollovivoapp/model/pedido_response.dart';
import 'package:pollovivoapp/model/ranfla.dart';
import 'package:pollovivoapp/model/reparto_header.dart';
import 'package:pollovivoapp/model/tipo_repeso.dart';
import 'package:pollovivoapp/ui/screens/pedido_screen.dart';

class SeleccionTestaferroScreen extends StatefulWidget {
  final GrupoCliente grupoCliente;
  final TipoRepeso tipoRepeso;
  final int puntoVenta;
  final TipoRepeso tipoVenta;
  final Ranfla ranfla;
  final List<Lote> lotesDisponibles;
  final RepartoCabecera repartoCabecera;
  final LoginResponse loginResponse;
  final List<Cliente> testaferros;

  SeleccionTestaferroScreen(
      this.grupoCliente,
      this.tipoRepeso,
      this.puntoVenta,
      this.tipoVenta,
      this.ranfla,
      this.lotesDisponibles,
      this.repartoCabecera,
      this.loginResponse,
      this.testaferros);

  @override
  _SeleccionTestaferroScreenState createState() =>
      _SeleccionTestaferroScreenState();
}

class _SeleccionTestaferroScreenState extends State<SeleccionTestaferroScreen> {
  final String viewTitle = 'Seleccion de testaferro';
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: renderAppBar(this.viewTitle),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildVentaInformation(context),
            SizedBox(height: 10.0),
            Text('Selecciona el testaferro'),
            Expanded(child: buildListView(this.widget.grupoCliente.oClientes))
          ],
        ));
  }

  Widget buildVentaInformation(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.amber[100]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Grupo: ${this.widget.grupoCliente.cNombre}'),
            Text('Tipo de venta: ${this.widget.tipoVenta.nombre}'),
            Text(this.widget.ranfla.toString()),
          ],
        ));
  }

  ListView buildListView(List<Cliente> clientes) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: clientes.length,
      itemBuilder: (_, i) => buildListTitle(clientes[i]),
    );
  }

  Widget buildListTitle(Cliente cliente) {
    return ListTile(
      title: Text(cliente.nombre),
      subtitle: Text('Codigo del cliente: ${cliente.codigo}'),
      leading: Icon(Icons.person),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: isLoading ? null : () => onTapTestaferro(cliente),
    );
  }

  AppBar renderAppBar(String title) {
    return AppBar(title: Text(title));
  }

  void onTapTestaferro(Cliente cliente) async {
    if (isLoading) {
      Fluttertoast.showToast(msg: 'Espere esta cargando la data del usuario');
      return;
    }
    isLoading = true;
    PedidoResponse pedidosCliente = await obtenerPedidosCliente(cliente);
    if (validarPedidosCliente(pedidosCliente) == false) {
      isLoading = false;
      mostrarToastError("El cliente no tiene pedidos en la ranfla");
      return;
    }
    int numero = await Navigator.push(
        context,
        new MaterialPageRoute<int>(
          builder: (context) => PedidoScreen(
              pedidosCliente,
              this.widget.tipoRepeso,
              cliente,
              this.widget.repartoCabecera,
              this.widget.puntoVenta,
              this.widget.loginResponse,
              this.widget.testaferros,
              this.widget.tipoVenta),
        ));
    print('${cliente.nombre} presionado');
    isLoading = false;
    Navigator.pop(context);
  }

  Future<PedidoResponse> obtenerPedidosCliente(Cliente cliente) async {
    PedidoRequest pedidoRequest = PedidoRequest(
        this.widget.puntoVenta,
        cliente.codigo,
        this.widget.tipoVenta.codigo == 0 ? this.widget.tipoVenta.codigo : 10);

    PedidoResponse pedidoResponse =
        await pedidoBloc.fetchDataPedido(pedidoRequest);

    return pedidoResponse;
  }

  Future<bool> mostrarToastError(String message) {
    return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 20.0,
    );
  }

  bool validarPedidosCliente(PedidoResponse pedidosCliente) {
    if (pedidosCliente.nCodError != 0) return false;

    pedidosCliente.pedidoData.pedidoDetalles
        .forEach((PedidoItem pedidoDetalle) {
      List<Lote> lotesHabilitados = this
          .widget
          .lotesDisponibles
          .where((lote) => pedidoDetalle.producto == lote.codigo)
          .toList();
      return lotesHabilitados.length > 0;
    });
  }
}
