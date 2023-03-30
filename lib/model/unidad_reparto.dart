class UnidadReparto {
  int vehiculo;
  String placa;
  int altura;
  int fila;
  int columna;

  UnidadReparto.fromJson(Map<String, dynamic> json)
      : vehiculo = json["Vehiculo"],
        placa = json["Placa"],
        altura = json["Altura"],
        fila = json["Fila"],
        columna = json["Columna"];
}
