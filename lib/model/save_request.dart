import 'package:pollovivoapp/model/pesaje_detalle_item.dart';
import 'package:pollovivoapp/model/save_request_cab.dart';

class SaveRequest {
  final SaveRequestCab oCabecera;
  List<PesajeDetalleItem> oDetalle;

   SaveRequest(this.oCabecera, this.oDetalle);

  SaveRequest.fromJson(Map<String, dynamic> json) : oCabecera = json["oCabecera"], oDetalle = List<PesajeDetalleItem>.from(
            json["oDetalle"].map((item) => PesajeDetalleItem.fromJson(item)));

  Map<String, dynamic> toJson() => {
        "oCabecera": oCabecera.toJson2(),
        "oDetalle": oDetalle.map((item) => item.toJson()).toList(),
      };
}
