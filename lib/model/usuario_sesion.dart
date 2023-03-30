class UsuarioSesion {

  String Usuario;
  String Cookie;

  UsuarioSesion.fromJson(Map<String, dynamic> json)
      : Usuario = json["Usuario"],
        Cookie = json["Cookie"];

/*@override
  String toString() {
    return this.Numero.toString() + " - " + this.Placa.trim();
  }*/
}
