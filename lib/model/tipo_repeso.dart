class TipoRepeso {
  final int codigo;
  String nombre;

  TipoRepeso(this.codigo, this.nombre);

  TipoRepeso.fromJson(Map<String, dynamic> json)
      : codigo = json["Codigo"],
        nombre = json["Nombre"];

  @override
  String toString() {
    return this.nombre.trim();
  }
}
