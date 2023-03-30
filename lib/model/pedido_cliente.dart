import 'package:flutter/material.dart';
import 'package:pollovivoapp/model/tuple.dart';

class PedidoCliente {
  int nPuntoVenta;
  int nNumero;
  int nPedido;
  int nCliente;
  int nClienteTestaferro;
  int nPedidoFacturacion;
  String cPedidoFacturacion;
  int nZisePedido;
  int nJabas;
  double nKilosTotal;

  PedidoCliente(this.nPuntoVenta,this.nNumero,this.nPedido,this.nCliente,this.nClienteTestaferro,this.nPedidoFacturacion,this.cPedidoFacturacion,this.nZisePedido);

  PedidoCliente.fromJson(Map<String, dynamic> json)
      : nPuntoVenta = json["nPuntoVenta"],
        nNumero = json["nNumero"],
        nPedido = json["nPedido"],
        nCliente = json["nCliente"],
        nClienteTestaferro = json["nClienteTestaferro"],
        nPedidoFacturacion = json["nPedidoFacturacion"],
        cPedidoFacturacion = json["cPedidoFacturacion"],
        nZisePedido = json["nZisePedido"],
        nJabas = json["nJabas"],
        nKilosTotal = json["nKilosTotal"];

  Map<String, dynamic> toJson() => {
    "nPuntoVenta": nPuntoVenta,
    "nNumero": nNumero,
    "nPedido": nPedido,
    "nCliente": nCliente,
    "nClienteTestaferro": nClienteTestaferro,
    "nPedidoFacturacion": nPedidoFacturacion,
    "cPedidoFacturacion": cPedidoFacturacion,
    "nZisePedido": nZisePedido,
    "nJabas": nJabas,
    "nKilosTotal": nKilosTotal
  };
}
