
import 'package:pollovivoapp/model/cliente.dart';

class GrupoCliente {
  final int nCodigo;
  final String cNombre;
  final bool lEsGrupo;
  List<Cliente> oClientes;

  GrupoCliente(this.nCodigo, this.cNombre, this.lEsGrupo);

  GrupoCliente.fromJson(Map<String, dynamic> json)
      : this.nCodigo = json["Codigo"],
        this.cNombre = json["Nombre"].trim(),
        this.lEsGrupo = json["EsGrupo"],
        this.oClientes = List.empty(growable: true);

  @override
  String toString() {
    return '${this.nCodigo} - ${this.cNombre}';
  }
}
