import 'package:flutter/material.dart';
import 'package:proyecto_examen_elecciones/login.dart';
import 'package:proyecto_examen_elecciones/reconocimientoTexto.dart';
import 'global.dart';
import 'home.dart';


void main() => runApp(Main());


class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //desactivar la etiquetita modo debug      
      debugShowCheckedModeBanner: false,

      title: NOMBRE_APP,
      home: LoginPage(),
      routes: <String, WidgetBuilder> {
        '/Login': (BuildContext context) => new LoginPage(),
        '/Home': (BuildContext context) => new HomePage(),
        '/ReconocimientoTexto': (BuildContext context) => new ReconocimientoTexto(),                   
        
      }
    );
  }

}//end class