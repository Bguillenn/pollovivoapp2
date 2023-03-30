import 'package:pollovivoapp/model/reparto_header.dart';
import 'package:pollovivoapp/model/reparto_item.dart';

class RepartoSaveRequest {
  final RepartoCabecera oCabecera;
  final List<RepartoItem> oDetalle;

  RepartoSaveRequest(this.oCabecera, this.oDetalle);

  RepartoSaveRequest.fromJson(Map<String, dynamic> json) : oCabecera = json["oCabecera"], oDetalle = List<RepartoItem>.from(
      json["oDetalle"].map((item) => RepartoItem.fromJson(item)));

  Map<String, dynamic> toJson() => {
    "oCabecera": oCabecera.toJson(),
    "oDetalle": oDetalle.map((item) => item.toJson()).toList(),
  };
}
