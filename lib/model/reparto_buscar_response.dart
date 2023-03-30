import 'package:pollovivoapp/model/reparto_data.dart';
import 'package:pollovivoapp/model/reparto_header.dart';

class RepartoBuscarResponse {
  final String cMensaje;
  final String cMsjError;
  final int nCodError;
  final List<RepartoCabecera> Repartos;

  RepartoBuscarResponse(
      this.cMensaje, this.cMsjError, this.nCodError, this.Repartos);

  RepartoBuscarResponse.fromJson(Map<String, dynamic> json)
      : cMensaje = json['cMensaje'],
        cMsjError = json['cMsjError'],
        nCodError = json['nCodError'],
        Repartos = List<RepartoCabecera>.from(
            json['oContenido'].map((reparto) => RepartoCabecera.fromJson(reparto)));
}
