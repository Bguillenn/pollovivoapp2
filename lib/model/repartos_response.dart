import 'package:pollovivoapp/model/reparto_data.dart';

class RepartosResponse {
  final String cMensaje;
  final String cMsjError;
  final int nCodError;
  final RepartoData repartoData;

  RepartosResponse(
      this.cMensaje, this.cMsjError, this.nCodError, this.repartoData);

  RepartosResponse.fromJson(Map<String, dynamic> json)
      : cMensaje = json['cMensaje'],
        cMsjError = json['cMsjError'],
        nCodError = json['nCodError'],
        repartoData = json['oContenido'] != null
            ? RepartoData.fromJson(json['oContenido'])
            : RepartoData(List(), List() ,List());
}
