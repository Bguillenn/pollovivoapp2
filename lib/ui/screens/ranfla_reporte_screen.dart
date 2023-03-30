import 'package:flutter/material.dart';
import 'package:pollovivoapp/model/cliente.dart';
import 'package:pollovivoapp/model/ranfla.dart';

class RanflaReporteScreen extends StatefulWidget {
  RanflaReporteScreen();

  @override
  _RanflaReporteScreenState createState() => _RanflaReporteScreenState();
}

class _RanflaReporteScreenState extends State<RanflaReporteScreen> {
  final String title = 'Reporte de ranflas';

  Ranfla _currentRanflaValue;
  Cliente _currentClienteValue;
  bool _tieneClientesRanfla;

  final List<Ranfla> ranflas = [
    Ranfla(123, 17222, 'VXY-745', [123, 124]),
    Ranfla(136, 17895, 'ACV-415', [136, 138]),
    Ranfla(187, 78945, 'ASD-123', [178])
  ];

  final List<Cliente> clientes = [
    Cliente(123, 'Brayan Guillen', 0),
    Cliente(123, 'Brayan Guillen', 0),
    Cliente(123, 'Brayan Guillen', 0),
    Cliente(123, 'Brayan Guillen', 0),
    Cliente(123, 'Brayan Guillen', 0),
  ];

  @override
  void initState() {
    super.initState();
    this._currentRanflaValue = ranflas[0];
    this._tieneClientesRanfla = true;
    this._currentClienteValue = clientes[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppBar(this.title),
      body: renderBody(this.ranflas),
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
          renderRanflaDropdown(ranflas, this._currentRanflaValue),
          Text('Selecciona cliente:', style: subTitlesTextStyle),
          SizedBox(height: 6.0),
          (_tieneClientesRanfla)
              ? renderClienteDropdown(this.clientes, this._currentClienteValue)
              : renderSinElementosContainer(
                  Icons.clear_sharp, 'Esta ranfla no atendio ningun cliente'),
          SizedBox(height: 10.0),
          Text('Detalles del pedido del cliente', style: subTitlesTextStyle),
          SizedBox(height: 6.0),
          (_tieneClientesRanfla)
              ? renderDetalleCliente()
              : Expanded(
                  child: renderSinElementosContainer(
                      Icons.line_style_outlined, 'No hay detalle a mostrar'),
                ),
        ],
      ),
    );
  }

  Widget renderRanflaDropdown(List<Ranfla> ranflas, Ranfla currentValue) {
    return DropdownButton(
      value: currentValue,
      iconSize: 40.0,
      itemHeight: 80.0,
      isExpanded: true,
      items: ranflas.map((ranfla) => createRanflaDropdownItem(ranfla)).toList(),
      onChanged: (Ranfla value) {
        setState(() {
          this._currentRanflaValue = value;
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
          subtitle: Text(ranfla.lotes.toString()),
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
    List<int> colSpan = [2, 3, 3, 2, 2, 2];
    return Column(
      children: [
        createTableHeader(titles, colSpan),
        createTableDetails(colSpan),
      ],
    );
  }

  Widget createTableHeader(List<String> titles, List<int> colSpan) {
    TextStyle headerTextStyle = TextStyle(fontWeight: FontWeight.bold);
    return ListTile(
      title: Row(children: [
        createCellWidget(titles[0], colSpan[0], headerTextStyle, TextAlign.start),
        createCellWidget(titles[1], colSpan[1], headerTextStyle, TextAlign.start),
        createCellWidget(titles[2], colSpan[2], headerTextStyle, TextAlign.start),
        createCellWidget(titles[3], colSpan[3], headerTextStyle, TextAlign.start),
        createCellWidget(titles[4], colSpan[4], headerTextStyle, TextAlign.start),
        createCellWidget(titles[5], colSpan[5], headerTextStyle, TextAlign.start),
      ]),
      tileColor: Colors.amber[50],
    );
  }

  Widget createCellWidget(String text, int colSpan, TextStyle style, TextAlign align) {
    return Flexible(
        child: Container(
          decoration: BoxDecoration(
            border: Border.symmetric(
              vertical: BorderSide(color: Color.fromRGBO(0, 0, 0, 0.5))
            )),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(text, style: style, textAlign: align),
          )
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
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: Row(children: [
                      createCellWidget('100', colSpan[0], null, null),
                      createCellWidget('123', colSpan[1], null, null),
                      createCellWidget('01102', colSpan[2], null, null),
                      createCellWidget('3000', colSpan[3], null, null),
                      createCellWidget('2000', colSpan[4], null, null),
                      createCellWidget('15000', colSpan[5], null, null)
                    ])),
            ]),
          ),
        );
  }
}
