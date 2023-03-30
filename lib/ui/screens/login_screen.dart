import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollovivoapp/bloc/login_bloc.dart';
import 'package:pollovivoapp/bloc/pedido_bloc.dart';
import 'package:pollovivoapp/model/login_request.dart';
import 'package:pollovivoapp/model/usuario_sesion.dart';
import 'package:pollovivoapp/ui/screens/inicio_pesaje_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Controladores para los INPUT de texto
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _impresoraController = TextEditingController();

  //Variables booleanadas para manejar el estado
  bool _isLoading;
  bool _passwordVisible;

  //Styles
  TextStyle _inputTextStyle = TextStyle(
    color: Colors.black,
    fontFamily: 'Lato',
    fontSize: 18.0,
  );

  //Inicializar componentes
  @override
  void initState() {
    super.initState();
    _isLoading = false;
    _passwordVisible = false;

    impresoraControllerInicio();
    cargarSesionPrevia();
    pedidoBloc.deleteDataLocalPesajes();
  }

  impresoraControllerInicio() async {
    String print = await loginBloc.getPrintServer();
    if (print == "")
      _impresoraController.text = "\\\\serverIMPRESORA\\";
    else
      _impresoraController.text = print;
  }

  configureNuevaImpresora() async {
    loginBloc.impresora = _impresoraController.text;
    await loginBloc.cleanImpresora();
    await loginBloc.addPrintServer(_impresoraController.text);
  }

  cargarSesionPrevia() async {
    UsuarioSesion us = await loginBloc.isLogged();
    if (us != null) {
      loginBloc.loginRepository.loginApiProvider.aToken = us.Cookie;
      loginBloc.impresora = await loginBloc.getPrintServer();
      pedidoBloc.fetchActualizar(us.Usuario).then((response) {
        if (response.nCodError == 0)
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => InicioPesajeScreen(response)));
      });
    }
  }

  iniciarSesion(LoginRequest credenciales) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    loginBloc.conexion(true).then((response) {
      if (response) {
        loginBloc.fetchDataLogin(credenciales).then((response) async {
          if (response.nCodError == 0) {
            await configureNuevaImpresora();
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => InicioPesajeScreen(response)));
          } else {
            setState(() => _isLoading = false);
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
      } else
        setState(() => _isLoading = false);
    });
  }

  onPressedButtonIngresar() async {
    if (_isLoading) return;

    String usuario = _usuarioController.text.trim();
    String password = _passwordController.text.trim();

    await iniciarSesion(LoginRequest(usuario, password));
  }

  // INTERFACE GRAFICA

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          renderLogotipoRP(),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(top: 280.0),
            child:
                Padding(padding: EdgeInsets.all(23.0), child: renderInputs()),
          ),
        ],
      ),
    );
  }

  Widget renderLogotipoRP() {
    return Container(
      margin: const EdgeInsets.fromLTRB(50, 20, 20, 0),
      child: Image.asset(
        'assets/images/logorico.jpg',
        fit: BoxFit.contain,
        width: MediaQuery.of(context).size.width - 100,
      ),
    );
  }

  Widget renderInputs() {
    return ListView(
      children: <Widget>[
        renderInputUsuario(),
        SizedBox(height: 20.0),
        renderInputPassword(),
        SizedBox(height: 30.0),
        renderButtonIngresar(),
        SizedBox(height: 30.0),
        renderInputImpresora(),
      ],
    );
  }

  Widget renderInputUsuario() {
    return Container(
      color: Colors.white,
      child: TextFormField(
        style: _inputTextStyle,
        controller: _usuarioController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Usuario',
          hintText: 'Usuario',
          prefixIcon: Icon(Icons.person),
          labelStyle: TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }

  Widget renderInputPassword() {
    return Container(
        color: Colors.white,
        child: TextFormField(
          style: _inputTextStyle,
          keyboardType: TextInputType.text,
          controller: _passwordController,
          obscureText: !_passwordVisible,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Contraseña',
            hintText: 'Contraseña',
            prefixIcon: Icon(Icons.lock),
            labelStyle: TextStyle(fontSize: 18.0),
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).primaryColorDark,
              ),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
          ),
        ));
  }

  Widget renderButtonIngresar() {
    return MaterialButton(
      onPressed: onPressedButtonIngresar,
      color: Colors.blue,
      textColor: Colors.white,
      child: Text(
        _isLoading ? "CARGANDO..." : "INGRESAR",
      ),
      elevation: 5.0,
      minWidth: 400,
      height: 60,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  Widget renderInputImpresora() {
    return TextField(
      controller: _impresoraController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Impresora',
      ),
    );
  }
}
