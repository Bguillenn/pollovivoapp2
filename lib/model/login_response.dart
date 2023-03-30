import 'package:pollovivoapp/model/login_data.dart';

class LoginResponse {
  final String cMensaje;
  final String cMsjError;
  final int nCodError;
  final LoginData loginData;

  LoginResponse(this.cMensaje, this.cMsjError, this.nCodError, this.loginData);

  LoginResponse.fromJson(Map<String, dynamic> json)
      : cMensaje = json['cMensaje'],
        cMsjError = json['cMsjError'],
        nCodError = json['nCodError'],
        loginData = json['oContenido'] != null
            ? LoginData.fromJson(json['oContenido'])
            : LoginData.empty();
}
