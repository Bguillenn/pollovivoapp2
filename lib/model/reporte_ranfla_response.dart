
import 'package:pollovivoapp/model/cliente.dart';
import 'package:pollovivoapp/model/lote.dart';
import 'package:pollovivoapp/model/pesada.dart';

class ReporteRanflaResponse {

  final List<Cliente> oClientes;
  final List<Pesada> oPesadas;
  final List<Lote> oLotes;

  ReporteRanflaResponse(this.oClientes, this.oPesadas, this.oLotes);

  ReporteRanflaResponse.fromJson(Map<String, dynamic> json):
    this.oClientes = json["Cabecera"]
                    .map<Cliente>((jsonCliente) => Cliente.fromJson(jsonCliente)).toList(),
    this.oPesadas = json["Detalle"]
                    .map<Pesada>( (jsonPesada) => Pesada.fromJson(jsonPesada)).toList(),
    this.oLotes = json["Detalle2"]
                    .map<Lote>( (jsonLote) => Lote.fromJson(jsonLote) ).toList();

}