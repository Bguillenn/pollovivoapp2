import 'package:pollovivoapp/model/reparto_data.dart';

class RepartoResponse {
  final String cMensaje;
  final String cMsjError;
  final int nCodError;
  final int NumeroReparto;

  RepartoResponse(
      this.cMensaje, this.cMsjError, this.nCodError, this.NumeroReparto);

  RepartoResponse.fromJson(Map<String, dynamic> json)
      : cMensaje = json['cMensaje'],
        cMsjError = json['cMsjError'],
        nCodError = json['nCodError'],
        NumeroReparto = json['oContenido'];
}
