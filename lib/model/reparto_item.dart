class RepartoItem {
  int numeroReparto;
  final int item;
  final int loteNumero;
  final String rumas;
  final int jabas;
  final int unidades;
  int disponible;
  bool nuevo = false;
  //List<int> Rumas= List();
  RepartoItem(this.numeroReparto, this.item, this.loteNumero, this.rumas, this.jabas,this.unidades);

  RepartoItem clone(){
    RepartoItem clon = new RepartoItem(this.numeroReparto, this.item, this.loteNumero, this.rumas, this.jabas, this.unidades);
    clon.disponible = this.disponible;
    clon.nuevo = this.nuevo;
    return clon;
  }

  RepartoItem.fromJson(Map<String, dynamic> json)
      : numeroReparto = json["Numero"],
        item = json["Item"],
        loteNumero = json["LoteNumero"],
        rumas = json["Rumas"],
        jabas = json["Jabas"],
        unidades = json["Unidades"],
        disponible = json["Disponible"];

  Map<String, dynamic> toJson() => {
    "Numero": numeroReparto,
    "Item": item,
    "LoteNumero": loteNumero,
    "Rumas": rumas,
    "Jabas": jabas,
    "Unidades": unidades,
    "Nuevo": nuevo
  };
}
