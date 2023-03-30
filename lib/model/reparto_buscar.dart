
import 'package:pollovivoapp/util/utils.dart';

class RepartoBuscarRequest {
  RepartoBuscar response;
  RepartoBuscarRequest(this.response);
  Map<String, dynamic> toJson() => {
    "response": response.toJson()
  };

}


class RepartoBuscar {
  int PuntoVenta;
  int Vehiculo;
  DateTime Desde;
  DateTime Hasta;
  RepartoBuscar(this.PuntoVenta,this.Vehiculo,this.Desde,this.Hasta);


  Map<String, dynamic> toJson() => {
    "PuntoVenta": PuntoVenta,
    "Vehiculo": Vehiculo,
    "Desde": DateTimeToWCF(Desde),//Desde.toIso8601String(),
    "Hasta": DateTimeToWCF(Hasta),//Hasta.toIso8601String(),
  };
}

