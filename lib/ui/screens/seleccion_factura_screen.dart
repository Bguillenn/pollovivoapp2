import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollovivoapp/bloc/pedido_bloc.dart';
import 'package:pollovivoapp/model/cliente.dart';
import 'package:pollovivoapp/model/factura_pedido.dart';
import 'package:pollovivoapp/model/login_response.dart';
import 'package:pollovivoapp/model/lote.dart';
import 'package:pollovivoapp/model/pedido_buscar.dart';
import 'package:pollovivoapp/model/pedido_item.dart';
import 'package:pollovivoapp/model/save_request.dart';
import 'package:pollovivoapp/model/save_request_solicitud.dart';
import 'package:pollovivoapp/model/solicitud_devolucion.dart';
import 'package:pollovivoapp/model/tipo_repeso.dart';
import 'package:pollovivoapp/ui/screens/pesaje_screen.dart';

class SeleccionFactura extends StatefulWidget {
  final EstadoPedido pedido;
  final TipoRepeso tipoRepeso;
  final List<TipoRepeso> motivoDevoluciones;
  final List<TipoRepeso> tipoDevoluciones;
  final LoginResponse loginResponse;
  final List<Lote> lotes;

  const SeleccionFactura(
    this.pedido, 
    this.tipoRepeso,
    this.motivoDevoluciones, 
    this.tipoDevoluciones,
    this.loginResponse,
    this.lotes);

  @override
  _SeleccionFacturaState createState() => _SeleccionFacturaState();
}

class _SeleccionFacturaState extends State<SeleccionFactura> {
  final String title = 'Seleccion de factura';
  String selectedValueTipoDevolucion = '';
  String selectedValueMotivoDevolucion = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppBar(this.title),
      body: FutureBuilder(
          future: pedidoBloc.obtenerFacturasPedido('39', this.widget.pedido.nNumero),
          builder: (context, snapshot) {
            if(!snapshot.hasData) return Center(child: CircularProgressIndicator());
            if(snapshot.data.length == 0) return Center(child: Text('El pedido no tiene facturas'));
            
            return renderBody(snapshot.data);
          }
      ),
    );
  }

  AppBar renderAppBar(String title) {
    return AppBar(
      title: Text(title),
      actions: [
        TextButton(
          onPressed: () { Navigator.pop(context); Navigator.pop(context);},
          child: Text("Cancelar", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget renderBody(List<FacturaPedido> facturaPedidos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        renderPedidoInfoBox(),
        renderDropdownTipoDevolucion(),
        renderDropdownMotivoDevolucion(),
        Divider(),
        Padding(padding: EdgeInsets.all(8.0), child: Text('Selecciona una factura')),
        Expanded(
          child: renderListView(facturaPedidos)
        )
      ],
    );
  }

  Widget renderPedidoInfoBox() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(color: Colors.amber[50]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pedido N° ${this.widget.pedido.nNumero}'),
          Text('Cliente: ${this.widget.pedido.nCliente} - ${this.widget.pedido.cCliente}')
        ],
      ),
    );
  }

  Widget renderDropdownTipoDevolucion() {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tipo de pollo:'),
          SizedBox(height: 8.0,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
            child: DropdownButton<String>(
                value: selectedValueTipoDevolucion,
                items: [
                  DropdownMenuItem<String>(child: Text('Selecciona un tipo', style: TextStyle(color: Colors.black54),), value: ''),
                  ...this.widget.tipoDevoluciones.map((tipo) =>  
                    DropdownMenuItem(child: Text('${tipo.nombre}'), value: tipo.codigo.toString())
                  ).toList()
                ],
                onChanged: (String newValue) =>
                    setState(() => selectedValueTipoDevolucion = newValue),
                iconSize: 30.0,
                isExpanded: true,
                underline: SizedBox(),
              ),
          )
        ],
      ),
    );
  }

  Widget renderDropdownMotivoDevolucion() {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Motivo de devolucion:'),
          SizedBox(height: 8.0,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
            child: DropdownButton<String>(
                value: selectedValueMotivoDevolucion,
                items: [
                  DropdownMenuItem<String>(child: Text('Selecciona un motivo', style: TextStyle(color: Colors.black54),), value: ''),
                  ...this.widget.motivoDevoluciones.map((tipo) =>  
                    DropdownMenuItem(child: Text('${tipo.nombre}'), value: tipo.codigo.toString())
                  ).toList()
                ],
                onChanged: (String newValue) =>
                    setState(() => selectedValueMotivoDevolucion = newValue),
                iconSize: 30.0,
                isExpanded: true,
                underline: SizedBox(),
              ),
          )
        ],
      ),
    );
  }

  Widget renderListView(List<FacturaPedido> facturaPedidos) {
    return ListView.builder(
      itemCount: facturaPedidos.length,
      itemBuilder: (_, i) => buildListTile(facturaPedidos[i]),
    );
  }

  Widget buildListTile(FacturaPedido facturaPedido) {

    final Lote lote = this.widget.lotes.firstWhere((lote) => lote.numero == facturaPedido.loteSecundario);
    return ListTile(
      title: Text('${facturaPedido.documento}    N° Tra. ${facturaPedido.numTra}', style: TextStyle(fontWeight: FontWeight.bold),),
      subtitle: RichText(text: TextSpan(
        style: TextStyle(
          color: Colors.black54
        ),
        children: <TextSpan>[
          TextSpan(text: '${facturaPedido.codigoProducto} - ${facturaPedido.nombreProducto}                             '+
                    'U. ${facturaPedido.unidades} KG. ${facturaPedido.kilos} '),
          TextSpan(text: '[${lote.placa.trim() ?? 'S/P'}] ${facturaPedido.loteSecundario}', style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold))
        ] 
      )),
      leading: Icon(Icons.inventory_outlined),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () => onTapListTile(context, facturaPedido, lote)  //Navigate
    );
  }

  void onTapListTile(BuildContext context, FacturaPedido facturaPedido, Lote lote) async{
    //Si no selecciono tipo de devolucion
    if(selectedValueTipoDevolucion == ''){
      Fluttertoast.showToast(
        msg: "Debe seleccionar el tipo de pollo devuelto!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    //Si no selecciono motivo de devolucion
    if(selectedValueMotivoDevolucion == ''){
      Fluttertoast.showToast(
        msg: "Debe seleccionar el motivo de la devolucion!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    TipoRepeso findMotivo(int codigo) => this.widget.motivoDevoluciones.firstWhere((motivo) => motivo.codigo == codigo);
    SaveRequest requestToSave = await Navigator.push(
          context,
          new MaterialPageRoute<SaveRequest>(
              builder: (context) => PesajeScreen(
                  this.widget.tipoDevoluciones.firstWhere((element) => element.codigo == int.parse(this.selectedValueTipoDevolucion)),
                  Cliente(this.widget.pedido.nCliente, this.widget.pedido.cCliente, 0),
                  lote ?? Lote(facturaPedido.lotePrincipal, facturaPedido.loteSecundario, 0, '', facturaPedido.codigoProducto , facturaPedido.nombreProducto, facturaPedido.unidades, 0, widget.loginResponse.loginData.dataUsuario.taraJava, 100),
                  39,
                  PedidoItem(facturaPedido.pedido, 1, facturaPedido.codigoProducto, 0),
                  widget.loginResponse,
                  null,
                  findMotivo(int.parse(selectedValueMotivoDevolucion)).nombre,
                  true,
                  List<Cliente>.empty(),
                  TipoRepeso(0, 'Venta Acopio/Directa'))));
    
    SolicitudDevolucion solicitudDevolucion = SolicitudDevolucion(
        puntoVenta: facturaPedido.puntoVenta,
        tipoDoc: facturaPedido.tipoDoc,
        serieDoc: facturaPedido.serieDoc,
        numeroDoc: facturaPedido.numeroDoc,
        tTra: facturaPedido.ttra,
        numtra: facturaPedido.numTra,
        producto: facturaPedido.codigoProducto,
        devMuerto: int.parse(selectedValueTipoDevolucion) == 4
      );
      if(requestToSave == null){
        Fluttertoast.showToast(
          msg: "No se registraron pesadas",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }
      SaveRequestSolicitud saveRequestSolicitud = SaveRequestSolicitud(requestToSave.oCabecera, requestToSave.oDetalle, solicitudDevolucion);
      pedidoBloc.saveSolicitudDevolucion(saveRequestSolicitud).then((SolicitudDevolucion response) async{
        Fluttertoast.showToast(
          msg: "Se guardo correctamente la devolucion repeso ${response.repeso}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pop(context);
        Navigator.pop(context);
      }).catchError((err) {
        Fluttertoast.showToast(
          msg: "Sucedio un error al realizar la devolucion - ${err.toString()}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      });
  }
}