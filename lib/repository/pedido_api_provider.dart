import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:pollovivoapp/bloc/login_bloc.dart';
import 'package:pollovivoapp/model/cliente.dart';
import 'package:pollovivoapp/model/data_Response.dart';
import 'package:pollovivoapp/model/pedido_buscar.dart';
import 'package:pollovivoapp/model/pedido_cliente.dart';
import 'package:pollovivoapp/model/pedido_response.dart';
import 'package:pollovivoapp/model/reparto_response.dart';
import 'package:pollovivoapp/model/reporte_ranfla_response.dart';
import 'package:pollovivoapp/model/save_request.dart';
import 'package:pollovivoapp/model/save_request_cab.dart';
import 'package:pollovivoapp/model/save_response.dart';
import 'package:pollovivoapp/model/shared_pref.dart';
import 'package:pollovivoapp/util/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pollovivoapp/model/login_response.dart';

class PedidoApiProvider {
  Dio _dio;
  static final PedidoApiProvider _instance = PedidoApiProvider._internal();
  factory PedidoApiProvider() => _instance;

  PedidoApiProvider._internal() {
    _dio = Dio(loginBloc.loginRepository.loginApiProvider.options);
    _dio.interceptors.add(InterceptorsWrapper(
        onRequest:(options, handler){
          _dio.interceptors.requestLock.lock();
          options.headers["cookie"] = loginBloc.loginRepository.loginApiProvider.aToken;
          _dio.interceptors.requestLock.unlock();
          return handler.next(options); //continue
        },
        onResponse:(response,handler) {
          return handler.next(response); // continue
        },
        onError: (DioError e, handler) async {
          String Error="";
          if(e.message != null) Error = e.message;

          if(e.response != null ){
            if(e.response.data != null && e.response.data!="") Error = e.response.data;
            else Error= e.response.statusMessage;
          }
          print(Error);
          e.response.data= new SaveReponse(null,Error, Error, 3);
          return handler.resolve(e.response);
          // If you want to resolve the request with some custom data，
          // you can resolve a `Response` object eg: return `dio.resolve(response)`.
        }
    ));
  }

  Future<PedidoResponse> fetchDataPedido(int puntoVenta, int cliente, int tipo) async {
    Response response = await _dio.get("/TraerDatosPedidoRepesoExtendido?nPuntoVenta=${puntoVenta}&nCliente=${cliente}&nTipo=${tipo}");
    print(response.data);

    if (response.statusCode == 200) {
      return PedidoResponse.fromJson(response.data);
    } else {
      throw Exception('no se puede cargar datos de pedido');
    }
  }


  Future<PedidoDetalleResponse> fetchDataPedidoDetalle(int puntoVenta, int pedido) async {
    Response response = await _dio.get("/DetallePedido?nPuntoVenta=${puntoVenta}&nPedido=${pedido}");
    print(response.data);

    if (response.statusCode == 200) {
      return PedidoDetalleResponse.fromJson(response.data);
    } else {
      throw Exception('no se puede cargar datos de pedido');
    }
  }

  Future<SaveReponse> saveDataPesajes(SaveRequest request) async {
    String requestJson = jsonEncode(request.toJson());
    Response response = await _dio.post("/GrabarRepeso",  data: requestJson);
    print(response.data);
    if (response.statusCode == 200) {
      return SaveReponse.fromJson(response.data);
    } else {
     return response.data;
    }
  }
  Future<RepartoResponse> updateDataPesajes(SaveRequest request) async {
    try{
      String requestJson = jsonEncode(request.toJson());
      print(requestJson);
      Response response = await _dio.post("/ActualizarRepeso",  data: requestJson);

      if (response.statusCode == 200) {
        return RepartoResponse.fromJson(response.data);
      } else {
        throw Exception('no se puede Actualizar ...');
      }
    }catch(e){
      var a = 01;
      throw e;
    }

  }

  Future<DataResponse> getReportPesadas(int PuntoVenta, int Cliente, int Tipo, String Fecha) async {
    Response response = await _dio.get("/getFilePesadas?nPuntoVenta=$PuntoVenta&nCliente=$Cliente&nTipo=$Tipo&dFecha=$Fecha");
    print(response.data);

    if (response.statusCode == 200) {
      return DataResponse.fromJson(response.data);
    } else {
      throw Exception('no se puede cargar datos de pedido');
    }
  }
  /*Future<List<SaveRequestCab>> revisarDatosErroneos(List<SaveRequestCab> lista) async {
    String requestJson = jsonEncode(lista.map((e) => e.toJson()).toString());
    Response response = await _dio.post("/revisarDatosErroneos",data:requestJson);
    print(response.data);
    if (response.statusCode == 200) {
      return List<SaveRequestCab>.from(response.data.map((cabecera) => SaveRequestCab.fromJson2(cabecera)));
    } else {
      throw Exception('no se puede cargar datos de pedido');
    }
  }*/
  Future<LoginResponse> fetchActualizar(String usuario) async {

    final response = await _dio.get('/actualizar?cUsu=${usuario}');

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(response.data);
    } else {
      throw Exception('no se puede cargar datos de usuario');
    }
    //}
  }

  Future<int> actualizarPedido(int puntoVenta,int numeroPedido,int estado) async {

    Response response = await _dio.get("/ActualizarEstadoPedido?nPuntoVenta=${puntoVenta}&numero=${numeroPedido}&estado=${estado}");
    print(response.data);
    if (response.statusCode == 200) {
      return 1;
    } else {
      throw Exception('no se puede cargar datos de pedido');
    }
  }

  Future<PedidoEstadoBuscarResponse> getDataPedidosBucar(PedidoEstadoBuscar obj) async {
    PedidoBuscarRequest objRBR = PedidoBuscarRequest(obj);
    String strObj = jsonEncode(objRBR.toJson());
    try {
      Response response = await _dio.post("/ListarEstadoPedido", data: strObj);
      print(response.data);
      if (response.statusCode == 200) {
        return PedidoEstadoBuscarResponse.fromJson(response.data);
      } else {
        throw Exception('no se puede cargar datos de pedido');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<int> fetchImprimirControlPesos(String PuntoVenta,String Pedido) async {
    print("ingresooo");

    //final response = await _dio.get('/ImprimirPedido?nPuntoVenta=${PuntoVenta}&numero=${Pedido}&impresora=\\\\printserver\\HPLJ_M527_Administracion');
    //final response = await _dio.get('/ImprimirPedido?nPuntoVenta=${PuntoVenta}&numero=${Pedido}&impresora=\\\\printserver\\KONICA MINOLTA 252');
    final response = await _dio.get('/ImprimirPedido?nPuntoVenta=${PuntoVenta}&numero=${Pedido}&impresora=${loginBloc.impresora}');
    if (response.statusCode == 200) {
      return response.data["oContenido"];
      return 1;
    } else {
      throw Exception('no se pudo imprimir');
    }
    print("salidaaaa");

  }

  Future<int> fetchImprimirPesada(String PuntoVenta,String Pesada) async {
    print("ingresooo");

    //final response = await _dio.get('/ImprimirPedido?nPuntoVenta=${PuntoVenta}&numero=${Pedido}&impresora=\\\\printserver\\HPLJ_M527_Administracion');
    //final response = await _dio.get('/ImprimirPedido?nPuntoVenta=${PuntoVenta}&numero=${Pedido}&impresora=\\\\printserver\\KONICA MINOLTA 252');
    final response = await _dio.get('/ImprimirPesada?nPuntoVenta=${PuntoVenta}&numeroPesada=${Pesada}&impresora=${loginBloc.impresora}');
    if (response.statusCode == 200) {
      return response.data["oContenido"];
      return 1;
    } else {
      throw Exception('no se pudo imprimir');
    }
    print("salidaaaa");

  }

  Future<List<Cliente> > getTestaferros(String PuntoVenta,String cliente) async{
    List<Cliente> objRBR = new List<Cliente>.empty(growable: true);
    try {
      Response response = await _dio.get("/MostrarTestaferros?nPuntoVenta=${PuntoVenta}&nCliente=${cliente}");
      if (response.statusCode == 200 && response.data["nCodError"]==0) {
        return List<Cliente>.from(response.data["oContenido"].map((obj) => Cliente.fromJson(obj)));
      } else {
        throw Exception('No se puede traer datos de testaferros');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List<PedidoCliente> > getPedidoTestaferros(String PuntoVenta,String Pedido) async{
    List<PedidoCliente> objRBR = new List<PedidoCliente>();
    try {
      Response response = await _dio.get("/MostrarCabeseraPeidos?nPuntoVenta=${PuntoVenta}&nCliente=${Pedido}");
      print(response.data);
      if (response.statusCode == 200 && response.data["nCodError"]==0) {
        return List<PedidoCliente>.from(response.data["oContenido"].map((obj) => PedidoCliente.fromJson(obj)));
      } else {
        throw Exception('no se puede cargar datos de pedido');
      }
    } catch (e) {
      print(e);
      throw e;
    }
  }


  Future<int> cerrarTodosPedidos(String PuntoVenta) async{
    List<PedidoCliente> objRBR = new List<PedidoCliente>();
    try {
      Response response = await _dio.get("/CerrarTodosPedidos?nPuntoVenta=${PuntoVenta}");
      print(response.data);
      if (response.statusCode == 200 && response.data["nCodError"]==0) {
        return response.data["oContenido"];
      } else {
        throw Exception('no se puede cargar datos de pedido');
      }
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<ReporteRanflaResponse> obtenerReporteDeRanflas(String puntoVenta, DateTime fecha) async {
    try{
      String json = jsonEncode({
        "tnPuntoVenta": puntoVenta,
        "tdFecha": DateTimeToWCF(fecha),//Hasta.toIso8601String(),
      });


      Response response = await _dio.post("/PesadasPorLotes", data: json);
      if(response.statusCode == 200 && response.data["nCodError"] == 0) {
        return ReporteRanflaResponse.fromJson(response.data["oContenido"]);
      }else {
        throw Exception("No se puede obtener los pesajes de las ranflas");
      }
    }catch(e) {
      print("[ERROR] ObtenerReporteDeRanflas : ${e.toString()}");
      throw e;
    }
  }
}
