class LoginRequest {
  String usuario;
  String password;

  LoginRequest(this.usuario, this.password);

  Map<String, dynamic> toJson() => {
        'usuario': usuario,
        'password': password,
      };

  LoginRequest.fromJson(Map<String, dynamic> json)
      : usuario = json['usuario'],
        password = json['password'];
}
