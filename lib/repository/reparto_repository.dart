import 'package:pollovivoapp/model/reparto_buscar.dart';
import 'package:pollovivoapp/model/reparto_buscar_response.dart';
import 'package:pollovivoapp/model/reparto_header.dart';
import 'package:pollovivoapp/model/reparto_response.dart';
import 'package:pollovivoapp/model/reparto_save_request.dart';
import 'package:pollovivoapp/model/repartos_response.dart';
import 'package:pollovivoapp/model/save_request.dart';
import 'package:pollovivoapp/model/save_response.dart';
import 'package:pollovivoapp/repository/reparto_api_provider.dart';

class RepartoRepository {
  RepartoApiProvider repartoApiProvider = RepartoApiProvider();

  Future<RepartosResponse> getdataRepartos(int puntoVenta) =>
      repartoApiProvider.getdataRepartos(puntoVenta);

  Future<RepartoResponse> saveDataReparto(RepartoSaveRequest request) =>
      repartoApiProvider.saveDataReparto(request);

  Future<RepartoResponse> deleteDataReparto(int puntoVenta,int numero) =>
      repartoApiProvider.deleteDataReparto(puntoVenta,numero);

  Future<RepartoResponse> closeReparto(int puntoVenta,int numero) =>
      repartoApiProvider.closeReparto(puntoVenta,numero);

  Future<RepartoResponse> actualizarEstadoReparto(int puntoVenta,int numero,bool estado) =>
      repartoApiProvider.actualizarEstadoReparto(puntoVenta,numero,estado);

  Future<int> cerrarPedido(int puntoVenta,int numeroPedido) =>
      repartoApiProvider.cerrarPedido(puntoVenta,numeroPedido);

  Future<RepartoBuscarResponse> listarReparto(RepartoBuscar obj) =>
      repartoApiProvider.getdataRepartosBucar(obj);

}