
import 'package:pollovivoapp/model/pesaje_detalle_item.dart';
import 'package:pollovivoapp/model/solicitud_devolucion.dart';

class SolicitudResponse {
  final List<SolicitudDevolucion> solicitudes;
  final List<PesajeDetalleItem> repesos;

  const SolicitudResponse({this.solicitudes, this.repesos});

  SolicitudResponse.fromJson(Map<String, dynamic> json):
    this.solicitudes = List<SolicitudDevolucion>.from( json["Cabecera"].map( (json) => SolicitudDevolucion.fromJson(json) ) ).toList(),
    this.repesos = List<PesajeDetalleItem>.from( json["Detalle"].map( (json) => PesajeDetalleItem.fromJson(json) ) ).toList();
}