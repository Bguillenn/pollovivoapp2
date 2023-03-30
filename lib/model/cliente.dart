import 'package:flutter/material.dart';
import 'package:pollovivoapp/model/tuple.dart';

class Cliente {
  final int codigo;
  final String nombre;
  final int grupo;
  List<Tuple> descuento;

  Cliente(this.codigo, this.nombre, this.grupo);

  Cliente.fromJson(Map<String, dynamic> json)
      : codigo = json["Codigo"],
        nombre = json["Nombre"],
        grupo = json["Grupo"],
        descuento = json['Descuento'] != null
            ? List<Tuple>.from(
                json['Descuento'].map((descuento) => Tuple.fromJson(descuento)))
            : List.empty();

  @override
  String toString() {
    return this.nombre.trim();
  }

  String toString2() {
    return this.codigo.toString() + " - " + this.nombre.trim();
  }
}
