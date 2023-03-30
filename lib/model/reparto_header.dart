import 'package:pollovivoapp/model/reparto_item.dart';

class RepartoCabecera {
  final int PuntoVenta;
  int NumeroReparto;
  final int Vehiculo;
  bool Cerrado;
  String UsuarioRegistro;
  final DateTime FechaRegistro;
  String Nombre;
  List<RepartoItem> items = new List();
  int Filas, Columnas;

  RepartoCabecera(this.PuntoVenta,this.NumeroReparto,this.Vehiculo, this.FechaRegistro,this.Nombre);

  RepartoCabecera.fromJson(Map<String, dynamic> json)
      : PuntoVenta = json["PuntoVenta"],
        NumeroReparto = json["Numero"],
        Vehiculo = json["Vehiculo"],
        Cerrado = json["Cerrado"],
        UsuarioRegistro = json["UsuarioRegistro"],
        FechaRegistro = DateTime.fromMillisecondsSinceEpoch(int.parse(json["FechaRegistro"].toString().replaceAll("/Date(", "").replaceAll("-0500)/", "")));

    Map<String, dynamic> toJson() => {
      "PuntoVenta": PuntoVenta,
      "Numero": NumeroReparto,
      "Vehiculo": Vehiculo,
     /* "UsuarioRegistro": UsuarioRegistro,*/
    };
}
