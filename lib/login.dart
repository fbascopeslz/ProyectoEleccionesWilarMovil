import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'global.dart';



class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool sw = false;

  //clase usada para controlar los ids de los EditText
  TextEditingController controllerUser = new TextEditingController();
  TextEditingController controllerPass = new TextEditingController();

  String mensaje = '';


  Future<void> login() async {  
    final response = await http.post(
      //url del servicio
      URL_LOGIN,
      //parametros
      body: {
        "login": controllerUser.text.trim().toLowerCase(),
        "password": controllerPass.text.trim().toLowerCase(),
      }
    );

    if (response.statusCode == 200) { //200 -> response is succesful      
      var paquete = json.decode(response.body);
      if (paquete['error'] == 0) {
        //Variables globles del usuario                              
        globalIdUsuario = paquete['values']['id'];
        globalUsuario = paquete['values']['login'].toString();
        globalNombres = paquete['values']['nombre'].toString();
        globalApellidos = paquete['values']['apellido'].toString();
        globalEmailUsuario = paquete['values']['correo'].toString();
        //Navigator.pop(context);        
        Navigator.pushReplacementNamed(context, '/Home');                    
      } else { 
        Navigator.pop(context);    
        Fluttertoast.showToast(
          msg: paquete['message'],
          toastLength: Toast.LENGTH_SHORT,
        );              
      }    
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Fallo al conectar a Internet, porfavor intente de nuevo",
        toastLength: Toast.LENGTH_SHORT,
      );
    }    
  }



  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  Widget build(BuildContext context) {

    final emailField = TextField(
      controller: controllerUser,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Usuario o Email",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final passwordField = TextField(
      controller: controllerPass,
      obscureText: true,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () async {

          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return Center(child: CircularProgressIndicator(),);
            }
          );
          await login();
          //Navigator.pop(context);

        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
      child: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 80.0),
                SizedBox(                  
                  height: 155.0,
                  child: Image.asset(
                    "assets/images/elecciones2020.jpg",
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 45.0),
                emailField,
                SizedBox(height: 25.0),
                passwordField,
                SizedBox(
                  height: 35.0,
                ),
                loginButon,
                SizedBox(
                  height: 15.0,
                ),
              ],
            ),
          ),
        ),
      ),
        )
    );
    
  }


}//end class