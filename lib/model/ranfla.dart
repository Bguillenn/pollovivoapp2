import 'package:flutter/material.dart';
import 'package:collection/equality.dart';

class Ranfla {
  final int lotePrincipal;
  final int viaje;
  final String placa;
  final List<int> lotes;
  int disponible = 0;

  Ranfla(this.lotePrincipal, this.viaje,this.placa, this.lotes);

  void addDisponible(int add){
    this.disponible += add;
  }

  bool sinUnidadesNegativo(){
    return this.disponible <= 0 ;
  }

  bool sinUnidades(){
    return this.disponible == 0 ;
  }

  Color color(){
    if(sinUnidadesNegativo()) return Colors.red[900];
    else return Colors.green[900];
  }

  String formatLote(){
    String lotes = "";
    if(this.lotes != null  && this.lotes.length > 0 ){
      lotes += "[";
      this.lotes.sort((a,b)=>a-b);
      for(int i in this.lotes){
        lotes += "$i,";
      }
      lotes = lotes.substring(0,lotes.length-1)+"]";
    }
    return lotes;
  }

  @override
  String toString() {

    return "Lote Ranfla: "+ formatLote() + "  "+ this.placa.trim() + "  Und:" +this.disponible.toString();
  }

  bool equals(Ranfla ranfla) {
    Function eq = const ListEquality().equals;
    return this.placa == ranfla.placa &&
          this.viaje == ranfla.viaje &&
          this.lotePrincipal == ranfla.lotePrincipal &&
          eq(this.lotes, ranfla.lotes) &&
          this.disponible == ranfla.disponible;
  }
}
