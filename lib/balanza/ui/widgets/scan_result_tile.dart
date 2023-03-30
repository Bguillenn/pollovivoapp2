import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({this.result, this.onTap}) : super();

  final ScanResult result;
  final VoidCallback onTap;
  int idBalaza(String IdDevice){
    List<int> data= new List<int>.empty(growable: true);
    IdDevice.split(':').forEach((element)=>{
      data.add(int.parse(element, radix: 16))
    });
    return data.reduce((a, b) => a + b);
  }
  Widget _buildTitle(BuildContext context) {
    if (result.device.name.length > 0) {
      var id = idBalaza(result.device.id.toString());
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Rico Pollo "+id.toString(),//result.device.name.contains("HF22")?:result.device.name,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "ID: ${result.device.id.toString()}",
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
    } else {
      return Text(result.device.id.toString());
    }
  }

  Widget _buildAdvRow(BuildContext context, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.caption,
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .apply(color: Colors.black),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]'
        .toUpperCase();
  }

  String getNiceManufacturerData(Map<int, List<int>> data) {
    if (data.isEmpty) {
      return null;
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add(
          '${id.toRadixString(16).toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  String getNiceServiceData(Map<String, List<int>> data) {
    if (data.isEmpty) {
      return null;
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add('${id.toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle(context),
      leading: Text(result.rssi.toString()),
      trailing: RaisedButton(
        
         padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
        color: Colors.blue,
        textColor: Colors.white,
        disabledTextColor: Colors.white, 
        child: Text('Conectar'),
        onPressed: (result.advertisementData.connectable) ? onTap : null,
        //onPressed: (result.advertisementData.serviceUuids.isNotEmpty) ? onTap : null,
      ),
      children: <Widget>[
        _buildAdvRow(context, 'Complete Local Name', result.advertisementData.localName),
        _buildAdvRow(context, 'Tx Power Level','${result.advertisementData.txPowerLevel ?? 'N/A'}'),
        _buildAdvRow(context,'Manufacturer Data',getNiceManufacturerData(result.advertisementData.manufacturerData) ?? 'N/A'),
        _buildAdvRow(context,'Servicio UUIDs',(result.advertisementData.serviceUuids.isNotEmpty)? result.advertisementData.serviceUuids.join(', ').toUpperCase(): 'N/A'),
        _buildAdvRow(context, 'Servicio Data',getNiceServiceData(result.advertisementData.serviceData) ?? 'N/A'),
      ],
    );
  }
}
