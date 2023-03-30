class LotePrincipal {
  final int Numero;
  final String Placa;
  int index;
  LotePrincipal(this.Numero, this.Placa);
  LotePrincipal.fromJson(Map<String, dynamic> json)
      : Numero = json["Numero"],
        Placa = json["Placa"];

  @override
  String toString() {
    return this.Numero.toString() + " - " + this.Placa.trim();
  }
}
