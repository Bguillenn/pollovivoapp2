import 'package:pollovivoapp/model/login_response.dart';
import 'package:pollovivoapp/repository/login_api_provider.dart';

class LoginRepository {
  LoginApiProvider loginApiProvider = LoginApiProvider();

  Future<LoginResponse> fetchDataLogin(String usuario, String password) =>
      loginApiProvider.fetchDataLogin(usuario, password);

  Future<bool> conexion(bool show) => loginApiProvider.conexion(show);
}
