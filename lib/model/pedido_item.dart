import 'package:pollovivoapp/model/repeso_item.dart';

class PedidoItem {
  final int numeroPedido;
  final int item;
  final String producto;
  String nombre;
  double pesoPromedio;
  double rangoPermitido;
  int cantidad;
  int cantidadRP;
  int cantidadAcopio;
  int cantidadReparto;
  int cantidadDevolucion;
  int estado;
  int reparto;
  int cliente;

  List<RepesoItem> repesos;

  PedidoItem(this.numeroPedido, this.item, this.producto, this.cantidadRP) {
    this.cantidad = 0;
  }

  PedidoItem.fromJson(Map<String, dynamic> json)
      : numeroPedido = json["Numero"],
        item = json["Item"],
        producto = json["Producto"],
        nombre = json["Nombre"],
        cantidad = json["Cantidad"],
        cantidadRP = json["CantidadRP"],
        cantidadAcopio = json["CantidadAcopio"],
        cantidadReparto = json["CantidadReparto"],
        cantidadDevolucion = json["CantidadDevolucion"],
        pesoPromedio = json["PesoPromedio"],
        rangoPermitido = json["RangoPermitido"],
        estado = json["Estado"],
        reparto = json["Reparto"],
        cliente = json["Cliente"];

  Map<String, dynamic> toJson() => {
        "Numero": numeroPedido,
        "Item": item,
        "Producto": producto,
        "Nombre": nombre,
      };

  initCantidad() {
    cantidadAcopio = 0;
    cantidadReparto = 0;
    cantidadDevolucion = 0;
  }
}
