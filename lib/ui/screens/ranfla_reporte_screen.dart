import 'package:flutter/material.dart';
import 'package:pollovivoapp/bloc/pedido_bloc.dart';
import 'package:pollovivoapp/model/cliente.dart';
import 'package:pollovivoapp/model/pesada.dart';
import 'package:pollovivoapp/model/ranfla.dart';

class RanflaReporteScreen extends StatefulWidget {
  final List<Ranfla> _ranflas;
  RanflaReporteScreen(this._ranflas);

  @override
  _RanflaReporteScreenState createState() => _RanflaReporteScreenState();
}

class _RanflaReporteScreenState extends State<RanflaReporteScreen> {
  final String title = 'Reporte de ranflas';

  Ranfla _currentRanflaValue;
  Cliente _currentClienteValue;
  bool _tieneClientesRanfla;

  List<Ranfla> ranflas;

  //En estos dos se guardan todos los clientes obtenidos de la peticion al API y las pesadas
  List<Cliente> clientesResponse = [];
  List<Pesada> pesadasResponse = [];

  //En estas dos listas se encuentran los clientes y pesadas que se mostraran cuando se seleccione en el dropdown
  List<Cliente> clientes = [];
  List<Pesada> pesadas = [];

  @override
  void initState() {
    super.initState();
    this.ranflas = widget._ranflas;
    this._currentRanflaValue = null;
    this._tieneClientesRanfla = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppBar(this.title),
      body: FutureBuilder(
        future: pedidoBloc.obtenerReporteDeRanflas('39', this.ranflas),
        builder: (_, snapshot) {
          if(snapshot.hasData){
            this.clientesResponse = snapshot.data.oClientes;
            this.pesadasResponse = snapshot.data.oPesadas;
            if(this._currentRanflaValue == null) {
              this._currentRanflaValue = ranflas[0];
              this.loadPesadasAndClientes(this._currentRanflaValue);
              this._currentClienteValue = this.clientes[0];
            }
            return renderBody(this.ranflas);
          }
          else if(snapshot.hasError){
            return Icon(Icons.error);
          }else
            return CircularProgressIndicator();
        },
      ),
    );
  }

  AppBar renderAppBar(String title) {
    return AppBar(
      title: Text(title),
      actions: [IconButton(onPressed: () => {}, icon: Icon(Icons.download))],
    );
  }

  Widget renderBody(List<Ranfla> ranflas) {
    
    TextStyle subTitlesTextStyle = TextStyle(color: Colors.blue[800]);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Selecciona la ranfla:', style: subTitlesTextStyle),
          SizedBox(height: 6.0),
          renderRanflaDropdown(ranflas),
          Text('Selecciona cliente:', style: subTitlesTextStyle),
          SizedBox(height: 6.0),
          (this.clientes.length > 0)
              ? renderClienteDropdown(this.clientes, this._currentClienteValue)
              : renderSinElementosContainer(
                  Icons.clear_sharp, 'Esta ranfla no atendio ningun cliente'),
          SizedBox(height: 10.0),
          Text('Detalles del pedido del cliente', style: subTitlesTextStyle),
          SizedBox(height: 6.0),
          (this.pesadas.length > 0)
              ? renderDetalleCliente()
              : Expanded(
                  child: renderSinElementosContainer(
                      Icons.line_style_outlined, 'No hay detalle a mostrar'),
                ),
        ],
      ),
    );
  }

  Widget renderRanflaDropdown(List<Ranfla> ranflas) {
    return DropdownButton(
      value: this._currentRanflaValue,
      iconSize: 40.0,
      itemHeight: 80.0,
      isExpanded: true,
      items: ranflas.map((ranfla) => createRanflaDropdownItem(ranfla)).toList(),
      onChanged: (Ranfla newValue) {
        setState(() {
          if(!this._currentRanflaValue.equals(newValue)) {
            loadPesadasAndClientes(newValue);
            
            this._currentClienteValue = this.clientes[0];
          
            this._currentRanflaValue = newValue;
            }
        });
      },
    );
  }

  DropdownMenuItem<Ranfla> createRanflaDropdownItem(Ranfla ranfla) {
    return DropdownMenuItem(
        value: ranfla,
        child: ListTile(
          leading: Icon(Icons.local_shipping, size: 36.0),
          title: Text(ranfla.toString()),
        ));
  }

  Widget renderClienteDropdown(List<Cliente> clientes, Cliente currentCliente) {
    return DropdownButton(
      iconSize: 40.0,
      itemHeight: 50.0,
      isExpanded: true,
      value: currentCliente,
      items: clientes
          .map((cliente) => createClienteDropdownItem(cliente))
          .toList(),
      onChanged: (Cliente value) {
        setState(() {
          print(_currentClienteValue == value);
          this._currentClienteValue = value;
        });
      },
    );
  }

  DropdownMenuItem<Cliente> createClienteDropdownItem(Cliente cliente) {
    return DropdownMenuItem(
      value: cliente,
      child: Text('[${cliente.codigo}] ${cliente.nombre}'),
    );
  }

  Widget renderDetalleCliente() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.05)), //Colors.amber[50]
        child: renderClienteTable(),
      ),
    );
  }

  Widget renderSinElementosContainer(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
      decoration: BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 0.1),
          borderRadius: BorderRadius.circular(10.0)),
      width: double.infinity,
      child: Center(
          child: Column(
            children: [
              Icon(icon, size: 52.0, color: Colors.black38),
              Text(text),
            ],
          )
      ),
    );
  }

  Widget renderClienteTable() {
    List<String> titles = ['#P', 'Lote', 'Prod.', 'KG.', 'J', 'Und'];
    List<int> colSpan = [2, 3, 3, 3, 2, 2];
    return Column(
      children: [
        createTableHeader(titles, colSpan),
        createTableDetails(colSpan),
      ],
    );
  }

  Widget createTableHeader(List<String> titles, List<int> colSpan) {
    TextStyle headerTextStyle = TextStyle(fontWeight: FontWeight.bold);
    return Container(
      child: Row(children: [
        createCellWidget(titles[0], colSpan[0], headerTextStyle, TextAlign.start),
        createCellWidget(titles[1], colSpan[1], headerTextStyle, TextAlign.start),
        createCellWidget(titles[2], colSpan[2], headerTextStyle, TextAlign.start),
        createCellWidget(titles[3], colSpan[3], headerTextStyle, TextAlign.start),
        createCellWidget(titles[4], colSpan[4], headerTextStyle, TextAlign.start),
        createCellWidget(titles[5], colSpan[5], headerTextStyle, TextAlign.start),
      ]),
      decoration: BoxDecoration(color: Colors.amber[50]),
    );
  }

  Widget createCellWidget(String text, int colSpan, TextStyle style, TextAlign align) {
    return Flexible(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
          decoration: BoxDecoration(
            border: Border.symmetric(
              vertical: BorderSide(width: 0.0, color: Color.fromRGBO(0, 0, 0, 0.5))
            )),
          child: Text(text, style: style, textAlign: align)
        ),
        flex: colSpan,
        fit: FlexFit.tight
    );
  }

  Widget createTableDetails(List<int> colSpan) {
    return Expanded(
          child: Container(
            child: ListView(
              children: [
                Divider(
                  color: Color.fromRGBO(0, 0, 0, 0.8),
                ),
                ...createRows(
                  this.pesadas.where(
                    (pesada) => pesada.nCliente == this._currentClienteValue.codigo)
                    .toList(), colSpan)
            ]),
          ),
        );
  }

  List<Widget> createRows(List<Pesada> pedidos, List<int> colSpan) {
    List<Widget> rows = [];
    pedidos.asMap().forEach((i,pedido) {
      rows.add(
        Container(
          decoration: BoxDecoration(
            color: (i%2 != 0) ? Color.fromRGBO(0, 0, 0, 0.030) : null,
            border: Border(
              bottom: BorderSide(
                color: Color.fromRGBO(0, 0, 0, 0.1)
              )
            )
          ),
          child: Row(children: [
            createCellWidget(pedido.nNumero.toString(), colSpan[0], null, null),
            createCellWidget(pedido.nLoteNumero.toString(), colSpan[1], null, null),
            createCellWidget(pedido.cProducto, colSpan[2], null, null),
            createCellWidget(pedido.nKilosTotal.toString(), colSpan[3], null, null),
            createCellWidget(pedido.nJabasTotal.toString(), colSpan[4], null, null),
            createCellWidget(pedido.nUnidadesTotal.toString(), colSpan[5], null, null)
          ]))
      );
    });
    return rows;
  }

  void loadPesadasAndClientes(Ranfla ranfla) {
    this._currentRanflaValue = ranfla;
    this.pesadas = pesadasResponse.where((pesada) => ranfla.lotes.contains(pesada.nLoteNumero)).toList();
    List<Cliente> clientesPesadas = [];
    this.pesadas.forEach((pesada) {
      int clientePesadaCod = pesada.nCliente;
      int indexCliente = clientesPesadas.indexWhere((cliente) => cliente.codigo == clientePesadaCod);
      if( indexCliente == -1)
        clientesPesadas.add(this.clientesResponse.firstWhere((cliente) => cliente.codigo == clientePesadaCod));
    });
    
    this.clientes = clientesPesadas;
    if(clientesPesadas.length == 0) this._tieneClientesRanfla = false;
  }
}
