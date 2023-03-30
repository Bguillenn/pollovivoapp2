class RepesoItem {
  final int Pedido;
  final int LoteNumero;
  final int NumeroReparto;
  final int NumeroPR;
  final int ItemPR;
  final int Item;
  final int Ttra;
  double Kilos;
  int Jabas;
  int Unidades;
  int nEstado = 1;
  int nTipoBalanza = 0;
  final int Tipo;
  RepesoItem(this.Pedido,this.NumeroReparto, this.Item, this.LoteNumero,this.NumeroPR,this.ItemPR, this.Kilos, this.Jabas,this.Unidades,this.Tipo,this.Ttra);

  RepesoItem.fromJson(Map<String, dynamic> json)
      : Pedido = json["Pedido"],
        Tipo = json["Tipo"],
        Ttra = json["Ttra"],
        NumeroReparto = json["Numero"],
        Item = json["Item"],
        LoteNumero = json["LoteNumero"],
        NumeroPR = json["NumeroPR"],
        ItemPR = json["ItemPR"],
        Kilos = json["Kilos"],
        Jabas = json["Jabas"],
        Unidades = json["Unidades"],
        nEstado = json["nEstado"];

  Map<String, dynamic> toJson() => {
    "Pedido": Pedido,
    "Numero": NumeroReparto,
    "Item": Item,
    "LoteNumero": LoteNumero,
    "Kilos": Kilos,
    "Jabas": Jabas,
    "Unidades": Unidades,
    "nEstado": nEstado
  };
}
