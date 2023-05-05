
import 'package:pollovivoapp/util/utils.dart';

class PedidoBuscarRequest {
  PedidoEstadoBuscar buscar;
  PedidoBuscarRequest(this.buscar);
  Map<String, dynamic> toJson() => {
    "buscar": buscar.toJson()
  };

}

class PedidoEstadoBuscar {
  int PuntoVenta;
  int CodigoCliente;
  DateTime Desde;
  DateTime Hasta;
  PedidoEstadoBuscar(this.PuntoVenta,this.CodigoCliente,this.Desde,this.Hasta);

  Map<String, dynamic> toJson() => {
    "PuntoVenta": PuntoVenta,
    "CodigoCliente": CodigoCliente,
    "Desde": DateTimeToWCF(Desde),//Desde.toIso8601String(),
    "Hasta": DateTimeToWCF(Hasta),//Hasta.toIso8601String(),
  };
}

class PedidoEstadoBuscarResponse {
  final String cMensaje;
  final String cMsjError;
  final int nCodError;
  final List<EstadoPedido> Pedidos;

  PedidoEstadoBuscarResponse(
      this.cMensaje, this.cMsjError, this.nCodError, this.Pedidos);

  PedidoEstadoBuscarResponse.fromJson(Map<String, dynamic> json)
      : cMensaje = json['cMensaje'],
        cMsjError = json['cMsjError'],
        nCodError = json['nCodError'],
        Pedidos = List<EstadoPedido>.from(
            json['oContenido'].map((reparto) => EstadoPedido.fromJson(reparto)));
}

class EstadoPedido{
  int nPuntoVenta;
  int nNumero;
  int nCliente;
  String cCliente;
  DateTime dFechaRegistro;
  DateTime dFechaEntrega;
  double nTotal;
  int nEstado;
  int nResponsable;
  EstadoPedido.fromJson(Map<String, dynamic> json)
      : nPuntoVenta = json["nPuntoVenta"],
        nNumero = json["nNumero"],
        nCliente = json["nCliente"],
        cCliente = json["cCliente"],
        dFechaRegistro = WCFtoDateTime(json["dFechaRegistro"].toString()),
        dFechaEntrega = WCFtoDateTime(json["dFechaEntrega"].toString()),
        nTotal = json["nTotal"].toDouble(),
        nEstado = json["nEstado"],
        nResponsable = json["nResponsable"];
}