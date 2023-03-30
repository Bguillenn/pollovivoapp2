import 'package:pollovivoapp/model/save_request_cab.dart';

class SaveReponse {
  final SaveRequestCab oContenido;
  final String cMensaje;
  final String cMsjError;
  final int nCodError;

  SaveReponse(this.oContenido,this.cMensaje, this.cMsjError, this.nCodError);

  SaveReponse.fromJson(Map<String, dynamic> json)
      : oContenido = json['oContenido']==null?null:SaveRequestCab.fromJson(json['oContenido']),
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
