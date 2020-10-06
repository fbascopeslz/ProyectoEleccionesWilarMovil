import 'package:barcode_scan/platform_wrapper.dart';
import 'package:flutter/material.dart';

import 'global.dart';
import 'package:http/http.dart' as http;
import "package:fluttertoast/fluttertoast.dart";
import 'dart:convert';
import 'dart:async';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String numeroCodigoBarras = '';  

  Future _scan() async {    
  
    var result = await BarcodeScanner.scan();    
    print(result.type); // The result type (barcode, cancelled, failed)
    print(result.rawContent); // The barcode content
    print(result.format); // The barcode format (as enum)
    print(result.formatNote); // If a unknown format was scanned this field contains a note

    if (result != null && result.rawContent != '') {
      numeroCodigoBarras = result.rawContent;
      verificarNumeroMesa();
    } else {
      Navigator.pop(context);

      Fluttertoast.showToast(
        msg: "Porfavor vuelva a escanear el codigo de barras",
        toastLength: Toast.LENGTH_SHORT,
      ); 
    }
  }

  Future<void> verificarNumeroMesa() async {    
    final response = await http.post(
      //url del servicio
      URL_VERNUMMES,
      //parametros
      body: {
        "numero": numeroCodigoBarras.toString(),
        "idUsuario": globalIdUsuario.toString()
      }
    );

    //Cerrar el CircularProgressDialog
    Navigator.pop(context);
  
    if (response.statusCode == 200) { //200 -> response is succesful     
      var paquete = json.decode(response.body);      

      //error 0 => Ya se envio la imagen, mostrar la imagen
      //error 1 => Error del servidor
      //error 2 => El usuario no es delegado asignado a esa mesa
      //error 3 => Aun no se envio la imagen, mostrar informacion de la mesa

      switch (paquete['error']) {
        case 0:                    
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Envio de imagen'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(paquete['message']),
                      SizedBox(height: 30),
                      Image.network(paquete['values']["imagen"]),
                      SizedBox(height: 30),
                      Text("HORA: " + paquete['values']["hora"]),
                      SizedBox(height: 5),
                      Text("FECHA: " + paquete['values']["fecha"]),                                        
                    ]
                  ),
                ),

                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();                        
                    },
                    child: Text('ACEPTAR'),
                  ),                                  
                ],
              );
            }
          );          
        break;
          
        case 1:                
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Envio de imagen'),
                content: Text(paquete['message']),
                actions: <Widget>[                    
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();                        
                    },
                    child: Text('ACEPTAR'),
                  )
                ],
              );
            }
          );
          break;

        case 2:                    
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Envio de imagen'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(paquete['message']),
                    SizedBox(height: 30),
                    Text("NUMERO DE MESA ENVIADO: " + numeroCodigoBarras.toString()),
                  ],
                ),
                actions: <Widget>[                                      
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();                        
                    },
                    child: Text('ACEPTAR'),
                  )
                ],
              );
            }
          );
        break;

        case 3:        
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Envio de imagen'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(paquete['message']),
                      SizedBox(height: 30),
                      Text("NUMERO MESA: " + paquete['values']["numero"].toString()),
                      SizedBox(height: 5),
                      Text("DEPARTAMENTO: " + paquete['values']["departamento"]),
                      SizedBox(height: 5),
                      Text("PROVINCIA: " + paquete['values']["provincia"]),
                      SizedBox(height: 5),
                      Text("LOCALIDAD: " + paquete['values']["localidad"]),
                      SizedBox(height: 5),
                      Text("RECINTO: " + paquete['values']["recinto"]),                                       
                    ]
                  ),
                ),
                actions: <Widget>[                                      
                  FlatButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/ReconocimientoTexto');                        
                    },
                    child: Text('ACEPTAR'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();                        
                    },
                    child: Text('CANCELAR'),
                  ),                  
                ],
              );
            }
          );          
        break;

        default:
      }      

    } else {
      Fluttertoast.showToast(
        msg: "Fallo al conectar a Internet, porfavor intente de nuevo",
        toastLength: Toast.LENGTH_SHORT,
      );
    }    
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(NOMBRE_APP), 
        backgroundColor: Colors.redAccent,
      ),
    
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[            
            Image.asset('assets/images/userandroid.png', width: 200,),
            SizedBox(height: 30),
            Text("Usuario: $globalNombres $globalApellidos", style: TextStyle(fontSize: 15),),
            SizedBox(height: 100),
            RaisedButton.icon(
              textColor: Colors.white,
              color: Color(0xFF6200EE),
              onPressed: () async {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return Center(child: CircularProgressIndicator(),);
                  }
                );
                await _scan();                

              },
              icon: Icon(Icons.camera, size: 30),
              label: Text("ENVIAR RESULTADOS"),
            ),
            SizedBox(height: 10),
            RaisedButton.icon(
              textColor: Colors.white,
              color: Color(0xFF6200EE),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/Login');
              },
              icon: Icon(Icons.exit_to_app, size: 30),
              label: Text("CERRAR SESION"),
            ),

          ],
        ),        
      ), 
            
    );
  }
}