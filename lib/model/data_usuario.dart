class DataUsuario {
  final String usuario;
  final int codigoPersonal;
  final String nombrePersonal;
  final int puntoVentaCodigo;
  double minimo;
  double maximo;
  double taraJava;
  String puntoVentaNombre;
  int holgura;
  bool balanzaManual;

  DataUsuario(this.usuario, this.codigoPersonal, this.nombrePersonal,
      this.puntoVentaCodigo) {
    this.puntoVentaNombre = "PuntoVentaNombre";
  }

  DataUsuario.empty()
      : this.usuario = "",
        this.codigoPersonal = 0,
        this.nombrePersonal = "",
        this.puntoVentaCodigo = 0,
        this.puntoVentaNombre = "PuntoVentaNombre";

  DataUsuario.fromJson(Map<String, dynamic> json)
      : usuario = json['Usuario'],
        codigoPersonal = json['nCodPlanilla'],
        nombrePersonal = json['NombrePersonal'],
        puntoVentaCodigo = json['PuntoventaDefecto'],
        minimo = json['Minimo'],
        maximo = json['Maximo'],
        taraJava = json['TaraJava'],
        holgura = json['Holgura'],
        puntoVentaNombre = "PuntoVentaNombre",
        balanzaManual = json["BalanzaManual"];
}
