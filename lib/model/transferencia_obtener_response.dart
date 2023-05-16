
import 'package:pollovivoapp/model/pesaje_detalle_item.dart';
import 'package:pollovivoapp/model/save_request_cab.dart';

class TransferenciaObtenerResponse {
  List<SaveRequestCab> repesosCabecera;
  List<PesajeDetalleItem> repesosDetalle;

  TransferenciaObtenerResponse({this.repesosCabecera, this.repesosDetalle});

  TransferenciaObtenerResponse.fromJson(Map<String, dynamic> json) :
    this.repesosCabecera = List.from( json["Cabecera"].map((json) => SaveRequestCab.fromJson(json)) ),
    this.repesosDetalle = List.from( json["Detalle"].map((json) => PesajeDetalleItem.fromJson2(json)) );
}