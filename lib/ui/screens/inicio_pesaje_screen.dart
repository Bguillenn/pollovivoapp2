import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pollovivoapp/bloc/login_bloc.dart';
import 'package:pollovivoapp/bloc/pedido_bloc.dart';
import 'package:pollovivoapp/bloc/reparto_bloc.dart';
import 'package:pollovivoapp/model/cliente.dart';
import 'package:pollovivoapp/model/grupo_cliente.dart';
import 'package:pollovivoapp/model/login_response.dart';
import 'package:pollovivoapp/model/lote.dart';
import 'package:pollovivoapp/model/pedido_data.dart';
import 'package:pollovivoapp/model/pedido_item.dart';
import 'package:pollovivoapp/model/pedido_request.dart';
import 'package:pollovivoapp/model/pedido_response.dart';
import 'package:pollovivoapp/model/reparto_header.dart';
import 'package:pollovivoapp/model/reparto_item.dart';
import 'package:pollovivoapp/model/repartos_response.dart';
import 'package:pollovivoapp/model/tipo_repeso.dart';
import 'package:pollovivoapp/model/unidad_reparto.dart';
import 'package:pollovivoapp/model/ranfla.dart';
import 'package:pollovivoapp/ui/screens/seleccion_pedido_facturado.dart';
import 'package:pollovivoapp/ui/screens/pedido_abrir.dart';
import 'package:pollovivoapp/ui/screens/pedido_screen.dart';
import 'package:pollovivoapp/ui/screens/pedido_testaferro.dart';
import 'package:pollovivoapp/ui/screens/preparacion_reparto_screen.dart';
import 'package:pollovivoapp/ui/screens/ranfla_reporte_screen.dart';
import 'package:pollovivoapp/ui/screens/reparto_abrir.dart';
import 'package:pollovivoapp/ui/screens/resumen_pedido.dart';
import 'package:pollovivoapp/ui/screens/search_screen.dart';
import 'package:pollovivoapp/ui/screens/seleccion_testaferro_screen.dart';
import 'package:pollovivoapp/ui/widgets/progresRefresActionBar.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'login_screen.dart';

class InicioPesajeScreen extends StatefulWidget {
  LoginResponse response;
  int codigoPuntoVenta;
  String rowPersonal, rowPuntoVenta;

  InicioPesajeScreen(this.response) {
    this.codigoPuntoVenta = response.loginData.dataUsuario.puntoVentaCodigo;

    String codPer = response.loginData.dataUsuario.codigoPersonal != null
        ? response.loginData.dataUsuario.codigoPersonal.toString().trim()
        : "";
    String nomPer = response.loginData.dataUsuario.nombrePersonal.trim();
    String pVenta = response.loginData.dataUsuario.puntoVentaNombre.trim();

    this.rowPersonal = "Bienvenido: $nomPer - $codPer";
    this.rowPuntoVenta = "PuntoVenta: $pVenta - ${codigoPuntoVenta.toString()}";
  }

  @override
  _InicioScreenState createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioPesajeScreen> {
  List<TipoRepeso> _tiposRepeso;
  List<Cliente> _clientes;
  List<GrupoCliente> _gruposCliente;

  List<Ranfla> _ranflas;
  List<Lote> _lotes;
  List<UnidadReparto> _vehiculos;
  List<RepartoCabecera> _itemsRepartos;
  List<RepartoCabecera> _repartos;
  List<RepartoItem> _repartoDetalle;
  List<Cliente> _clientesTestaferro = [];

  PedidoItem _pedidoSelected;
  List<PedidoItem> _pedidos;
  int currentIndex = 10;
  final String version = "2.02";
  TipoRepeso _tipoRepesoSelected;
  GrupoCliente _grupoClienteSelected;
  Cliente _clienteSelected;
  Ranfla _ranflaSelected;

  //Lote _loteSelected;
  UnidadReparto _placaSelected;
  RepartoCabecera _repartoReselected;

  //RepartoCabecera _repartoRepesoSelected;
  bool isload = false;
  bool loadingsave;
  bool pendientesave;
  List<DropdownMenuItem<TipoRepeso>> _itemsTipoRepeso;
  List<DropdownMenuItem<Cliente>> _itemsCliente;
  List<DropdownMenuItem<UnidadReparto>> _itemsVehiculos;
  DateTime inicioDate = DateTime.now().subtract(Duration(days: 1));
  DateTime finDate = DateTime.now().add(Duration(days: 1));

  TipoRepeso _tipoRepesoVentaDirectaSelected;
  List<TipoRepeso> _repesoVentaDirecta;


  var redibujar;

  bool blockButton = false;
  @override
  void initState() {
    super.initState();
    pendientesave = false;
    loadingsave = false;
    _tiposRepeso = widget.response.loginData.tiposRepeso;
    _clientes = widget.response.loginData.clientes;
    _gruposCliente = widget.response.loginData.gruposCliente;
    _vehiculos = widget.response.loginData.vehiculos;
    _pedidos = listaPedidos();

    _repartos = new List.empty(growable: true);
    _repartoDetalle = new List.empty(growable: true);
    _itemsTipoRepeso = List.empty(growable: true);
    _itemsVehiculos = List.empty(growable: true);
    _itemsCliente = List.empty(growable: true);
    _itemsRepartos = List.empty(growable: true);
    _ranflas = [];

    for (TipoRepeso tipoRepeso in _tiposRepeso) {
      _itemsTipoRepeso.add(DropdownMenuItem(
        value: tipoRepeso,
        child: Text(tipoRepeso.nombre.trim()),
      ));
    }

    for (UnidadReparto item in _vehiculos) {
      _itemsVehiculos.add(DropdownMenuItem(
        value: item,
        child: Text(item.placa),
      ));
    }

    for (Cliente cliente in _clientes) {
      _itemsCliente.add(DropdownMenuItem(
        value: cliente,
        child: Text(cliente.nombre.trim()),
      ));
    }

    //? Establece el menu predeterminado a 10 (VENTA)
    if (_itemsTipoRepeso.length > 0) {
      _tipoRepesoSelected = _itemsTipoRepeso
          .firstWhere((element) => element.value.codigo == 10)
          .value;
    }

    if (_itemsCliente.length > 0) _clienteSelected = _itemsCliente[0].value;
    if (_gruposCliente.length > 0) {
      _grupoClienteSelected = _gruposCliente[0];
      _grupoClienteSelected.oClientes = _clientes
          .where((cliente) => cliente.grupo == _grupoClienteSelected.nCodigo)
          .toList();
    }
    if (_itemsVehiculos.length > 0) _placaSelected = _itemsVehiculos[0].value;

    _itemsRepartos.add(new RepartoCabecera(widget.codigoPuntoVenta, -1,
        _placaSelected.vehiculo, new DateTime.now(), "NUEVO REPARTO"));
    _repartoReselected = _itemsRepartos[0];

    //* Llamada a pedidos BLOC para ver si hay pedidos en la DB Local
    pedidoBloc.pendientes().then((value) => {
          setState(() {
            pendientesave = value;
          })
        });

    //*LLamada a login BLOC
    getData().then((value) {});

    //*Llamada a pedidos BLOC
    pedidoBloc.getTestaferros(widget.codigoPuntoVenta.toString(), "0").then(
        (respGT) => {
              if (respGT != null && respGT.length > 0)
                _clientesTestaferro = respGT
            });

    _repesoVentaDirecta = [
      new TipoRepeso(0, "Venta Acopio / Venta Directa"),
      new TipoRepeso(1, "Venta Reparto")
    ];
    _tipoRepesoVentaDirectaSelected = _repesoVentaDirecta[0];
  }

  filtrarPedidos() {
    _pedidos = widget.response.loginData.pedidos
        .where((element) => element.cliente == _clienteSelected.codigo);
  }

  List<PedidoItem> filtrarPedidosList() {
    return widget.response.loginData.pedidos
        .where((element) => element.cliente == _clienteSelected.codigo);
  }

  List<PedidoItem> listaPedidos() {
    List<PedidoItem> list = new List<PedidoItem>.empty(growable: true);
    widget.response.loginData.pedidos.forEach((element) {
      PedidoItem temp = list.firstWhere(
          (item) => element.numeroPedido == item.numeroPedido,
          orElse: () => null);
      if (temp == null) {
        list.add(element);
      }
    });
    return list;
  }

  void cargarRanflas(RepartosResponse response) {
    List<Ranfla> ranflas = [];
    response.repartoData.lotes.forEach((lote) {
      //? Crea una ranfla por numero de lote y numero de viaje
      Ranfla temp = ranflas.firstWhere(
          (ran) => lote.placa == ran.placa && lote.viaje == ran.viaje,
          orElse: () => null);
      if (temp == null) {
        List<int> lotes = [lote.numero];
        temp = new Ranfla(lote.lotePrincipal, lote.viaje, lote.placa, lotes);
        ranflas.add(temp);
      } else {
        temp.lotes.add(lote.numero);
      }
      temp.addDisponible(lote.disponible);
    });
    //? Carga las ranflas a la vista
    _ranflas = ranflas.toList();
    if (_ranflaSelected != null) {
      _ranflaSelected = ranflas.firstWhere((element) =>
          _ranflaSelected.placa == element.placa &&
          _ranflaSelected.viaje == element.viaje);
    } else {
      _ranflaSelected = ranflas[0];
    }
    widget.response.loginData.lotes = _lotes
        .where((element) =>
            _ranflaSelected.placa == element.placa &&
            _ranflaSelected.viaje == element.viaje)
        .toList();
  }

  getData() async {
    await loginBloc.conexion(false).then((response) {
      if (response) {
        // * Llama a reparto BLOC para obtener datos de los lotes y las ranflas
        repartoBloc.getdataRepartos(widget.codigoPuntoVenta).then((response) {
          widget.response.loginData.lotes = response.repartoData.lotes;
          _lotes = response.repartoData.lotes;
          _repartos = response.repartoData.repartoCabeceras;
          _repartoDetalle = response.repartoData.repartoDetalles;
          cargarRanflas(response);
          filtrarItemsPorPlaca();
          return response.repartoData;
        });
      }
    });
  }

  List<PedidoItem> pedidoSinRepeticion(List<PedidoItem> items_arr) {
    List<PedidoItem> resp = new List<PedidoItem>.empty(growable: true);
    for (int i = 0; i < items_arr.length; i++) {
      PedidoItem item = resp.firstWhere(
          (r) => r.numeroPedido == items_arr[i].numeroPedido,
          orElse: () => null);
      if (item == null) resp.add(items_arr[i]);
    }
    return resp;
  }

  void filtrarItemsPorPlaca() {
    _itemsRepartos = List.empty(growable: true);
    if (_tipoRepesoSelected.codigo == 1 && _repartos.length == 0) {
      Fluttertoast.showToast(
          msg: "No existen ningun reparto listo",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.amber,
          textColor: Colors.white,
          fontSize: 20.0);
      return;
    }
    var usuario = widget.response.loginData.dataUsuario.usuario;
    setState(() {
      if (_tipoRepesoSelected.codigo == 5)
        _itemsRepartos.add(new RepartoCabecera(widget.codigoPuntoVenta, -1,
            _placaSelected.vehiculo, new DateTime.now(), "NUEVO REPARTO"));
      for (RepartoCabecera item in _repartos) {
        String placaRp = _vehiculos
            .firstWhere((element) => element.vehiculo == item.Vehiculo)
            .placa;
        if (item.Vehiculo == _placaSelected.vehiculo &&
            (_tipoRepesoSelected.codigo == 1 ||
                (_tipoRepesoSelected.codigo == 5 &&
                    usuario == item.UsuarioRegistro))) {
          item.Nombre = placaRp + " - " + item.NumeroReparto.toString();
          var reparto = _repartoDetalle.firstWhere(
              (e) => e.numeroReparto == item.NumeroReparto,
              orElse: () => null);
          if (reparto != null) _itemsRepartos.add(item);
        }
      }
      if (_itemsRepartos.length > 0) _repartoReselected = _itemsRepartos[0];
    });
  }

  void refreshsSave() {
    setState(() {
      loadingsave = true;
    });
    pedidoBloc.saveDataChangue(true).then((value) => setState(() {
          pendientesave = value;
          loadingsave = false;
        }));
  }

  void updateState() {
    print('Update state');
    var usuario = widget.response.loginData.dataUsuario.usuario.split("\\")[1];
    //* LLamada a pedido BLOC para actualizar data
    pedidoBloc.fetchActualizar(usuario).then((response) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => InicioPesajeScreen(response)));
    });
  }

  List<Widget> itemmenus() {
    List<Widget> titles = new List.empty(growable: true);
    for (TipoRepeso item in _tiposRepeso) {
      titles.add(GestureDetector(
        onTap: () {
          TipoRepeso currentOpcion = _tipoRepesoSelected;
          Navigator.pop(context, true);
          if(item.codigo == 11) {
            
            Navigator.push(
              context,
              new MaterialPageRoute<int>(
                  builder: (context) => RanflaReporteScreen(_ranflas)));
            return;
          }
          if(item.codigo == 2) {
            
            Navigator.push(
              context,
              new MaterialPageRoute<int>(
                  builder: (context) => SeleccionPedidoFacturado(
                    _pedidos, 
                    item,
                    this.widget.response.loginData.motivosDevolucion, 
                    this.widget.response.loginData.tiposDevolucion,
                    this.widget.response,
                    this._lotes)));
            return;
          }
          setState(() {
            //Si es reporte de ranflas o devolucion cliente regresamos a la opcion anterior ya que redirige a nueva vista
            TipoRepeso newOpcion = (item.codigo == 11 || item.codigo == 2) ? currentOpcion : item;
            currentIndex = newOpcion.codigo;
            _tipoRepesoSelected = newOpcion;
            if (newOpcion.codigo == 5 || newOpcion.codigo == 1)
              filtrarItemsPorPlaca();
            else if (newOpcion.codigo == 3)
              loadPedido();
            else if (newOpcion.codigo == 6)
              _pedidos = widget.response.loginData.pedidos
                  .where(
                      (element) => element.cliente == _clienteSelected.codigo)
                  .toList();
          });
        },
        child: // if(currentIndex==item.id)
            Ink(
          color: currentIndex == item.codigo
              ? Color.fromRGBO(34, 35, 79, 1)
              : Colors.white,
          child: new ListTile(
            leading: SvgPicture.asset(
              'assets/icons/' + item.codigo.toString() + '.svg',
              width: 21,
              color: currentIndex == item.codigo
                  ? Colors.white
                  : Color.fromRGBO(0, 0, 40, 0.6),
              height: 21,
            ),
            title: Text(
              item.nombre,
              style: TextStyle(
                  color: currentIndex == item.codigo
                      ? Colors.white
                      : Color.fromRGBO(34, 35, 79, 1)),
            ),
          ),
        ),
      ));
    }
    return titles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppBar(),
      body: SingleChildScrollView(
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            child: renderContenido()),
      ),
      drawer: renderDrawer(),
    );
  }

  Future<void> cerrarPedido() async {
    _clienteSelected.codigo;
    repartoBloc
        .cerrarPedido(widget.codigoPuntoVenta, _pedidoSelected.numeroPedido)
        .then((response) {
      //widget.reponseLotes=response;
      updateState();

      Fluttertoast.showToast(
        msg: "Pedido cerrado con exito",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 20.0,
      );
    });

    return;
  }

  //? CARGA PEDIDO PARA VENTA
  Future<void> loadPedido() async {
    //? Si no hay lotes abiertos
    if (widget.response.loginData.lotes.length == 0) {
      Fluttertoast.showToast(
        msg: "No existe lotes abiertos",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 20.0,
      );
      return;
    }

    // ? No se sabe que es el codigo 5 aparentemente reparto
    if (_tipoRepesoSelected.codigo == 5) {
      // PREPARACION DE REPARTO

      if (_repartoReselected.NumeroReparto < 0) {
        if (widget.response.loginData.lotes
                .fold(0, (sum, item) => sum + item.disponible) <=
            0) {
          Fluttertoast.showToast(
            msg: "No existe lotes Disponibles",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 20.0,
          );
          return;
        }
      } else
        for (RepartoItem item in _repartoDetalle) {
          if (item.numeroReparto == _repartoReselected.NumeroReparto) {
            _repartoReselected.items.add(item);
          }
        }
      int numero = await Navigator.push(
          context,
          new MaterialPageRoute<int>(
              builder: (context) => PreparacionRepartoScreen(
                  widget.response, _placaSelected, _repartoReselected)));
      blockButton = false;

      getData().then((value) {
        print("Nuevo Reparto: " + numero.toString());
      });
    } else {
      //? Valida si ya esta cargando la aplicacion
      if (!isload) {
        isload = true;
        //* Llamada a login bloc metodo conexion
        await loginBloc
            .conexion(_tipoRepesoSelected.codigo == 3)
            .then((result) {
          isload = false;
          //? Si hay conexion
          if (result) {
            //? Solo en el caso de devolucion al cliente
            if (_clienteSelected == null && _tipoRepesoSelected.codigo < 3)
              return;

            //? Para venta
            int _tipoRepeso = 0;
            if (_tipoRepesoSelected.codigo == 10) {
              //? Venta acopio / Venta directa
              if (_tipoRepesoVentaDirectaSelected.codigo == 0)
                _tipoRepeso = 0;
              //? Venta reparto
              else if (_tipoRepesoVentaDirectaSelected.codigo == 1)
                _tipoRepeso = 10;
              //? Para otro que no es venta
            } else {
              _tipoRepeso = _tipoRepesoSelected.codigo;
            }

            //? Creamos un objeto de pedido request con el punto de venta, el codigo del cliente seleccionado y el tipo de repeso puesto anteriormente
            PedidoRequest req = PedidoRequest(
                widget.codigoPuntoVenta,
                _tipoRepesoSelected.codigo == 3 ? 0 : _clienteSelected.codigo,
                _tipoRepeso);

            //* Si es venta cargamos la vista de testaferros
            if (_tipoRepesoSelected.codigo == 10)
              loadTestaferrosView();
            else
              pedidoBloc.fetchDataPedido(req).then((response) {
                //* Para venta delegamos la tarea de cargar pedido a la vista de seleccion de testaferro
                if (response.nCodError == 0) {
                  bool tienePedidos = false;
                  //? Valida si dentro dentro de los lotes habilitados, hay el producto de los pedidos
                  response.pedidoData.pedidoDetalles
                      .forEach((PedidoItem pedidoDetalle) {
                    var lotesHabilitados = widget.response.loginData.lotes
                        .where((lote) => pedidoDetalle.producto == lote.codigo);
                    if (lotesHabilitados.length > 0) tienePedidos = true;
                  });
                  loadRepeso(response);
                  if (!tienePedidos) {
                    Fluttertoast.showToast(
                      msg: "El cliente no tiene pedidos en la ranfla",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.amber,
                      textColor: Colors.black,
                      fontSize: 20.0,
                    );
                  }
                  //? Para otra cosa que no es venta
                } else if (_tipoRepesoSelected.codigo < 3) {
                  var pedidos = widget.response.loginData.pedidos
                      .where((element) =>
                          element.cliente == _clienteSelected.codigo)
                      .toList();
                  /* if(_tipoRepesoSelected.Codigo==2) pedidos = pedidos.where((element) => element.Estado!=0).toList();
                      else pedidos = pedidos.where((element) => element.Reparto==_tipoRepesoSelected.Codigo && element.Estado!=2).toList();*/
                  var objresponse = new PedidoResponse(
                      "", "", 0, new PedidoData(pedidos, []));

                  loadRepeso(objresponse);
                  //? Muestra mensaje de error del endpoint
                } else {
                  Fluttertoast.showToast(
                    msg: response.cMsjError,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 20.0,
                  );
                }
              });
            //? Si no hay conexion y el tipo de repeso es menor a 3 (Solo es posible en el caso de devolucion al cliente)
          } else if (_tipoRepesoSelected.codigo < 3) {
            var pedidos = widget.response.loginData.pedidos
                .where((element) => element.cliente == _clienteSelected.codigo)
                .toList();
            if (_tipoRepesoSelected.codigo == 2)
              pedidos =
                  pedidos.where((element) => element.estado != 0).toList();
            else
              pedidos = pedidos
                  .where((element) =>
                      element.reparto == _tipoRepesoSelected.codigo &&
                      element.estado != 2)
                  .toList();
            var objresponse =
                new PedidoResponse("", "", 0, new PedidoData(pedidos, []));
            loadRepeso(objresponse);
          }
        });
      }
    }
  }

  Future<void> loadRepeso(PedidoResponse response) async {
    //? Para pollo muerto viaje
    if (_tipoRepesoSelected.codigo == 3) {
      List<PedidoItem> arr = new List<PedidoItem>.empty(growable: true);
      var pedidosRanfla = response.pedidoData.pedidoDetalles;
      var lotesRanflaSelecionada = widget.response.loginData.lotes;
      for (var itemPR in pedidosRanfla) {
        for (var itemLRS in lotesRanflaSelecionada) {
          if (itemPR.numeroPedido == itemLRS.numero) {
            arr.add(itemPR);
          }
        }
      }
      response.pedidoData.pedidoDetalles = arr;
    }

    for (RepartoItem item in _repartoDetalle) {
      if (item.numeroReparto == _repartoReselected.NumeroReparto) {
        _repartoReselected.items.add(item);
      }
    }

    //? Para otra cosa que no es venta
    if (_tipoRepesoSelected.codigo == 1) {
      //? VENTA REPARTO VALIDAMOS SI TIENE PEDIDOS EN EL CAMION DE REPARTO
      bool passPedidoReparto = false;
      for (var itemp in response.pedidoData.pedidoDetalles) {
        for (var itemr in _repartoReselected.items) {
          var item = widget.response.loginData.lotes.firstWhere(
              (element) => element.numero == itemr.loteNumero,
              orElse: () => null);
          if (item != null &&
              itemp.producto == item.codigo) //&& itemr.Disponible>0
            passPedidoReparto = true;
        }
      }
      //? Si no hay ningun item en el camion de reparto
      if (!passPedidoReparto) {
        Fluttertoast.showToast(
          msg: "Cliente no tiene ningun pedido en el camion reparto",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.amber,
          textColor: Colors.black,
          fontSize: 20.0,
        );
        return;
      }
    }

    //? Saca las filas y columnas del vehiculo que selecciono
    _repartoReselected.Filas = _vehiculos
        .firstWhere(
            (element) => element.vehiculo == _repartoReselected.Vehiculo)
        .fila;
    _repartoReselected.Columnas = _vehiculos
        .firstWhere(
            (element) => element.vehiculo == _repartoReselected.Vehiculo)
        .columna;

    //? Regresa el numero cuando se cierra la vista, espera a que regrese para continuar
    int numero;

    numero = await Navigator.push(
        context,
        new MaterialPageRoute<int>(
          builder: (context) => PedidoScreen(
              response,
              _tipoRepesoSelected,
              _clienteSelected,
              _repartoReselected,
              widget.codigoPuntoVenta,
              widget.response,
              _clientesTestaferro,
              _tipoRepesoVentaDirectaSelected),
        ));
    blockButton = false;

    pedidoBloc.saveDataChangue(false).then((value) => setState(() {
          pendientesave = value;
        }));

    getData().then((value) {
      print("Nuevo Reparto: " + numero.toString());
    });
  }

  Widget renderAppBar() {
    return AppBar(
      backgroundColor: loginBloc.online ? null : Colors.amber,
      title: Center(
        child: Text(_tiposRepeso
            .firstWhere((element) => element.codigo == currentIndex)
            .nombre),
      ),
      actions: [
        if (pendientesave)
          ProgressRefreshAction(loadingsave, Icons.save_outlined, refreshsSave),
        IconButton(
            icon: Icon(
              Icons.search_sharp,
              size: 32.0,
            ),
            onPressed: () => Navigator.push(
                context,
                new MaterialPageRoute<int>(
                    builder: (context) => SearchScreen(widget.response)))),
        IconButton(
            icon: Icon(
              Icons.update,
              size: 32.0,
            ),
            onPressed: () => updateState())
      ],
    );
  }

  Widget renderContenido() {
    return Column(children: <Widget>[
      renderRanflaDropdownBox(),
      renderClientesDropdownBox(),
      renderGrupoClienteDropdownBox(),
      renderTipoVentaDropdownBox(),
      renderVehiculosDropdownBox(),
      renderItemsRepartorDropdownBox(),
      renderPedidoDropdownBox(),
      renderDesdeHastaInputs(),
      renderResumenPedidoView(),
      renderRepartoAbrirView(),
      renderReabrirPedidoView(),
      renderImprimirControlPesosButton(),
      renderSiguienteCerrarButton(),
      renderCerrarTodosPedidosButton(),
      renderPedidoTestaferroView(),
    ]);
  }

  Widget renderRanflaDropdownBox() {
    if (_tipoRepesoSelected.codigo != 6 &&
        _tipoRepesoSelected.codigo != 7 &&
        _tipoRepesoSelected.codigo != 8 &&
        _tipoRepesoSelected.codigo != 9 &&
        _tipoRepesoSelected.codigo != 11)
      return Column(
        children: [
          DropdownButton<Ranfla>(
            value: _ranflaSelected,
            items: _ranflas
                .map(
                  (data) => DropdownMenuItem<Ranfla>(
                    child: Text(
                      data.toString(),
                      style: TextStyle(color: data.color()),
                    ),
                    value: data,
                  ),
                )
                .toList(),
            onChanged: (Ranfla value) {
              setState(() => {
                    _ranflaSelected = value,
                    filtrarItemsPorPlaca(),
                    widget.response.loginData.lotes = _lotes
                        .where((element) =>
                            value.placa == element.placa &&
                            value.viaje == element.viaje)
                        .toList(),
                  });
            },
            iconSize: 30.0,
            isExpanded: true,
          ),
        ],
      );
    else
      return Container();
  }

  Widget renderGrupoClienteDropdownBox() {
    //? Solo para venta se selecciona el grupo de cliente
    if (_tipoRepesoSelected.codigo == 10)
      return DropdownButton<GrupoCliente>(
        value: _grupoClienteSelected,
        items: _gruposCliente
            .map((grupo) => DropdownMenuItem<GrupoCliente>(
                child: Text(grupo.cNombre), value: grupo))
            .toList(),
        onChanged: (GrupoCliente grupo) {
          setState(() => {
                _grupoClienteSelected = grupo,
                _grupoClienteSelected.oClientes = _clientes
                    .where((cliente) => cliente.grupo == grupo.nCodigo)
                    .toList()
              });
        },
        iconSize: 30.0,
        isExpanded: true,
      );
    else
      return Container();
  }

  Widget renderClientesDropdownBox() {
    if (_tipoRepesoSelected.codigo != 3 &&
        _tipoRepesoSelected.codigo != 5 &&
        _tipoRepesoSelected.codigo != 7 &&
        _tipoRepesoSelected.codigo != 8 &&
        _tipoRepesoSelected.codigo != 10 &&
        _tipoRepesoSelected.codigo != 11)
      return DropdownButton<Cliente>(
        value: _clienteSelected,
        items: _clientes
            .map(
              (data) => DropdownMenuItem<Cliente>(
                child: Text(data.nombre),
                value: data,
              ),
            )
            .toList(),
        onChanged: (Cliente value) {
          //filtrarPedidos();
          setState(() => {
                _clienteSelected = value,
                //_pedidos =
                _pedidos = widget.response.loginData.pedidos
                    .where(
                        (element) => element.cliente == _clienteSelected.codigo)
                    .toList(),
                _pedidoSelected = _pedidos[0]
              });
        },
        iconSize: 30.0,
        isExpanded: true,
      );
    else
      return Container();
  }

  Widget renderTipoVentaDropdownBox() {
    if (_tipoRepesoSelected.codigo == 10)
      return DropdownButton<TipoRepeso>(
        value: _tipoRepesoVentaDirectaSelected,
        items: _repesoVentaDirecta
            .map(
              (data) => DropdownMenuItem<TipoRepeso>(
                child: Text(data.nombre),
                value: data,
              ),
            )
            .toList(),
        onChanged: (TipoRepeso value) {
          print("TIPO VENTA CODIGO: ${value.codigo}");
          setState(() => {_tipoRepesoVentaDirectaSelected = value});
        },
        iconSize: 30.0,
        isExpanded: true,
      );
    else
      return Container();
  }

  Widget renderVehiculosDropdownBox() {
    if (_tipoRepesoSelected.codigo == 5 || _tipoRepesoSelected.codigo == 7)
      return DropdownButton<UnidadReparto>(
        value: _placaSelected,
        items: _vehiculos
            .map(
              (data) => DropdownMenuItem<UnidadReparto>(
                child: Text(data.placa),
                value: data,
              ),
            )
            .toList(),
        onChanged: (UnidadReparto value) {
          setState(() => {_placaSelected = value, filtrarItemsPorPlaca()});
        },
        iconSize: 30.0,
        isExpanded: true,
      );
    else
      return Container();
  }

  Widget renderItemsRepartorDropdownBox() {
    if (_itemsRepartos.length > 0 &&
        (_tipoRepesoSelected.codigo == 5 || _tipoRepesoSelected.codigo == 1))
      return DropdownButton<RepartoCabecera>(
        value: _repartoReselected,
        items: _itemsRepartos
            .map(
              (data) => DropdownMenuItem<RepartoCabecera>(
                child: Text(data.Nombre),
                value: data,
              ),
            )
            .toList(),
        onChanged: (RepartoCabecera value) {
          setState(() => {
                _repartoReselected = value,
              });
        },
        iconSize: 30.0,
        isExpanded: true,
      );
    else
      return Container();
  }

  Widget renderPedidoDropdownBox() {
    if (_tipoRepesoSelected.codigo == 6)
      return DropdownButton<PedidoItem>(
        value: _pedidoSelected,
        items: pedidoSinRepeticion(_pedidos)
            .map(
              (data) => DropdownMenuItem<PedidoItem>(
                child: Text(data.numeroPedido.toString()),
                value: data,
              ),
            )
            .toList(),
        onChanged: (PedidoItem value) {
          setState(() {
            _pedidoSelected = value;
          });
        },
        iconSize: 30.0,
        isExpanded: true,
      );
    else
      return Container();
  }

  Widget renderDesdeHastaInputs() {
    if (_tipoRepesoSelected.codigo == 7 || _tipoRepesoSelected.codigo == 8)
      return Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          alignment: Alignment.bottomLeft,
          child: Row(
            children: [
              MaterialButton(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Desde',
                        style: TextStyle(fontSize: 14),
                      ),
                      Icon(const IconData(0xe03a, fontFamily: 'MaterialIcons')),
                      Text(
                        '${inicioDate.year}/${inicioDate.month}/${inicioDate.day}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  //Text("Fecha ${inicioDate.year}/${inicioDate.month}/${inicioDate.day}"),
                  onPressed: () async {
                    DateTime newDate = await showDatePicker(
                      context: context,
                      locale: const Locale("es", "ES"),
                      initialDate: inicioDate,
                      firstDate: DateTime(DateTime.now().year - 1),
                      lastDate: DateTime(DateTime.now().year + 1),
                    );
                    inicioDate = newDate ?? inicioDate;
                    setState(() {});
                  }),
              MaterialButton(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Hasta',
                        style: TextStyle(fontSize: 14),
                      ),
                      Icon(const IconData(0xee2b, fontFamily: 'MaterialIcons')),
                      Text(
                        '${finDate.year}/${finDate.month}/${finDate.day}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    DateTime newDate = await showDatePicker(
                      context: context,
                      locale: const Locale("es", "ES"),
                      initialDate: finDate,
                      firstDate: DateTime(DateTime.now().year - 1),
                      lastDate: DateTime(DateTime.now().year + 1),
                    );
                    finDate = newDate ?? finDate;
                    setState(() {});
                  })
            ],
          ));
    else
      return Container();
  }

  Widget renderResumenPedidoView() {
    if (_tipoRepesoSelected.codigo == 6 && _pedidoSelected != null)
      return ResumenPedido(
          key: UniqueKey(),
          puntoVenta: widget.codigoPuntoVenta,
          pedido: _pedidoSelected);
    else
      return Container();
  }

  Widget renderRepartoAbrirView() {
    if (_tipoRepesoSelected.codigo == 7)
      return RepartoAbrir(
        key: UniqueKey(),
        PuntoVenta: widget.response.loginData.dataUsuario.puntoVentaCodigo,
        Vehiculo: _placaSelected.vehiculo,
        Desde: inicioDate,
        Hasta: finDate,
        Reload: () {
          setState(() {});
        },
      );
    else
      return Container();
  }

  Widget renderReabrirPedidoView() {
    if (_tipoRepesoSelected.codigo == 8)
      return PedidoAbrir(
        key: UniqueKey(),
        PuntoVenta: widget.response.loginData.dataUsuario.puntoVentaCodigo,
        Desde: inicioDate,
        Hasta: finDate,
        Reload: () {
          setState(() {});
        },
      );
    else
      return Container();
  }

  Widget renderImprimirControlPesosButton() {
    if (_tipoRepesoSelected.codigo == 6)
      return Container(
        margin:
            EdgeInsets.only(left: 50.0, right: 50.0, top: 10.0, bottom: 10.0),
        child: MaterialButton(
          onPressed: () async {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  title: Text(
                    "Imprimir",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  content:
                      Text("Imprimir Control de Pesos y Numero de Aves Vivas"),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        "ACEPTAR",
                      ),
                      onPressed: () async {
                        int resp;
                        try {
                          resp = await pedidoBloc.fetchImprimirCOntrolPesos(
                              widget.codigoPuntoVenta.toString(),
                              _pedidoSelected.numeroPedido.toString());
                        } catch (e) {
                          resp = 0;
                        }
                        if (resp == 1) {
                          Fluttertoast.showToast(
                            msg: "Se imprimio correctamente",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.green,
                            textColor: Colors.black,
                            fontSize: 20.0,
                          );
                          Navigator.of(context).pop();
                        } else if (resp == 0) {
                          Fluttertoast.showToast(
                            msg: "No se puedo imprimir.",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 20.0,
                          );
                        }
                      },
                    ),
                    TextButton(
                      child: Text(
                        "CANCELAR",
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                );
              },
            );
          },
          color: Colors.blue,
          textColor: Colors.white,
          child: Text(
            "IMPRIMIR CONTROL PESOS",
            style: TextStyle(
              fontSize: 18.0,
              fontFamily: 'Lato',
              fontWeight: FontWeight.bold,
            ),
          ),
          minWidth: 400,
          height: 60,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      );
    else
      return Container();
  }

  Widget renderSiguienteCerrarButton() {
    if (_tipoRepesoSelected.codigo != 7 &&
        _tipoRepesoSelected.codigo != 8 &&
        _tipoRepesoSelected.codigo != 9 &&
        _tipoRepesoSelected.codigo != 11)
      return Container(
        margin: EdgeInsets.all(50.0),
        child: MaterialButton(
          onPressed: () {
            if (_itemsRepartos.length == 0 && _tipoRepesoSelected.codigo == 1) {
              Fluttertoast.showToast(
                msg: "No hay repartos.",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 20.0,
              );
              return;
            }

            if (_tipoRepesoSelected.codigo == 6) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    title: Text(
                      "Desea cerrar pedido",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    content: Text("¿Esta seguro de cerrar el pedido?"),
                    actions: <Widget>[
                      TextButton(
                        child: Text(
                          "ACEPTAR",
                        ),
                        onPressed: () async {
                          cerrarPedido();
                        },
                      ),
                      TextButton(
                        child: Text(
                          "CANCELAR",
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  );
                },
              );
            } else {
              //? Caso de venta
              if (!blockButton) {
                blockButton = true;
                if (_tipoRepesoSelected.codigo == 10 &&
                    _tipoRepesoVentaDirectaSelected == null) {
                  //? Caso de venta y no selecciono el tipo de venta
                  Fluttertoast.showToast(
                    msg: "Seleccionar Tipo Venta",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 20.0,
                  );
                  blockButton = false;
                  return;
                }
                //? Seleciono todo y pone siguiente
                loadPedido();
              }
            }
          },
          color: Colors.blue,
          textColor: Colors.white,
          child: Text(
            _tipoRepesoSelected.codigo != 6 ? "SIGUIENTE" : "CERRAR",
            style: TextStyle(
              fontSize: 18.0,
              fontFamily: 'Lato',
              fontWeight: FontWeight.bold,
            ),
          ),
          minWidth: 400,
          height: 60,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      );
    else
      return Container();
  }

  Widget renderCerrarTodosPedidosButton() {
    if (_tipoRepesoSelected.codigo == 6)
      return Container(
        margin:
            EdgeInsets.only(left: 50.0, right: 50.0, top: 20.0, bottom: 20.0),
        child: MaterialButton(
          onPressed: () async {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  title: Text(
                    "PRECAUCIÓN!",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  content:
                      Text("¿Desea cerrar todos los pedidos del dia anterior?"),
                  actions: <Widget>[
                    TextButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                      child: Text(
                        "ACEPTAR",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        try {
                          await pedidoBloc.cerrarTodosPedidos(
                              widget.codigoPuntoVenta.toString());
                          Fluttertoast.showToast(
                            msg:
                                "Se cerraron todos los pedidos del dia anterior",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.green,
                            textColor: Colors.black,
                            fontSize: 20.0,
                          );
                          Navigator.of(context).pop();
                        } catch (e) {
                          Fluttertoast.showToast(
                            msg: "No se pudo cerrar los pedidos",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                            textColor: Colors.black,
                            fontSize: 20.0,
                          );
                        }
                      },
                    ),
                    TextButton(
                      child: Text(
                        "CANCELAR",
                        style: TextStyle(color: Colors.green),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                );
              },
            );
          },
          color: Colors.blue[900],
          textColor: Colors.white,
          child: Text(
            "CERRAR TODOS LOS PEDIDOS",
            style: TextStyle(
              fontSize: 18.0,
              fontFamily: 'Lato',
              fontWeight: FontWeight.bold,
            ),
          ),
          minWidth: 400,
          height: 60,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      );
    else
      return Container();
  }

  Widget renderPedidoTestaferroView() {
    if (_tipoRepesoSelected.codigo == 9)
      return PedidoTestaferro(
          GlobalKey(),
          widget.codigoPuntoVenta,
          _clienteSelected.codigo,
          widget.response.loginData.dataUsuario.taraJava);
    else
      return Container();
  }

  Widget renderDrawer() {
    return Drawer(
        child: Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height - 65,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    height: 140,
                    child: new UserAccountsDrawerHeader(
                      accountName: Text(
                          "Punto Venta: " +
                              widget.response.loginData.dataUsuario
                                  .puntoVentaCodigo
                                  .toString(),
                          style: TextStyle(color: Colors.white)),
                      accountEmail: Text(
                          widget.response.loginData.dataUsuario.nombrePersonal
                              .trim(),
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              color: Colors.white)),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/images/logorico.png"),
                              fit: BoxFit.fitWidth),
                          color: Colors.blue[800]),
                      margin: const EdgeInsets.all(0.0),
                    )),
                ...itemmenus(),
              ],
            ),
          ),
        ),
        Container(
          //padding: EdgeInsets.only(top: 200),
          height: 65,
          width: MediaQuery.of(context).size.width,
          color: Color.fromRGBO(0, 0, 40, 1),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    ' v$version',
                    style: TextStyle(
                      fontFamily: 'Avenir',
                      fontSize: 20,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  //widthFactor: 3.8,
                ),
              ),
              SizedBox(
                width: 60,
                child: IconButton(
                  icon: Icon(Icons.logout, color: Colors.white),
                  onPressed: () => {
                    /*SystemNavigator.pop(),*/
                    loginBloc.closeSession(),
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginScreen())),
                    blockButton = false
                  },
                ),
              )
            ],
          ),
        )
      ],
    ));
  }

  void loadTestaferrosView() async {
    _repartoReselected.Filas = _vehiculos
        .firstWhere(
            (element) => element.vehiculo == _repartoReselected.Vehiculo)
        .fila;
    _repartoReselected.Columnas = _vehiculos
        .firstWhere(
            (element) => element.vehiculo == _repartoReselected.Vehiculo)
        .columna;
    int numero = await Navigator.push(
        context,
        new MaterialPageRoute<int>(
            builder: (context) =>
                SeleccionTestaferroScreen(
                  _grupoClienteSelected,
                  _tipoRepesoSelected,
                  widget.codigoPuntoVenta,
                  _tipoRepesoVentaDirectaSelected,
                  _ranflaSelected,
                  widget.response.loginData.lotes,
                  _repartoReselected,
                  widget.response,
                  _clientesTestaferro
                )));

    blockButton = false;
    pedidoBloc.saveDataChangue(false).then((value) => setState(() {
          pendientesave = value;
        }));
    getData().then((value) {
      print("Nuevo Reparto: " + numero.toString());
    });
  }
}
