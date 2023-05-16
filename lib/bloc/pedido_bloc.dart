import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollovivoapp/LocalDB/dbPesaje.dart';
import 'package:pollovivoapp/balanza/bloc/balanza_bloc.dart';
import 'package:pollovivoapp/model/cliente.dart';
import 'package:pollovivoapp/model/data_Response.dart';
import 'package:pollovivoapp/model/factura_pedido.dart';
import 'package:pollovivoapp/model/lote.dart';
import 'package:pollovivoapp/model/pedido_buscar.dart';
import 'package:pollovivoapp/model/pedido_cliente.dart';
import 'package:pollovivoapp/model/pedido_request.dart';
import 'package:pollovivoapp/model/pedido_response.dart';
import 'package:pollovivoapp/model/pesaje_detalle_item.dart';
import 'package:pollovivoapp/model/ranfla.dart';
import 'package:pollovivoapp/model/reparto_response.dart';
import 'package:pollovivoapp/model/reporte_ranfla_response.dart';
import 'package:pollovivoapp/model/save_request.dart';
import 'package:pollovivoapp/model/save_request_cab.dart';
import 'package:pollovivoapp/model/save_request_solicitud.dart';
import 'package:pollovivoapp/model/save_response.dart';
import 'package:pollovivoapp/model/solicitud_devolucion.dart';
import 'package:pollovivoapp/model/solicitud_res.dart';
import 'package:pollovivoapp/model/solicitud_response.dart';
import 'package:pollovivoapp/model/transferencia_obtener_response.dart';
import 'package:pollovivoapp/repository/pedido_repository.dart';
import 'package:rxdart/rxdart.dart';

import 'dart:async';

import 'login_bloc.dart';

import 'package:pollovivoapp/model/login_response.dart';

class PedidoBloc {
  final pedidoRepository = PedidoRepository();
  final dbLocalsave = DBLocal();
  //Código para grabar PedidoRequest
  final request = PublishSubject<PedidoRequest>();
  final pedidoFetcherData = BehaviorSubject<Future<PedidoResponse>>();
  //String Dataname="DataLocal";
  //SharedPref saveLocal = new SharedPref();

  Function(PedidoRequest) get fetchPedidoRequest => request.sink.add;
  Stream<Future<PedidoResponse>> get pedidoResponse => pedidoFetcherData.stream;

  DBLocal getDbLocalSave() => dbLocalsave;

  // Open the database and store the reference.

  Future<PedidoResponse> fetchDataPedido(PedidoRequest request) async {
    PedidoResponse pedidoResponse = await pedidoRepository.fetchDataPedido(
        request.puntoVenta, request.cliente, request.tipo);

    return pedidoResponse;
  }

  Future<PedidoDetalleResponse> fetchDataPedidoDetalle(
      int puntoVenta, int pedido) async {
    PedidoDetalleResponse pedidoResponse =
        await pedidoRepository.fetchDataPedidoDetalle(puntoVenta, pedido);

    return pedidoResponse;
  }

  disposePedido() {
    request.close();
    pedidoFetcherData.close();
  }

  //Código para grabar SaveRequest
  final saveRequest = PublishSubject<SaveRequest>();
  final saveFetcherData = BehaviorSubject<Future<SaveReponse>>();

  Function(SaveRequest) get fetchSaveRequest => saveRequest.sink.add;

  Stream<Future<SaveReponse>> get saveResponse => saveFetcherData.stream;

  Future<SaveReponse> saveDataPesajes(SaveRequest request) async {
    await dbLocalsave.insertPesaje(request);
    request.oCabecera.Numero = 1;

    SaveReponse dataReturn = new SaveReponse(
        request.oCabecera, "Se ejecuto la operación con éxito.", "", 0);
    return dataReturn;
  }

  Future<bool> pendientes() async {
    List<SaveRequestCab> pendientes = await dbLocalsave.pesajesPendientes();
    return pendientes.length > 0;
  }

  Future<bool> saveDataChangue(bool show) async {
    List<SaveRequestCab> all = await dbLocalsave.pesajes();
    List<SaveRequestCab> pendientes = await dbLocalsave.pesajesPendientes();

    //* Pedido a Login BLOC
    bool rpt = await loginBloc.conexion(show).then((response) async {
      if (response && pendientes.length > 0) {
        int cont = 0;
        var errores = [];
        for (int i = 0; i < pendientes.length; i++) {
          //* GET Pesajes detalle de la BDLocal
          List<PesajeDetalleItem> items =
              await dbLocalsave.pesajesDetalle(pendientes[i].Uuid);

          var datasave = SaveRequest(pendientes[i], items);
          //? ESTADO LOCAL DE LOS REGISTROS P = Pendiente de subir | C = Subido al servidor | E = Error
          pendientes[i].Estado = "P";

          await dbLocalsave.updatePesaje(pendientes[i]);

          //* Se llama a si mismo para guardar la data en la BD online
          SaveReponse response = await saveDataOnline(datasave);

          if (response.nCodError == 0 && response.oContenido.Numero > 0) {
            pendientes[i].Numero = response.oContenido.Numero;
            pendientes[i].nPedidoTestaferro =
                response.oContenido.nPedidoTestaferro;
            pendientes[i].Estado = "C";
            cont++;
          } else {
            pendientes[i].Estado = "E";
            errores.add(response.cMsjError);
          }
          //Pendientes[i].Estado = "C";
          //* Llamada a la base de datos local para actualizar el pesaje
          await dbLocalsave.updatePesaje(pendientes[i]);
        }
        if (pendientes.length == cont) {
          Fluttertoast.showToast(
            msg: "Sincronización exitosa!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 20.0,
          );
          dbLocalsave.deletePesajes("C");
        } else
          Fluttertoast.showToast(
            msg: "Fallo la sincronización: " + errores.join('; '),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 20.0,
          );
        return !(pendientes.length == cont);
      } else
        return pendientes.length > 0;
    });
    return rpt;
  }

  Future<List<PesajeDetalleItem>> getList(String Uuid) {
    return dbLocalsave.pesajesDetalle(Uuid);
  }

  Future<List<SaveRequestCab>> getPesaje() {
    return dbLocalsave.pesajes();
  }

  Future<List<SaveRequestCab>> getPesajeCabesera(String Uuid) async {
    /*dbLocalsave.cleanPesajes();*/
    List<SaveRequestCab> list = await dbLocalsave.pesajesCabecera('C');
    return list.where((element) => element.Uuid == Uuid).toList();
  }
  /*saveDataOnline(item).then((response) {
          if (response.nCodError == 0) {
            if(response.oContenido.Numero>0)
              {
                pesosBackGraund.remove(item);
              }
          }
        });*/

  Future<SaveReponse> saveDataOnline(SaveRequest request) async {
    SaveReponse saveReponse = await pedidoRepository.saveDataPesajes(request);
    return saveReponse;
  }
  /* Future<List<SaveRequestCab>> revisarDatosErroneos(List<SaveRequestCab> request) async {
    List<SaveRequestCab> saveReponse = await pedidoRepository.revisarDatosErroneos(request);
    return saveReponse;
  }*/

  Future<RepartoResponse> updateDataPesajes(SaveRequest request) async {
    RepartoResponse saveReponse =
        await pedidoRepository.updateDataPesajes(request);
    return saveReponse;
  }

  Future<DataResponse> getReportPesadas(
      PuntoVenta, Cliente, Tipo, Fecha) async {
    DataResponse saveReponse = await pedidoRepository.getReportPesadas(
        PuntoVenta, Cliente, Tipo, Fecha);
    return saveReponse;
  }

  Future<int> actualizarPedido(
      int puntoVenta, int numeroPedido, int estado) async {
    int res = await pedidoRepository.actualizarPedido(
        puntoVenta, numeroPedido, estado);
    return res;
  }

  Future<PedidoEstadoBuscarResponse> getDataPedidosBucar(
      PedidoEstadoBuscar obj) async {
    PedidoEstadoBuscarResponse resp =
        await pedidoRepository.getDataPedidosBucar(obj);
    return resp;
  }

  deleteDataLocalPesajes() async {
    await dbLocalsave.createDb2();
    /*dbLocalsave.cleanPesajes("C");*/
    dbLocalsave.deletePesajes("C");
  }

  Future<LoginResponse> fetchActualizar(String user) async {
    LoginResponse loginResponse = await pedidoRepository.fetchActualizar(user);
    balanzaBloc.AvailableManual = loginResponse.loginData.dataUsuario.balanzaManual;
    return loginResponse;
  }

  Future<int> fetchImprimirCOntrolPesos(
      String puntoVenta, String pedido) async {
    int resp = await pedidoRepository.imprimirControlPesos(puntoVenta, pedido);
    return resp;
  }

  Future<int> fetchImprimirPesadas(String puntoVenta, String pesada) async {
    int resp = await pedidoRepository.imprimirPesada(puntoVenta, pesada);
    return resp;
  }

  Future<List<Cliente>> getTestaferros(String puntoVenta, String pedido) async {
    List<Cliente> response =
        await pedidoRepository.getTestaferros(puntoVenta, pedido);
    return response;
  }

  Future<List<PedidoCliente>> getPedidoTestaferros(
      String puntoVenta, String pedido) async {
    List<PedidoCliente> response =
        await pedidoRepository.getPedidoTestaferros(puntoVenta, pedido);
    return response;
  }

  Future<int> cerrarTodosPedidos(String puntoVenta) async {
    int response = await pedidoRepository.cerrarTodosPedidos(puntoVenta);
    return response;
  }

  Future<ReporteRanflaResponse> obtenerReporteDeRanflas(String puntoVenta, DateTime fecha) async {
    ReporteRanflaResponse response = await pedidoRepository.obtenerReporteDeRanflas(puntoVenta, fecha);
    return response;
  }

  Future<List<EstadoPedido>> obtenerPedidosConFacturacion(String nPuntoVenta) async {
    List<EstadoPedido> response = await pedidoRepository.obtenerPedidosConFacturacion(nPuntoVenta);
    return response;
  }

  Future<List<FacturaPedido>> obtenerFacturasPedido(String nPuntoVenta, int nPedido) async {
    List<FacturaPedido> response = await pedidoRepository.obtenerFacturasPedido(nPuntoVenta, nPedido);
    return response;
  }

  Future<SolicitudRes> saveSolicitudDevolucion(SaveRequestSolicitud request) async {
    SolicitudRes response = await pedidoRepository.saveSolicitudDevolucion(request);
    return response;
  }

  Future<SolicitudResponse> obtenerSolicitudesDevolucion(int puntoVenta) async {
    SolicitudResponse response = await pedidoRepository.obtenerSolicitudesDevolucion(puntoVenta);
    return response;
  }

  Future<SolicitudRes> eliminarSolicitudDevolucion(SolicitudDevolucion solicitud) async {
    SolicitudRes response = await pedidoRepository.eliminarSolicitudDevolucion(solicitud);
    return response;
  }

  Future<TransferenciaObtenerResponse> obtenerTransferencias(int puntoVenta, String lotes) async {
    TransferenciaObtenerResponse response = await pedidoRepository.obtenerTransferencias(puntoVenta, lotes);
    return response;
  }

  Future<SaveRequestCab> eliminarTransferencia(int puntoVenta, int repeso) async {
    SaveRequestCab response = await pedidoRepository.eliminarTransferencia(puntoVenta, repeso);
    return response;
  }

  Future<PesajeDetalleItem> eliminarTransferenciaDetalle(int puntoVenta, int repeso, int item) async {
    PesajeDetalleItem response = await pedidoRepository.eliminarTransferenciaDetalle(puntoVenta, repeso, item);
    return response;
  }

  Future<Lote> obtenerUnidadesDisponiblesLote(int puntoVenta, int lotePrincipal, int subLote) async {
    Lote response = await pedidoRepository.obtenerUnidadesDisponiblesLote(puntoVenta, lotePrincipal, subLote);
    return response;
  }
}

final pedidoBloc = PedidoBloc();
