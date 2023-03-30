class SaveRequestCab {
  final int PuntoVenta;
  final int Cliente;
  final int LoteNumero;
  final int Pedido;
  final int ItemPedido;
  int Tipo;
  DateTime FechaRegistro;
  int NumeroPR;
   int ItemPR;
  int Numero = 0;
  String LotesNumero;
  String ItemsPR;
  String Uuid;
  String Estado;
  String Observacion;
  int ClienteTestaferro = -1;
  int nPedidoTestaferro = 0;
  int nTipoBalanza;
  SaveRequestCab(
      this.PuntoVenta,
      this.Cliente,
      this.LoteNumero,
      this.Pedido,
      this.ItemPedido,
      this.Tipo,
      this.NumeroPR,
      this.ItemPR
  ){
    FechaRegistro = DateTime.now();
  }

  SaveRequestCab.fromJson(Map<String, dynamic> json)
      : PuntoVenta = json["PuntoVenta"],
        Cliente = json["Cliente"],
        Numero = json["Numero"],
        LoteNumero = json["LoteNumero"],
        Pedido = json["Pedido"],
        ItemPedido = json["ItemPedido"],
        Tipo = json["Tipo"],
        Observacion = json["Observacion"],
        ClienteTestaferro = json["nClienteTestaferro"],
        nPedidoTestaferro = json["nPedidoTestaferro"],
        nTipoBalanza = json["nTipoBalanza"];

  Map<String, dynamic> toJson() => {
        "PuntoVenta": PuntoVenta,
        "Cliente": Cliente,
        "LoteNumero": LoteNumero,
        "LotesNumero": LotesNumero,
        "Pedido": Pedido,
        "ItemPedido": ItemPedido,
        "Tipo": Tipo,
        "Numero": Numero,
        "NumeroPR": NumeroPR,
        "ItemPR": ItemPR,
        "ItemsPR": ItemsPR,
        "Uuid": Uuid,
        "FechaRegistro": FechaRegistro.toString(),
        "Estado": Estado,
        "Observacion": Observacion,
        "nClienteTestaferro": ClienteTestaferro,
        "nPedidoTestaferro": nPedidoTestaferro,
        "nTipoBalanza": nTipoBalanza
      };

  Map<String, dynamic> toJson2() => {
    "PuntoVenta": PuntoVenta,
    "Cliente": Cliente,
    "LoteNumero": LoteNumero,
    "LotesNumero": LotesNumero,
    "Pedido": Pedido,
    "ItemPedido": ItemPedido,
    "Tipo": Tipo,
    "Numero": Numero,
    "NumeroPR": NumeroPR,
    "ItemPR": ItemPR,
    "ItemsPR": ItemsPR,
    "Uuid": Uuid,
    "Estado": Estado,
    "Observacion": Observacion,
    "nClienteTestaferro": ClienteTestaferro,
    "nPedidoTestaferro": nPedidoTestaferro,
    "nTipoBalanza": nTipoBalanza
  };

  SaveRequestCab.fromJson2(Map<String, dynamic> json)
      : PuntoVenta = json["PuntoVenta"],
        Cliente = json["Cliente"],
        LoteNumero = json["LoteNumero"],
        LotesNumero = json["LotesNumero"],
        Pedido = json["Pedido"],
        ItemPedido = json["ItemPedido"],
        Tipo = json["Tipo"],
        Numero = json["Numero"],
        NumeroPR = json["NumeroPR"],
        ItemPR = json["ItemPR"],
        ItemsPR = json["ItemsPR"],
        Uuid = json["Uuid"],
        FechaRegistro = DateTime.parse(json["FechaRegistro"]),
        Estado = json["Estado"],
        Observacion = json["Observacion"],
        ClienteTestaferro = json["nClienteTestaferro"],
        nPedidoTestaferro = json["nPedidoTestaferro"],
        nTipoBalanza = json["nTipoBalanza"];
}
