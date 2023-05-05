class FacturaPedido {
  String codigoProducto;
  String documento;
  double kilos;
  int lotePrincipal;
  int loteSecundario;
  String nombreProducto;
  int numTra;
  int numeroDoc;
  int pedido;
  int puntoVenta;
  int serieDoc;
  int tipoDoc;
  int ttra;
  int unidades;

  FacturaPedido(
      {this.codigoProducto,
      this.documento,
      this.kilos,
      this.lotePrincipal,
      this.loteSecundario,
      this.nombreProducto,
      this.numTra,
      this.numeroDoc,
      this.pedido,
      this.puntoVenta,
      this.serieDoc,
      this.tipoDoc,
      this.ttra,
      this.unidades});

  FacturaPedido.fromJson(Map<String, dynamic> json) {
    codigoProducto = json['CodigoProducto'];
    documento = json['Documento'];
    kilos = json['Kilos'].toDouble();
    lotePrincipal = json['LotePrincipal'];
    loteSecundario = json['LoteSecundario'];
    nombreProducto = json['NombreProducto'];
    numTra = json['NumTra'];
    numeroDoc = json['NumeroDoc'];
    pedido = json['Pedido'];
    puntoVenta = json['PuntoVenta'];
    serieDoc = json['SerieDoc'];
    tipoDoc = json['TipoDoc'];
    ttra = json['Ttra'];
    unidades = json['Unidades'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CodigoProducto'] = this.codigoProducto;
    data['Documento'] = this.documento;
    data['Kilos'] = this.kilos;
    data['LotePrincipal'] = this.lotePrincipal;
    data['LoteSecundario'] = this.loteSecundario;
    data['NombreProducto'] = this.nombreProducto;
    data['NumTra'] = this.numTra;
    data['NumeroDoc'] = this.numeroDoc;
    data['Pedido'] = this.pedido;
    data['PuntoVenta'] = this.puntoVenta;
    data['SerieDoc'] = this.serieDoc;
    data['TipoDoc'] = this.tipoDoc;
    data['Ttra'] = this.ttra;
    data['Unidades'] = this.unidades;
    return data;
  }
}