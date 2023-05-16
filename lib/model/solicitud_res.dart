import 'package:pollovivoapp/model/save_request_cab.dart';
import 'package:pollovivoapp/model/solicitud_devolucion.dart';

class SolicitudRes {
  final SolicitudDevolucion oContenido;
  final String cMensaje;
  final String cMsjError;
  final int nCodError;

  SolicitudRes(this.oContenido,this.cMensaje, this.cMsjError, this.nCodError);

  SolicitudRes.fromJson(Map<String, dynamic> json)
      : oContenido = json['oContenido']==null ? null:SolicitudDevolucion.fromJson(json['oContenido']),
        cMensaje = json['cMensaje'],
        cMsjError = json['cMsjError'],
        nCodError = json['nCodError'];

  Map<String, dynamic> toJson() => {
    "oContenido": oContenido.toJson(),
    "cMensaje": cMensaje,
    "cMsjError": cMsjError,
    "nCodError": nCodError
  };

}
