import 'package:intl/intl.dart';
class PesajeDetalleItem {
  int Numero;
  final int Item;
  final int Jabas;
  final int Unidades;
  final double Kilos;
  double KilosSinTara;
  double SubTotal;
  bool Estado=false;
  String Uuid;
  DateTime FechaRegistro;
  int nEstado = 1;
  int nTipoBalanza= 0;
  PesajeDetalleItem(this.Numero, this.Item, this.Jabas, this.Unidades, this.Kilos){
    this.FechaRegistro = DateTime.now();
  }

  PesajeDetalleItem.fromJson(Map<String, dynamic> json)
      : Numero = json["Numero"],
        Item = json["Item"],
        Jabas = json["Jabas"].toInt(),
        Unidades = json["Unidades"].toInt(),
        SubTotal = json["SubTotal"],
        Kilos = json["Kilos"],
        FechaRegistro = DateTime.parse(json["FechaRegistro"] ?? '2023-05-01'),
        nEstado = json["nEstado"];

  Map<String, dynamic> toJson() => {
    "Numero": Numero,
    "Item": Item,
    "Jabas": Jabas,
    "Unidades": Unidades,
    "Kilos": Kilos,
    "SubTotal": SubTotal,
    "Estado": Estado,
    "fechaRegistro": FechaRegistro.toString(),
    "nEstado": nEstado
  };
  PesajeDetalleItem.fromJson2(Map<String, dynamic> json)
      : Numero = json["Numero"],
        Item = json["Item"].toInt(),
        Jabas = json["Jabas"].toInt(),
        Unidades = json["Unidades"].toInt(),
        Kilos = json["Kilos"],
        nEstado = json["nEstado"];

  Map<String, dynamic> toJson2() => {
        "Numero": Numero,
        "Uuid": Uuid,
        "Item": Item,
        "Jabas": Jabas,
        "Unidades": Unidades,
        "Kilos": Kilos,
        "fechaRegistro": FechaRegistro.toString(),
        "nEstado": nEstado
      };
}
