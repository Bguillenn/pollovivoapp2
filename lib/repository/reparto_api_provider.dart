import 'dart:convert';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:pollovivoapp/bloc/login_bloc.dart';
import 'package:pollovivoapp/model/reparto_buscar.dart';
import 'package:pollovivoapp/model/reparto_buscar_response.dart';
import 'package:pollovivoapp/model/reparto_response.dart';
import 'package:pollovivoapp/model/reparto_save_request.dart';
import 'package:pollovivoapp/model/repartos_response.dart';

class RepartoApiProvider {
  Dio _dio;
  var cookieJar=CookieJar();
  static final RepartoApiProvider _instance = RepartoApiProvider._internal();
  factory RepartoApiProvider() => _instance;

  RepartoApiProvider._internal() {
    _dio = Dio(loginBloc.loginRepository.loginApiProvider.options);
    _dio.interceptors.add(InterceptorsWrapper(
        onRequest:(options, handler){
          _dio.interceptors.requestLock.lock();
          options.headers["cookie"] = loginBloc.loginRepository.loginApiProvider.aToken;
          _dio.interceptors.requestLock.unlock();
          return handler.next(options); //continue
        },
       /* onResponse:(response,handler) {
          return handler.next(response.data); // continue
        },*/
    ));
  }


  Future<int> cerrarPedido(int puntoVenta,int numeroPedido) async {

    Response response = await _dio.get("/CerrarPedido?nPuntoVenta=${puntoVenta}&nNumeroPedido=${numeroPedido}");

    if (response.statusCode == 200) {
      return 1;
    } else {
      throw Exception('No se puede cargar datos de pedido');
    }
  }

  Future<RepartosResponse> getdataRepartos(int puntoVenta) async {

    Response response = await _dio.get("/TraerPreparacionReparto?nPuntoVenta=${puntoVenta}");

    if (response.statusCode == 200) {
      return RepartosResponse.fromJson(response.data);
    } else {
      throw Exception('No se puede cargar datos de reparto');
    }
  }

  Future<RepartoBuscarResponse> getdataRepartosBucar(RepartoBuscar obj) async {

    RepartoBuscarRequest objRBR = RepartoBuscarRequest(obj);
    String strObj = jsonEncode(objRBR.toJson());
    try {
      Response response = await _dio.post("/ListarRepartoBuscar",data:strObj);
      print(response.data);
      if (response.statusCode == 200) {
        return RepartoBuscarResponse.fromJson(response.data);
      } else {
        throw Exception('no se puede cargar datos de pedido');
      }

    } catch(e) {
      print(e);
    }

  }

  Future<RepartoResponse> saveDataReparto(RepartoSaveRequest request) async {
    String requestJson = jsonEncode(request.toJson());
    Response response = await _dio.post("/GrabarReparto", data: requestJson);
    print(response.data);

    if (response.statusCode == 200) {
      return RepartoResponse.fromJson(response.data);
    } else {
      var data = response;
      throw Exception('no se puede grabar ...');
    }
  }

  Future<RepartoResponse> closeReparto(int puntoVenta,int numeroReparto) async {
    Response response = await _dio.get("/CerrarReparto?nPuntoVenta=${puntoVenta}&numero=${numeroReparto}");
    print(response.data);
    if (response.statusCode == 200) {
      return RepartoResponse.fromJson(response.data);
    } else {
      var data = response;
      throw Exception('no se puede cerrar ...');
    }
  }

  Future<RepartoResponse> actualizarEstadoReparto(int puntoVenta,int numeroReparto,bool estado) async {
    Response response = await _dio.get("/ActualizarEstadoReparto?nPuntoVenta=${puntoVenta}&numero=${numeroReparto}&estado=${estado}");
    print(response.data);
    if (response.statusCode == 200) {
      return RepartoResponse.fromJson(response.data);
    } else {
      var data = response;
      throw Exception('no se puede cerrar ...');
    }
  }

  Future<RepartoResponse> deleteDataReparto(int puntoVenta,int numeroReparto) async {
    Response response = await _dio.get("/BorrarReparto?nPuntoVenta=${puntoVenta}&numero=${numeroReparto}");
    print(response.data);
    if (response.statusCode == 200) {
      return RepartoResponse.fromJson(response.data);
    } else {
      var data = response;
      throw Exception('no se puede grabar ...');
    }
  }
}
