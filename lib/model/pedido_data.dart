import 'package:pollovivoapp/model/pedido_item.dart';
import 'package:pollovivoapp/model/repeso_item.dart';

class PedidoData {
  List<PedidoItem> pedidoDetalles;
  List<RepesoItem> repesoDetalle;

  PedidoData(this.pedidoDetalles,this.repesoDetalle);

  PedidoData.fromJson(Map<String, dynamic> json)
      : pedidoDetalles = List<PedidoItem>.from(json["Cabecera"].map((cabecera) => PedidoItem.fromJson(cabecera))),
        repesoDetalle = List<RepesoItem>.from(json["Detalle"]
            .map((itemDetalle) => RepesoItem.fromJson(itemDetalle)));
}
