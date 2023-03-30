import 'package:pollovivoapp/model/reparto_buscar.dart';
import 'package:pollovivoapp/model/reparto_buscar_response.dart';
import 'package:pollovivoapp/model/reparto_header.dart';
import 'package:pollovivoapp/model/reparto_response.dart';
import 'package:pollovivoapp/model/reparto_save_request.dart';
import 'package:pollovivoapp/model/repartos_response.dart';
import 'package:pollovivoapp/model/save_request.dart';
import 'package:pollovivoapp/model/save_response.dart';
import 'package:pollovivoapp/repository/reparto_repository.dart';
import 'package:rxdart/rxdart.dart';

class RepartoBloc {
  final repartoRepository = RepartoRepository();

  //Código para grabar RepartoRequest
  final request = PublishSubject<int>();
  final repartoFetcherData = BehaviorSubject<Future<RepartosResponse>>();

  Function(int) get fetchRepartoRequest => request.sink.add;

  Stream<Future<RepartosResponse>> get repartoResponse => repartoFetcherData.stream;

  Future<int> cerrarPedido(int puntoVenta,int numeroPedido) async {
    int response_ = await repartoRepository.cerrarPedido(puntoVenta,numeroPedido);
    return response_;
  }

  Future<RepartosResponse> getdataRepartos(int puntoVenta) async {
    RepartosResponse repartoResponse = await repartoRepository.getdataRepartos(puntoVenta);
    return repartoResponse;
  }

  Future<RepartoResponse> deleteDataReparto(int puntoVenta,int nmero) async {
    RepartoResponse repartoResponse = await repartoRepository.deleteDataReparto(puntoVenta,nmero);
    return repartoResponse;
  }

  Future<RepartoResponse> closeReparto(int puntoVenta,int nmero) async {
    RepartoResponse repartoResponse = await repartoRepository.closeReparto(puntoVenta,nmero);
    return repartoResponse;
  }

  Future<RepartoResponse> actualizarEstadoReparto(int puntoVenta,int numero,bool estado) async {
    RepartoResponse repartoResponse = await repartoRepository.actualizarEstadoReparto(puntoVenta,numero,estado);
    return repartoResponse;
  }

  Future<RepartoBuscarResponse> listarReparto(RepartoBuscar obj ) async {
    RepartoBuscarResponse repartoResponse = await repartoRepository.listarReparto(obj);
    return repartoResponse;
  }

  disposeReparto() {
    request.close();
    repartoFetcherData.close();
  }

  //Código para grabar SaveRequest
  final saveRequest = PublishSubject<RepartoSaveRequest>();
  final saveFetcherData = BehaviorSubject<Future<RepartoResponse>>();

  Function(RepartoSaveRequest) get fetchSaveRequest => saveRequest.sink.add;
  Stream<Future<RepartoResponse>> get saveResponse => saveFetcherData.stream;

  Future<RepartoResponse> saveDataReparto(RepartoSaveRequest request) async {
    RepartoResponse saveReponse = await repartoRepository.saveDataReparto(request);
    return saveReponse;
  }
}

final repartoBloc = RepartoBloc();
