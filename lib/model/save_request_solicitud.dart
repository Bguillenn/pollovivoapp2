import 'package:pollovivoapp/model/pesaje_detalle_item.dart';
import 'package:pollovivoapp/model/save_request_cab.dart';
import 'package:pollovivoapp/model/solicitud_devolucion.dart';

class SaveRequestSolicitud {
  final SaveRequestCab oCabecera;
  final SolicitudDevolucion oSolicitud;
  List<PesajeDetalleItem> oDetalle;

  SaveRequestSolicitud(this.oCabecera, this.oDetalle, this.oSolicitud);

  SaveRequestSolicitud.fromJson(Map<String, dynamic> json) : oCabecera = json["oCabecera"], oDetalle = List<PesajeDetalleItem>.from(
            json["oDetalle"].map((item) => PesajeDetalleItem.fromJson(item))), oSolicitud = json["oSolicitud"];

  Map<String, dynamic> toJson() => {
        "oCabecera": oCabecera.toJson2(),
        "oDetalle": oDetalle.map((item) => item.toJson()).toList(),
        "oSolicitud": oSolicitud.toJson(),
      };
}
