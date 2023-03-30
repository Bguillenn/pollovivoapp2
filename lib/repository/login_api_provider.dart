import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pollovivoapp/bloc/login_bloc.dart';
import 'package:pollovivoapp/model/login_response.dart';

class LoginApiProvider {
  //static const String baseUrl='http://appricopollo.com/WCF_Ventas/ServiceVentas.svc';    //URL Produccion
  static const String BASE_URL =
      'http://10.82.1.30/WCF_Ventas/ServiceVentas.svc'; //URL Desarrollo (Cambiar IP por el de su maquina)

  //Singleton
  static final LoginApiProvider _instance = LoginApiProvider._internal();
  factory LoginApiProvider() => _instance;

  Dio _dio;
  String aToken = '';

  final BaseOptions options = new BaseOptions(
    baseUrl: BASE_URL,
    connectTimeout: 15000,
    receiveTimeout: 13000,
  );

  LoginApiProvider._internal() {
    _dio = Dio(options);
  }

  Future<LoginResponse> fetchDataLogin(String usuario, String password) async {
    try {
      final response = await _dio.post("/iniciarPost",
          data: {'tcUsuario': usuario, 'tcPassword': password});
      this._setCookies(response, usuario);

      //Validamos la respuesta
      if (response.statusCode == 200)
        return LoginResponse.fromJson(response.data);
      else
        throw Exception('No se pudo cargar los datos del usuario');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> conexion(bool show) async {
    // ?? Utilizadad desconocida
    if (kIsWeb) {
      loginBloc.online = true;
      return true;
    }

    try {
      //final result = await InternetAddress.lookup('appricopollo.com');  //URL Produccion
      final result = await InternetAddress.lookup(
          '10.82.1.30'); //URL Desarrollo (Reemplazar por IP de su maquina)
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        loginBloc.online = true;
        return true;
      } else
        return false;
    } on SocketException catch (_) {
      if (show)
        Fluttertoast.showToast(
            msg:
                "No se pudo establecer conexion con el servidor, verifica tu conexion a internet",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      loginBloc.online = false;
      return false;
    }
  }

  void _setCookies(Response response, String usuario) {
    final cookies = response.headers.map['set-cookie'];
    if (cookies != null && cookies.isNotEmpty) {
      final authToken = cookies[0]
          .split(';')[0]; //Depende de la manera de enviar del servidor
      this.aToken =
          authToken; //Guardando el token para realizar peticiones futuras
      loginBloc.addSession(usuario, authToken);
    }
  }
}
