import 'dart:async';
import 'package:path/path.dart';
import 'package:pollovivoapp/model/pesaje_detalle_item.dart';
import 'package:pollovivoapp/model/save_request.dart';
import 'package:pollovivoapp/model/save_request_cab.dart';
import 'package:pollovivoapp/model/usuario_sesion.dart';
import 'package:sqflite/sqflite.dart';


class DBLocal {
  Future<Database> database;

  DBLocal(){
    _createDb();
  }

  // Estados de Registro
  // P = Procesando, a la espera de respuesta de envio a la BD
  // C = Cerrado, fue enviado correctamente
  // E = Erroneo, Error de envio
  // N = Nuevo Registro, registro nuevo, pendiente de envio
  void _createDb() async
  {
    try{
      database =  openDatabase( join( await getDatabasesPath(), 'pesajes.db'),
        onCreate: (db, version) async
        {
          // call database script that is saved in a file in assets
          String script = "CREATE TABLE RepesoPolloVivoCabecera(PuntoVenta INTEGER NOT NULL, Uuid TEXT NOT NULL, Numero INTEGER NOT NULL, Cliente INTEGER, LoteNumero INTEGER, LotesNumero TEXT, Pedido INTEGER, ItemPedido INTEGER, Tipo INTEGER, NumeroPR INTEGER, ItemPR INTEGER, ItemsPR TEXT,Estado TEXT,FechaRegistro TEXT,Observacion TEXT,nClienteTestaferro INTEGER,nPedidoTestaferro INTEGER,nTipoBalanza INTEGER, PRIMARY KEY ( PuntoVenta, Uuid, Numero));CREATE TABLE RepesoPolloVivoDetalle(Numero INTEGER NOT NULL, Uuid TEXT NOT NULL, Item INTEGER NOT NULL, Jabas INTEGER, Unidades INTEGER, Kilos REAL,FechaRegistro TEXT,nEstado INTEGER, nTipoBalanza INTEGER, PRIMARY KEY (Numero, Uuid, Item));CREATE TABLE Session(Usuario TEXT,Cookie TEXT);CREATE TABLE Impresora(Imp TEXT)";
          List<String> scripts = script.split(";");
          scripts.forEach((v)   //, SubTotal INTEGER, Estado INTEGER
          {
            if(v.isNotEmpty )
            {
              print(v.trim());
              db.execute(v.trim());
            }
          });

        },
        version: 2,
      );
      var a = 1;
    }
    catch(e){
      var a = 1;
    }

  }
  void deleteDB() async{
    DatabaseFactory test;
    deleteDatabase(join( await getDatabasesPath(), 'pesajes.db'));

  }
  void createDb2() async
  {
    if(database == null) await _createDb();
  }

  Future<int> addSession(String Username,String Cookie) async{

    try{
      final db = await database;
      Map<String, dynamic> tuple =  {
        "Usuario": Username,
        "Cookie": Cookie,
      };
      await db.insert(
        'Session',
        tuple,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return 1;
    }catch(e){
      var a = 1;
    }

  }
  Future<int> cerrarSesion() async{
    final db = await database;
    await db.delete('Session');
    return 1;
  }
  Future<UsuarioSesion> getSession() async{
    final db = await database;
    List<Map<String, dynamic>> resultQuery;
    resultQuery = await db.rawQuery('SELECT Usuario,Cookie FROM Session');
    if(resultQuery.length>0)
      return UsuarioSesion.fromJson(resultQuery[0]);
    else return null;
  }

  Future<String> getPrintServer() async{
    try{
      final db = await database;
      List<Map<String, dynamic>> resultQuery;
      resultQuery = await db.rawQuery('SELECT Imp FROM Impresora');
      if(resultQuery.length>0)
        return resultQuery[0]['Imp'];
      else return "";
    }catch(e){
      var a = 1;
    }

  }

  Future<int> cleanImpresora() async{
    final db = await database;
    await db.delete('Impresora');
    return 1;
  }

  Future<void> addImpresora(String imp) async {
    final db = await database;
    Map<String, dynamic> tuple =  {
      "Imp": imp,
    };
    await db.insert(
      'Impresora',
      tuple,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

  }

  Future<List<SaveRequestCab>> pesajes() async {
    // Get a reference to the database.
    final db = await database;
    final List<Map<String, dynamic>> resultQuery = await db.query('RepesoPolloVivoCabecera');
    return  List<SaveRequestCab>.from(resultQuery.map((item) => SaveRequestCab.fromJson2(item)));
  }

  Future<List<SaveRequestCab>> pesajesCabecera(String Estado) async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> resultQuery = await db.rawQuery('SELECT * FROM RepesoPolloVivoCabecera WHERE Estado=?', [Estado]);
    //final List<Map<String, dynamic>> resultQuery = await db.query('RepesoPolloVivoCabecera');
    return  List<SaveRequestCab>.from(resultQuery.map((item) => SaveRequestCab.fromJson2(item)));
  }

  Future<List<SaveRequestCab>> pesajesPendientes() async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> resultQuery = await db.rawQuery('SELECT * FROM RepesoPolloVivoCabecera WHERE Estado = ? or Estado = ?', ["N","E"]);
    //final List<Map<String, dynamic>> resultQuery = await db.query('RepesoPolloVivoCabecera');
    return  List<SaveRequestCab>.from(resultQuery.map((item) => SaveRequestCab.fromJson2(item)));
  }

  Future<List<PesajeDetalleItem>> pesajesDetalle(String Uuid) async {
    // Get a reference to the database.
    final db = await database;
    final List<Map<String, dynamic>> resultQuery = await db.rawQuery('SELECT * FROM RepesoPolloVivoDetalle WHERE Uuid=?', [Uuid]);
    //final List<Map<String, dynamic>> resultQuery = await db.query('RepesoPolloVivoDetalle');
    return  List<PesajeDetalleItem>.from(resultQuery.map((item) => PesajeDetalleItem.fromJson2(item)));
  }

  // Define a function that inserts dogs into the database
  Future<void> insertPesaje(SaveRequest pesaje) async {
    // Get a reference to the database.
    try{
      final db = await database;

      // Insert the Dog into the correct table. You might also specify the
      // `conflictAlgorithm` to use in case the same dog is inserted twice.
      //
      // In this case, replace any previous data.
      await db.insert(
        'RepesoPolloVivoCabecera',
        pesaje.oCabecera.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for(var item in pesaje.oDetalle){
        await db.insert(
          'RepesoPolloVivoDetalle',
          item.toJson2(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }catch(e){
      var a = 1;
      throw e;
    }

  }

  Future<void> updatePesaje(SaveRequestCab pesaje) async {
    // Get a reference to the database.
    final db = await database;
    // Update the given Dog.
    await db.update('RepesoPolloVivoCabecera', pesaje.toJson(),where: 'Uuid = ?',whereArgs: [pesaje.Uuid],
    );
  }
  Future<void> cleanPesajes() async {
    final db = await database;
    final List<Map<String, dynamic>> resultQuery = await db.rawQuery('SELECT * FROM RepesoPolloVivoCabecera ');
    var listDelete = List<SaveRequestCab>.from(resultQuery.map((item) => SaveRequestCab.fromJson2(item)));
    for(var item in listDelete){
        await db.delete('RepesoPolloVivoDetalle',
          // Use a `where` clause to delete a specific dog.
          where: 'Uuid = ?',
          // Pass the Dog's id as a whereArg to prevent SQL injection.
          whereArgs: [item.Uuid],
        );
        await db.delete('RepesoPolloVivoCabecera',
          // Use a `where` clause to delete a specific dog.
          where: 'Uuid = ?',
          // Pass the Dog's id as a whereArg to prevent SQL injection.
          whereArgs: [item.Uuid],
        );
    }
  }
  Future<void> deletePesajes(String Estado) async {
    // Get a reference to the database.
    final db = await database;
    final List<Map<String, dynamic>> resultQuery = await db.rawQuery('SELECT * FROM RepesoPolloVivoCabecera WHERE Estado=?', [Estado]);
    var listDelete = List<SaveRequestCab>.from(resultQuery.map((item) => SaveRequestCab.fromJson2(item)));
    for(var item in listDelete){
      Duration difference = DateTime.now().difference(item.FechaRegistro);
      if(difference.inHours>24){
        await db.delete('RepesoPolloVivoDetalle',
          // Use a `where` clause to delete a specific dog.
          where: 'Uuid = ?',
          // Pass the Dog's id as a whereArg to prevent SQL injection.
          whereArgs: [item.Uuid],
        );
        await db.delete('RepesoPolloVivoCabecera',
          // Use a `where` clause to delete a specific dog.
          where: 'Uuid = ?',
          // Pass the Dog's id as a whereArg to prevent SQL injection.
          whereArgs: [item.Uuid],
        );
      }
    }
    // Remove the Dog from the database.
  }





}
