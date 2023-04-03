import 'package:flutter/material.dart';
import 'package:pollovivoapp/bloc/pedido_bloc.dart';
import 'package:pollovivoapp/model/cliente.dart';
import 'package:pollovivoapp/model/lote.dart';
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

  List<Ranfla> ranflas;

  DateTime fechaSeleccionada;

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
    this.fechaSeleccionada = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle subTitlesTextStyle = TextStyle(color: Colors.blue[800]);
    return Scaffold(
      appBar: renderAppBar(this.title),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selecciona una fecha', style: subTitlesTextStyle),
          renderDateButton(),
          renderDynamicContent(),
        ],
      ),
    );
  }

  AppBar renderAppBar(String title) {
    return AppBar(
      title: Text(title),
    );
  }

  FutureBuilder renderDynamicContent() {
    return FutureBuilder(
        future: pedidoBloc.obtenerReporteDeRanflas('39', this.fechaSeleccionada),
        builder: (_, snapshot) {
          if(snapshot.hasData){
            if(snapshot.data.oLotes.length <= 0)
              return Expanded(child: renderSinElementosContainer(Icons.error, "No hay datos para la fecha seleccionada"));
            print(snapshot.data.oLotes);
            this.clientesResponse = [];
            this.ranflas = [];
            this.pesadasResponse = [];
            this.clientesResponse = snapshot.data.oClientes;
            this.pesadasResponse = snapshot.data.oPesadas;
            this.ranflas = generarRanflas(snapshot.data.oLotes);
            if(this._currentRanflaValue == null) {
              this._currentRanflaValue = ranflas[0];
              this.loadPesadasAndClientes(this._currentRanflaValue);
              this._currentClienteValue = this.clientes[0];
            }
            return renderBody();
          }
          else if(snapshot.hasError){
            print(snapshot.error);
            return Icon(Icons.error);
          }else
            return CircularProgressIndicator();
        },
      );
  }

  Widget renderDateButton() {
    return MaterialButton(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Fecha',
                        style: TextStyle(fontSize: 14),
                      ),
                      Icon(const IconData(0xe03a, fontFamily: 'MaterialIcons')),
                      Text(
                        '${fechaSeleccionada.year}/${fechaSeleccionada.month}/${fechaSeleccionada.day}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    DateTime newDate = await showDatePicker(
                      context: context,
                      locale: const Locale("es", "ES"),
                      initialDate: fechaSeleccionada,
                      firstDate: DateTime(DateTime.now().year - 1),
                      lastDate: DateTime(DateTime.now().year + 1),
                    );
                    fechaSeleccionada = newDate ?? fechaSeleccionada;
                    setState(() {});
                  });
  }

  Widget renderBody() {
    
    TextStyle subTitlesTextStyle = TextStyle(color: Colors.blue[800]);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Selecciona la ranfla:', style: subTitlesTextStyle),
            SizedBox(height: 6.0),
            (this.ranflas.length > 0)
                ? renderRanflaDropdown(this.ranflas)
                : renderSinElementosContainer(Icons.local_shipping, "No hay ranflas el dia seleccionado"),
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
      ),
    );
  }

  Widget renderRanflaDropdown(List<Ranfla> ranflas) {

    DropdownButton dropdown = DropdownButton(
      value: this._currentRanflaValue,
      iconSize: 40.0,
      itemHeight: 80.0,
      isExpanded: true,
      items: ranflas.map((ranfla) => createRanflaDropdownItem(ranfla)).toList(),
      onChanged: (newValue) {
        setState(() {
          if(!this._currentRanflaValue.equals(newValue)) {
            loadPesadasAndClientes(newValue);
            
            this._currentClienteValue = this.clientes[0];
          
            this._currentRanflaValue = newValue;
          }
        });
      },
    );
    return dropdown;
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
    TextStyle headerTextStyle = TextStyle(fontWeight: FontWeight.bold, color: Colors.white);
    return Container(
      child: Row(children: [
        createCellWidget(titles[0], colSpan[0], headerTextStyle, TextAlign.start),
        createCellWidget(titles[1], colSpan[1], headerTextStyle, TextAlign.start),
        createCellWidget(titles[2], colSpan[2], headerTextStyle, TextAlign.start),
        createCellWidget(titles[3], colSpan[3], headerTextStyle, TextAlign.start),
        createCellWidget(titles[4], colSpan[4], headerTextStyle, TextAlign.start),
        createCellWidget(titles[5], colSpan[5], headerTextStyle, TextAlign.start),
      ]),
      decoration: BoxDecoration(color: Colors.blue),
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
            color: (i%2 != 0) ? Color.fromRGBO(255,255,255,0.7) : Colors.white,
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
  }

  List<Ranfla> generarRanflas(List<Lote> lotes) {
    List<Ranfla> ranflas = [];
    lotes.forEach((lote) {
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
    this.ranflas = ranflas.toList();
    if (this._currentRanflaValue != null) {
      this._currentRanflaValue = this.ranflas.firstWhere((element) =>
          this._currentRanflaValue.placa == element.placa &&
          this._currentRanflaValue.viaje == element.viaje);
    } else {
      this._currentRanflaValue = ranflas[0] ?? null;
    }
    return ranflas;
  }

}
