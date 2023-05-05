class SolicitudDevolucion {
  int puntoVenta;
  int tipoDoc;
  int serieDoc;
  int numeroDoc;
  int tTra;
  int numtra;
  int repeso;
  String producto;
  bool devMuerto;

  SolicitudDevolucion(
      {this.puntoVenta,
      this.tipoDoc,
      this.serieDoc,
      this.numeroDoc,
      this.tTra,
      this.numtra,
      this.repeso,
      this.producto,
      this.devMuerto});

  SolicitudDevolucion.fromJson(Map<String, dynamic> json) {
    puntoVenta = json['PuntoVenta'];
    tipoDoc = json['TipoDoc'];
    serieDoc = json['SerieDoc'];
    numeroDoc = json['NumeroDoc'];
    tTra = json['TTra'];
    numtra = json['Numtra'];
    producto = json['Producto'];
    repeso = json['Repeso'];
    devMuerto = json['DevMuerto'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PuntoVenta'] = this.puntoVenta;
    data['TipoDoc'] = this.tipoDoc;
    data['SerieDoc'] = this.serieDoc;
    data['NumeroDoc'] = this.numeroDoc;
    data['TTra'] = this.tTra;
    data['Numtra'] = this.numtra;
    data['Producto'] = this.producto;
    data['Repeso'] = this.repeso;
    data['DevMuerto'] = this.devMuerto;
    return data;
  }
}