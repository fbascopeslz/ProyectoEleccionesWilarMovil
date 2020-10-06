import 'dart:convert';
import 'dart:io';

import 'package:cloudinary_client/cloudinary_client.dart';
import 'package:cloudinary_client/models/CloudinaryResponse.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:http/http.dart' as http;
import "package:fluttertoast/fluttertoast.dart";
import 'global.dart';


class ReconocimientoTexto extends StatefulWidget {
  @override
  _ReconocimientoTextoState createState() => _ReconocimientoTextoState();
}

class _ReconocimientoTextoState extends State<ReconocimientoTexto> {
  File imageFile;

  bool isImageLoaded = false;



  List<SiglaVotos> procesarTextoToArray() {
    List<SiglaVotos> lista = new List();
    
    lista.add(SiglaVotos("VOTOS VALIDOS", 188));
    lista.add(SiglaVotos("VOTOS BLANCOS", 2));
    lista.add(SiglaVotos("VOTOS NULOS", 3));
    lista.add(SiglaVotos("C.C.", 111));
    lista.add(SiglaVotos("FPV", 1));
    lista.add(SiglaVotos("MTS", 1));
    lista.add(SiglaVotos("UCS", 188));
    lista.add(SiglaVotos("MAS-IPSP", 57));
    lista.add(SiglaVotos("21F", 3));
    lista.add(SiglaVotos("PDC", 8));
    lista.add(SiglaVotos("MNR", 1));
    lista.add(SiglaVotos("PAN-BOL", 3));

    return lista;
  }

  Future readText() async {

    //final File imageFile = getImageFile();
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(imageFile);

    final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
    final TextRecognizer cloudTextRecognizer = FirebaseVision.instance.cloudTextRecognizer();
    final DocumentTextRecognizer cloudDocumentTextRecognizer = FirebaseVision.instance.cloudDocumentTextRecognizer();

    final VisionText visionText = await textRecognizer.processImage(visionImage);
    final VisionText visionText2 = await cloudTextRecognizer.processImage(visionImage);
    final VisionDocumentText visionDocumentText = await cloudDocumentTextRecognizer.processImage(visionImage);
    
    //Cerrar el CircularProgressDialog
    Navigator.pop(context);

    String text = visionText.text;
    for (TextBlock block in visionText.blocks) {
      final Rect boundingBox = block.boundingBox;
      final List<Offset> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<RecognizedLanguage> languages = block.recognizedLanguages;

      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        //print(line);
        for (TextElement element in line.elements) {
          // Same getters as TextBlock
          print(element.text);
        }
      }
    }

    print("---------------------------------------------------");

    text = visionDocumentText.text;
    for (DocumentTextBlock block in visionDocumentText.blocks) {
      final Rect boundingBox = block.boundingBox;
      final String text = block.text;
      final List<RecognizedLanguage> languages = block.recognizedLanguages;
      final DocumentTextRecognizedBreak = block.recognizedBreak;

      for (DocumentTextParagraph paragraph in block.paragraphs) {
        // Same getters as DocumentTextBlock
        print(paragraph.text);
        for (DocumentTextWord word in paragraph.words) {
          // Same getters as DocumentTextBlock
          //print(word.text);
          for (DocumentTextSymbol symbol in word.symbols) {
            // Same getters as DocumentTextBlock
            //print(symbol.text);
          }
        }
      }
    }

      
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmacion de envio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(text)
              ]
            )
          ),
          actions: <Widget>[
            FlatButton(
                onPressed: () async {
                  
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      return Center(child: CircularProgressIndicator(),);
                    }
                  );
                  //Guardar en Cloudinary
                  CloudinaryClient client = new CloudinaryClient("676521111585172", "rxxPitlbur0R2gi66OJ9cn2BVPM", "wilarads");
                  CloudinaryResponse response = await client.uploadImage(imageFile.path);
                  print(response.url);
                  //Cerrar el CircularProgressDialog
                  Navigator.pop(context);              


                  
                  //array que contiene las siglas y votos para enviar al servicio
                  List<SiglaVotos> arraySiglaVotos = procesarTextoToArray();

                  Navigator.pop(context); 

                  procesarTextoImagen(arraySiglaVotos, response.url);
                  
                  
                  //Navigator.of(context).pop(); 

                  //Navigator.pushReplacementNamed(context, '/Home');
                  
                },
                child: Text('ACEPTAR')),
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

  }

  Future<void> procesarTextoImagen(List<SiglaVotos> arraySiglaVotos, String urlImagen) async {           
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator(),);
      }
    );
        
    //List<Object> to json
    String arrayJson = jsonEncode(arraySiglaVotos.map((e) => e.toJson()).toList());

    final response = await http.post(
      //url del servicio
      URL_PROCTEXTIMAG,
      //parametros
      body: {
        "idUsuario": globalIdUsuario.toString(),
        "arrayVotos": arrayJson,
        "urlImagen": urlImagen.toString()
      }
    );    

    //Cerrar el CircularProgressDialog
    Navigator.pop(context);
    
    if (response.statusCode == 200) { //200 -> response is succesful     
      var paquete = json.decode(response.body);                
      if (paquete['error'] == 0) {   
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Envio de resultados'),
                content: Text(paquete['message']),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {                      
                      //Cerrar el actual y remplazarla por el Home                      
                      Navigator.of(context).popUntil((route) => route.isFirst);                       
                      Navigator.pushReplacementNamed(context, '/Home');                  
                    },
                    child: Text('ACEPTAR')
                  ),                  
                ],
              );
            }
          );                  
      } else {     
        Fluttertoast.showToast(
          msg: paquete['message'],
          toastLength: Toast.LENGTH_SHORT,
        );              
      }      
    } else {
      Fluttertoast.showToast(
        msg: "Fallo al conectar a Internet, Porfavor intente de nuevo",
        toastLength: Toast.LENGTH_SHORT,
      ); 
    }

  }



  openGallery(BuildContext context) async{
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState((){
      this.imageFile = picture;
      isImageLoaded = true;
    });
    //Navigator.of(context).pop();
  }

  openCamara(BuildContext context) async{
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState((){
      this.imageFile = picture;
      isImageLoaded = true;
    });
    //Navigator.of(context).pop();
  }

  Widget _decideImageView(){
   if (this.imageFile == null){
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 180, 0, 180),
      child: Text('Imagen no seleccionada'),
    );    
   }else{
     return Padding(
      padding: EdgeInsets.fromLTRB(0, 30, 0, 30),
      child: Image.file(this.imageFile, width: 400, height: 400),
    ); 
   }
 }

  Future<void> verificarImagenNula() async {
    if (isImageLoaded == false) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Confirmacion de envio'),
            content: Text("Porfavor seleccione una imagen de la Galeria o saque una foto con la camara"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {                                                                  
                  Navigator.of(context).pop();                   
                },
                child: Text('ACEPTAR')
              ),                        
            ],
          );
        }
      );
    } else {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator(),);
        }
      );
      await readText();
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text("Envio de imagen"),
      ),

      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[

              _decideImageView(),

              RaisedButton(
                onPressed: (){
                  openGallery(context);
                },
                child: Text("Galeria"),
              ),

              RaisedButton(
                onPressed: (){
                  openCamara(context);
                },
                child: Text("Camara"),
              ),

              RaisedButton(
                onPressed: () {
                  verificarImagenNula();
                },
                child: Text("Leer Texto"),
              )
            ],
          ),
        ),
      ),
    );
  }
  
}//end class


//class para el array de envio al service
class SiglaVotos {
  String sigla;
  int votos;

  SiglaVotos(String sigla, int votos) {
    this.sigla = sigla;
    this.votos = votos;
  }

  Map<String, dynamic> toJson() => {
    'sigla': sigla,
    'votos': votos,
  };

}