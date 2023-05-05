import 'package:pollovivoapp/model/cliente.dart';
import 'package:pollovivoapp/model/data_Response.dart';
import 'package:pollovivoapp/model/factura_pedido.dart';
import 'package:pollovivoapp/model/pedido_buscar.dart';
import 'package:pollovivoapp/model/pedido_cliente.dart';
import 'package:pollovivoapp/model/pedido_response.dart';
import 'package:pollovivoapp/model/ranfla.dart';
import 'package:pollovivoapp/model/reparto_response.dart';
import 'package:pollovivoapp/model/reporte_ranfla_response.dart';
import 'package:pollovivoapp/model/save_request.dart';
import 'package:pollovivoapp/model/save_request_cab.dart';
import 'package:pollovivoapp/model/save_request_solicitud.dart';
import 'package:pollovivoapp/model/save_response.dart';
import 'package:pollovivoapp/model/solicitud_devolucion.dart';
import 'package:pollovivoapp/model/solicitud_response.dart';
import 'package:pollovivoapp/repository/pedido_api_provider.dart';
import 'package:pollovivoapp/model/login_response.dart';

class PedidoRepository {
  PedidoApiProvider pedidoApiProvider = PedidoApiProvider();

  Future<PedidoResponse> fetchDataPedido(int puntoVenta, int cliente, int tipo) =>
      pedidoApiProvider.fetchDataPedido(puntoVenta, cliente, tipo);

  Future<PedidoDetalleResponse> fetchDataPedidoDetalle(int puntoVenta, int pedido) =>
      pedidoApiProvider.fetchDataPedidoDetalle(puntoVenta, pedido);

  Future<SaveReponse> saveDataPesajes(SaveRequest request) =>
      pedidoApiProvider.saveDataPesajes(request);

  Future<RepartoResponse> updateDataPesajes(SaveRequest request) =>
      pedidoApiProvider.updateDataPesajes(request);

  Future<DataResponse> getReportPesadas(PuntoVenta, Cliente, Tipo, Fecha) =>
      pedidoApiProvider.getReportPesadas(PuntoVenta, Cliente, Tipo, Fecha);
 /* Future<List<SaveRequestCab>> revisarDatosErroneos(List<SaveRequestCab> request) =>
      pedidoApiProvider.revisarDatosErroneos(request);*/

  Future<PedidoEstadoBuscarResponse> getDataPedidosBucar(PedidoEstadoBuscar obj)  =>
      pedidoApiProvider.getDataPedidosBucar(obj);

  Future<int> actualizarPedido(int puntoVenta,int numeroPedido,int estado)   =>
      pedidoApiProvider.actualizarPedido(puntoVenta, numeroPedido, estado);


  Future<LoginResponse> fetchActualizar(String usuario) =>
      pedidoApiProvider.fetchActualizar(usuario);

  Future<int> imprimirControlPesos(String PuntoVenta,String Pedido) =>
      pedidoApiProvider.fetchImprimirControlPesos(PuntoVenta,Pedido);

  Future<int> imprimirPesada(String PuntoVenta,String Pesada) =>
      pedidoApiProvider.fetchImprimirPesada(PuntoVenta,Pesada);

  Future<List<Cliente>> getTestaferros(String PuntoVenta,String Pedido) =>
      pedidoApiProvider.getTestaferros(PuntoVenta,Pedido);

  Future<List<PedidoCliente>> getPedidoTestaferros(String PuntoVenta,String Pedido) =>
      pedidoApiProvider.getPedidoTestaferros(PuntoVenta,Pedido);

  Future<int> cerrarTodosPedidos(String PuntoVenta) =>
      pedidoApiProvider.cerrarTodosPedidos(PuntoVenta);

  Future<ReporteRanflaResponse> obtenerReporteDeRanflas(String puntoVenta, DateTime fecha) =>
      pedidoApiProvider.obtenerReporteDeRanflas(puntoVenta, fecha);

  Future<List<EstadoPedido>> obtenerPedidosConFacturacion(String nPuntoVenta, String sPedidos) =>
    pedidoApiProvider.obtenerPedidosConFacturacion(nPuntoVenta, sPedidos);
  
  Future<List<FacturaPedido>> obtenerFacturasPedido(String nPuntoVenta, int nPedido) =>
    pedidoApiProvider.obtenerFacturasPedido(nPuntoVenta, nPedido);

  Future<SolicitudDevolucion> saveSolicitudDevolucion(SaveRequestSolicitud request) =>
    pedidoApiProvider.saveSolicitudDevolucion(request);

  Future<SolicitudResponse> obtenerSolicitudesDevolucion(int puntoVenta) =>
    pedidoApiProvider.obtenerSolicitudesDevolucion(puntoVenta);

  Future<SolicitudDevolucion> eliminarSolicitudDevolucion(SolicitudDevolucion solicitud) =>
    pedidoApiProvider.eliminarSolicitudDevolucion(solicitud);
}
