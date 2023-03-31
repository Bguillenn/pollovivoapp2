
import 'package:pollovivoapp/model/cliente.dart';

class Pesada{

  final int nPuntoVenta;
  final int nNumero;
  final int nPedido;
  final int nLoteNumero;
  final int nCliente;
  final String cProducto;
  final double nKilosTotal;
  final int nJabasTotal;
  final int nUnidadesTotal;


  Pesada(
    this.nPuntoVenta,
    this.nNumero,
    this.nPedido,
    this.nLoteNumero,
    this.nCliente,
    this.cProducto,
    this.nKilosTotal,
    this.nJabasTotal,
    this.nUnidadesTotal);

  Pesada.fromJson(Map<String, dynamic> json):
    this.nPuntoVenta = json["PuntoVenta"],
    this.nNumero = json["Numero"],
    this.nPedido = json["Pedido"],
    this.nLoteNumero = json["LoteNumero"],
    this.nCliente = json["Cliente"],
    this.cProducto = json["Producto"],
    this.nKilosTotal = json["KilosTotal"].toDouble(),
    this.nJabasTotal = json["JabasTotal"],
    this.nUnidadesTotal = json["UnidadesTotal"];
}