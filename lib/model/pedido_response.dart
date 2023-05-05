import 'package:pollovivoapp/model/pedido_data.dart';
import 'package:pollovivoapp/model/pedido_item.dart';

class PedidoResponse {
  final String cMensaje;
  final String cMsjError;
  final int nCodError;
  final PedidoData pedidoData;

  PedidoResponse(
      this.cMensaje, this.cMsjError, this.nCodError, this.pedidoData);

  PedidoResponse.fromJson(Map<String, dynamic> json)
      : cMensaje = json['cMensaje'],
        cMsjError = json['cMsjError'],
        nCodError = json['nCodError'],
        pedidoData = json['oContenido'] != null
            ? PedidoData.fromJson(json['oContenido'])
            : PedidoData(List.empty(growable: true), List.empty(growable: true));
}

class PedidoDetalleResponse {
  final String cMensaje;
  final String cMsjError;
  final int nCodError;
  final PedidoCerrar oPedido;

  PedidoDetalleResponse(
      this.cMensaje, this.cMsjError, this.nCodError, this.oPedido);

  PedidoDetalleResponse.fromJson(Map<String, dynamic> json)
    : cMensaje = json['cMensaje'],
    cMsjError = json['cMsjError'],
    nCodError = json['nCodError'],
    oPedido = PedidoCerrar.fromJson(json["oContenido"]);
}

class PedidoCerrar {
  final List<PedidoItem> listPedidos;
  final List<DetallePedio> listDetalle;
  PedidoCerrar(
      this.listPedidos,  this.listDetalle);

  PedidoCerrar.fromJson(Map<String, dynamic> json)
      : listPedidos = List<PedidoItem>.from(json["Cabecera"].map((obj) => PedidoItem.fromJson(obj))),
        listDetalle = List<DetallePedio>.from(json["Detalle"].map((obj) => DetallePedio.fromJson(obj)));
}

class DetallePedio{

  int nPuntoVenta;
  int nLoteNumero;
  int nTipo;
  String cProducto;
  String cTipo;
  double nJabas;
  double nUnidades;
  double nKilos;

  DetallePedio.fromJson(Map<String, dynamic> json)
      : nPuntoVenta = json["nPuntoVenta"],
        nLoteNumero = json["nLoteNumero"],
        nTipo = json["nTipo"],
        cTipo = json["cTipo"],
        cProducto = json["cProducto"],
        nJabas = json["nJabas"],
        nUnidades = json["nUnidades"],
        nKilos = json["nKilos"];
}