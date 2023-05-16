import 'dart:ui';

class Lote {
  final int lotePrincipal;
  final int viaje;
  final int numero;
  final String placa;
  final String codigo;
  final String descripcion;
  int unidades;
  final int jabas;
  int disponible;
  final double taraJaba;
  int unidadesPorJaba;
  double precio;
  Color colorLote;



  Lote(
      this.lotePrincipal,
      this.numero,
      this.viaje,
      this.placa,
      this.codigo,
      this.descripcion,
      this.unidades,
      this.jabas,
      this.taraJaba,
      this.disponible){
        this.precio = 0.0;
        this.unidadesPorJaba = 1;
      }


  Lote.fromJson(Map<String, dynamic> json)
      : lotePrincipal = json["LotePrincipal"],
        viaje = json["Viaje"],
        numero = json["Numero"],
        placa = json["Placa"],
        codigo = json["Codigo"],
        descripcion = json["Descripcion"],
        unidades = json["Unidades"],
        jabas = json["Jabas"],
        disponible = json["Disponible"],
        taraJaba = json["TaraJaba"],
        precio = json["Precio"],
        unidadesPorJaba = json["UnidadesxJaba"];

  int cantidadPollosPorLote() {
    if (this.jabas == 0)
      return 8;
    else
      return (this.unidades / this.jabas).round();
  }

  @override
  String toString() {
    return this.numero.toString() + " - " + this.placa.trim();
  }
}
