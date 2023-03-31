
import 'package:pollovivoapp/model/cliente.dart';
import 'package:pollovivoapp/model/pesada.dart';

class ReporteRanflaResponse {

  final List<Cliente> oClientes;
  final List<Pesada> oPesadas;

  ReporteRanflaResponse(this.oClientes, this.oPesadas);

  ReporteRanflaResponse.fromJson(Map<String, dynamic> json):
    this.oClientes = json["Cabecera"]
                    .map<Cliente>((jsonCliente) => Cliente.fromJson(jsonCliente)).toList(),
    this.oPesadas = json["Detalle"]
                    .map<Pesada>( (jsonPesada) => Pesada.fromJson(jsonPesada)).toList();

}