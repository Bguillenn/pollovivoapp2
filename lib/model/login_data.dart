import 'package:pollovivoapp/model/cliente.dart';
import 'package:pollovivoapp/model/data_usuario.dart';
import 'package:pollovivoapp/model/grupo_cliente.dart';
import 'package:pollovivoapp/model/lote.dart';
import 'package:pollovivoapp/model/pedido_item.dart';
import 'package:pollovivoapp/model/tipo_repeso.dart';
import 'package:pollovivoapp/model/unidad_reparto.dart';

class LoginData {
  final DataUsuario dataUsuario;
  final List<GrupoCliente> gruposCliente;
  final List<Cliente> clientes;
  final List<PedidoItem> pedidos;
  final List<TipoRepeso> tiposRepeso;
  final List<UnidadReparto> vehiculos;
  final List<TipoRepeso> tiposDevolucion;
  final List<TipoRepeso> motivosDevolucion;
  List<String> motivos;
  List<Lote> lotes = List.empty(growable: true);

  LoginData(this.dataUsuario, this.gruposCliente ,this.clientes, this.pedidos, this.tiposRepeso,
      this.vehiculos, this.tiposDevolucion, this.motivosDevolucion);

  LoginData.empty()
      : this.dataUsuario = DataUsuario.empty(),
        this.gruposCliente = List.empty(),
        this.clientes = List.empty(),
        this.pedidos = List.empty(),
        this.tiposRepeso = List.empty(),
        this.vehiculos = List.empty(),
        this.tiposDevolucion = List.empty(),
        this.motivosDevolucion = List.empty();

  LoginData.fromJson(Map<String, dynamic> json)
      : this.dataUsuario = DataUsuario.fromJson(json['Cabecera']),
        this.clientes = List<Cliente>.from(
            json['Detalle'].map((cliente) => Cliente.fromJson(cliente))),
        this.gruposCliente = List<GrupoCliente>.from(
            json["Detalle2"].map((grupo) => GrupoCliente.fromJson(grupo))),
        this.pedidos = List<PedidoItem>.from(
            json['Detalle3'].map((pedido) => PedidoItem.fromJson(pedido))),
        this.tiposRepeso = List<TipoRepeso>.from(json['Detalle4']
            .map((tipoRepeso) => TipoRepeso.fromJson(tipoRepeso))),
        this.vehiculos = List<UnidadReparto>.from(
            json['Detalle5'].map((placa) => UnidadReparto.fromJson(placa))),
        this.tiposDevolucion = List<TipoRepeso>.from(json['Detalle6']
            .map((tipoRepeso) => TipoRepeso.fromJson(tipoRepeso))),
        this.motivosDevolucion = List<TipoRepeso>.from(json['Detalle7']
            .map((tipoRepeso) => TipoRepeso.fromJson(tipoRepeso))),
        this.motivos = List<String>.from(
            json['Detalle8'].map((motivo) => motivo.toString()));
}
