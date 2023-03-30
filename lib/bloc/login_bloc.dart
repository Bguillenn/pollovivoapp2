import 'package:flutter/material.dart';
import 'package:pollovivoapp/balanza/bloc/balanza_bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'package:pollovivoapp/LocalDB/dbPesaje.dart';
import 'package:pollovivoapp/model/login_request.dart';
import 'package:pollovivoapp/model/login_response.dart';
import 'package:pollovivoapp/model/usuario_sesion.dart';
import 'package:pollovivoapp/repository/login_repository.dart';

class LoginBloc {
  final loginRepository = LoginRepository();
  final loginFetcher = PublishSubject<LoginResponse>();
  final loginFetcherData = BehaviorSubject<Future<LoginResponse>>();
  final request = PublishSubject<LoginRequest>();
  final dbLocalsave = DBLocal();

  bool online = true;
  String impresora = '';

  final List colors = [
    Colors.red[700],
    Colors.green[700],
    Colors.blue[800],
    Colors.blueGrey,
    Colors.orange,
    Colors.brown,
    Colors.yellow[700],
    Colors.black54,
    Colors.teal,
    Colors.purple,
    Colors.red[900],
    Colors.green[900],
    Colors.blue[900],
    Colors.blueGrey[500],
    Colors.orange[500],
    Colors.brown[500],
    Colors.yellow[500],
    Colors.black54,
    Colors.teal[500],
    Colors.purple[500]
  ];

  Stream<LoginResponse> get loginResponse => loginFetcher.stream;
  Function(LoginRequest) get fetchLoginRequest => request.sink.add;

  Stream<Future<LoginResponse>> get loginResponse2 => loginFetcherData.stream;

  Future<LoginResponse> fetchDataLogin(LoginRequest request) async {
    LoginResponse loginResponse =
        await loginRepository.fetchDataLogin(request.usuario, request.password);
    balanzaBloc.AvailableManual =
        loginResponse.loginData.dataUsuario.balanzaManual;
    return loginResponse;
  }

  Future<UsuarioSesion> isLogged() async {
    // await dbLocalsave.deleteDB();
    await dbLocalsave.createDb2();
    return await dbLocalsave.getSession();
  }

  Future<int> deleteDB() async {
    await dbLocalsave.deleteDB();
    return 1;
  }

  Future<int> cleanImpresora() async {
    await dbLocalsave.cleanImpresora();
    return 1;
  }

  Future<String> getPrintServer() async {
    await dbLocalsave.createDb2();
    return await dbLocalsave.getPrintServer();
  }

  Future<String> addPrintServer(String imp) async {
    await dbLocalsave.addImpresora(imp);
  }

  Future<String> addSession(String username, String cookie) async {
    await dbLocalsave.addSession(username, cookie);
  }

  Future<String> closeSession() async {
    await dbLocalsave.cerrarSesion();
  }

  Future<bool> conexion(bool show) async {
    bool loginResponse = await loginRepository.conexion(show);
    return loginResponse;
  }

  dispose() {
    loginFetcher.close();
    request.close();
    loginFetcherData.close();
  }
}

final loginBloc = LoginBloc();
