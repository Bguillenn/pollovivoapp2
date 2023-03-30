import 'package:pollovivoapp/model/reparto_header.dart';
import 'package:pollovivoapp/model/reparto_item.dart';

import 'lote.dart';

class RepartoData {
  final List<Lote> lotes;
  final List<RepartoCabecera> repartoCabeceras;
  final List<RepartoItem> repartoDetalles;

  RepartoData(this.lotes,this.repartoCabeceras, this.repartoDetalles);

  RepartoData.fromJson(Map<String, dynamic> json)
      : lotes = List<Lote>.from(json["Cabecera"]
      .map((cabecera) => Lote.fromJson(cabecera))),
        repartoCabeceras = List<RepartoCabecera>.from(json["Detalle"]
            .map((cabecera) => RepartoCabecera.fromJson(cabecera))),
        repartoDetalles = List<RepartoItem>.from(json["Detalle2"]
            .map((itemDetalle) => RepartoItem.fromJson(itemDetalle)));
}
