
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollovivoapp/bloc/login_bloc.dart';
import 'package:pollovivoapp/bloc/pedido_bloc.dart';
import 'package:pollovivoapp/model/cliente.dart';
import 'package:pollovivoapp/model/login_response.dart';
import 'package:pollovivoapp/model/lote.dart';
import 'package:pollovivoapp/model/pedido_item.dart';
import 'package:pollovivoapp/model/ranfla.dart';
import 'package:pollovivoapp/model/save_request.dart';
import 'package:pollovivoapp/model/tipo_repeso.dart';
import 'package:pollovivoapp/ui/screens/pesaje_screen.dart';
import 'package:pollovivoapp/ui/screens/transferencia_historial_screen.dart';


class TransferenciaScreen extends StatefulWidget {
  final List<Ranfla> ranflas;
  final List<Lote> lotes;
  final List<TipoRepeso> tiposPollo;
  final LoginResponse loginResponse;
  final int puntoVenta;
  const TransferenciaScreen({@required this.ranflas, @required this.lotes, @required this.tiposPollo, @required this.loginResponse, @required this.puntoVenta});

  @override
  _TransferenciaScreenState createState() => _TransferenciaScreenState();
}

class _TransferenciaScreenState extends State<TransferenciaScreen> {
  final String title = 'Transferencias a plantas';
  final TipoRepeso _tipoPolloEmpty = TipoRepeso(-1, ''); //Para mostrar la opcion de seleccion un tipo de pollo
  Ranfla _ranflaSelected;
  Lote _loteSelected;
  TipoRepeso _tipoPolloSelected;


  @override
  void initState() {
    super.initState();
    this._ranflaSelected = this.widget.ranflas[0];
    this._tipoPolloSelected = this._tipoPolloEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if(this.widget.ranflas == null || this.widget.ranflas.length == 0) return Center(child: Text('No hay ranflas disponibles'));
    return Scaffold(
      appBar: renderAppBar(context),
      body: renderBody(context),
      floatingActionButton: renderFloatingActionButton(context),
    );
  }

  Widget renderFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async{
         List<int> loteData = await Navigator.push(
          context,
          new MaterialPageRoute<List<int>>(
              builder: (context) => TransferenciaHistorialScreen(lotes: this.widget.lotes, puntoVenta: this.widget.puntoVenta)));
        
        //Buscamos el lote que anulo la transferencia y le añadimos las unidades disponibles [0] Numero de sublote [1] Unidades que se anularon de transferencias tienen que sumarse denuevo
        //Tambien actualizamos la ranfla con las unidades disponibles
        setState(() {
              if(loteData != null) {
                this.widget.lotes.firstWhere((lote) => lote.numero == loteData[0]).disponible += loteData[1];
                this.widget.ranflas.firstWhere((ranfla) => ranfla.lotes.contains(loteData[0])).disponible += loteData[1];
              }
        });
      },
      label: Row(children: [
        Icon(Icons.list_alt_outlined),
        SizedBox(width: 8.0),
        Text('Historial')
      ],),
    );
  }

  Widget renderAppBar(BuildContext context) {
    return AppBar(
      title: Text(this.title)
    );
  }

  Widget renderBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          renderDropdownRanflas(context),
          SizedBox(height: 8.0),
          renderRanflaSubLotes(context, 
            this._ranflaSelected,
            this.widget.lotes.where((lote) => this._ranflaSelected.lotes.contains(lote.numero)).toList()),
          SizedBox(height: 16.0),
          renderDropdownTipopollo(context),
          SizedBox(height: 60.0),
          renderButton(context)
        ],
      ),
    );
  }

  Widget renderDropdownRanflas(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selecciona la ranfla:'),
        SizedBox(height: 8.0,),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
          child: DropdownButton<Ranfla>(
              value: _ranflaSelected,
              items: [
                ...this.widget.ranflas.map((ranfla) =>  
                  DropdownMenuItem(
                    child: Text('Lotes: ${ranfla.lotes} | ${ranfla.placa.trim()} | UND: ${ranfla.disponible}',
                              style: TextStyle(color: ranfla.disponible <= 0 ? Colors.red : Colors.black)
                            )
                    , value: ranfla)
                ).toList()
              ],
              onChanged: (Ranfla newValue) =>
                  setState(() => _ranflaSelected = newValue),
              iconSize: 30.0,
              isExpanded: true,
              underline: SizedBox(),
            ),
        )
      ],
    );
  }

  Widget renderDropdownTipopollo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selecciona el tipo de pollo:'),
        SizedBox(height: 8.0,),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
          child: DropdownButton<TipoRepeso>(
              value: _tipoPolloSelected,
              items: [
                DropdownMenuItem<TipoRepeso>(child: Text('Selecciona un tipo de pollo', style: TextStyle(color: Colors.black54),), value: _tipoPolloEmpty),
                ...this.widget.tiposPollo.map((tipo) =>  
                  DropdownMenuItem(
                    child: Text('${tipo.nombre}')
                    , value: tipo)
                ).toList()
              ],
              onChanged: (TipoRepeso newValue) =>
                  setState(() => _tipoPolloSelected = newValue),
              iconSize: 30.0,
              isExpanded: true,
              underline: SizedBox(),
            ),
        )
      ],
    );
  }

  Widget renderRanflaSubLotes(BuildContext context, Ranfla ranfla, List<Lote> lotes) {
    //this._loteSelected = null;
    double buttonListWidth = MediaQuery.of(context).size.width - 100 - 16;
    return Container(
      height: 100.0,
      padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            width: 50.0,
            color: Colors.black87,
            child: RotatedBox(
              quarterTurns: 3,
              child: Center(
                  child: Text(ranfla.placa.trim(),
                      style: TextStyle(
                          color: Colors.white, fontSize: 20))),
            )),
            ListView.builder(
              itemCount: lotes.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) => buildSubLoteItem(
                context,
                lote: lotes[i],
                size: buttonListWidth / lotes.length,
                index: i
              ),
            )
        ],
      ),
    );
  }

  Widget buildSubLoteItem(BuildContext context, {Lote lote, double size, int index}) {
    double radio = 0, borders = 0, elevation = 0;
    TextStyle styleTextLote = TextStyle(
      fontSize: 14,
      color: Colors.white,
    );
    Color relleno = colorLote(lote, index);
    if (_loteSelected != null && _loteSelected.numero == lote.numero) {
      radio = 8;
      borders = 2;
      elevation = 10;
      relleno = relleno.withOpacity(0.8);
    }

    return GestureDetector(
      child: Material(
        borderRadius: BorderRadius.circular(radio),
        elevation: elevation,
        child: Container(
              height: 100,
              width: size - 2,
              margin: const EdgeInsets.only(left: 1, right: 1),
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radio),
                  border: Border.all(color: relleno, width: borders),
                  color: relleno),
              child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Und: " + lote.disponible.toString(),
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text(
                        lote.codigo,
                        style: styleTextLote,
                      ),
                      Text(lote.descripcion.replaceAll("POLLO VIVO", "PV"),
                          style: styleTextLote),
                      Text(lote.numero.toString(), style: styleTextLote)
                    ],
                  ))),
      ),
      onTap: () {
        this.setState(() {
          this._loteSelected = lote;
        });
      }
    );
  }

  Widget renderButton(BuildContext  context) {
    return SizedBox(
      width: double.infinity,
      height: 50.0,
      child: ElevatedButton(
          child: Text('CONTINUAR'),
          onPressed: () async {
            //Validamos que eligio un tipo de pollo
            if(_tipoPolloSelected == _tipoPolloEmpty){
              Fluttertoast.showToast(
                msg: "Debe seleccion un tipo de pollo",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              return;
            }
            //Validamos si selecciono un sublote y que el elegido le pertenezca a la ranfla actual
            if(_loteSelected == null || _loteSelected.lotePrincipal != _ranflaSelected.lotePrincipal){
              Fluttertoast.showToast(
                msg: "Debe seleccionar un lote",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              return;
            }

            //Validamos que el tenga unidades para devolver el lote
            if(_ranflaSelected.sinUnidades() || _loteSelected.disponible <= 0){
              Fluttertoast.showToast(
                msg: "El lote ya no tiene unidades",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              return;
            }

          int totalUnidades = await Navigator.push(
          context,
          new MaterialPageRoute<int>(
              builder: (context) => PesajeScreen(
                  _tipoPolloSelected.codigo == 4 ? TipoRepeso(12, 'TRANSFERENCIA MUERTO') : TipoRepeso(13, 'TRANSFERENCIA VIVO'),
                  null,
                  _loteSelected,
                  39, //Corregir punto de venta que sea dinamico
                  PedidoItem(-1, 1, _loteSelected.codigo, 0),
                  widget.loginResponse,
                  null,
                  'TRANSFERENCIA A PLANTAS',
                  true,
                  List<Cliente>.empty(), 
                  TipoRepeso(0, 'Venta Acopio/Directa'),
                  onSaveCallBack: saveDataPesajes,)));
            setState(() {
              _loteSelected.disponible = _loteSelected.disponible - totalUnidades;
            });
          }
        ),
    );
  }

  Future<dynamic> saveDataPesajes(BuildContext context, SaveRequest request) async {
    return await pedidoBloc.saveDataPesajes(request).then((response) async {
      return response;
    }).onError((error, stackTrace) => throw error);
  }

  Color colorLote(Lote lote, int index) {
    if (lote.codigo == '01102' || lote.codigo == '01103')
      return Colors.pink[700];
    else if (lote.codigo == '01120')
      return Colors.blue[900];
    else
      return loginBloc.colors[index];
  }
}