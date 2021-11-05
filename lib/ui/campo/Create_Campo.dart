import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto/object/Campo.dart';
import 'package:projeto/service/firebaseService.dart';

class CreateCampo extends StatefulWidget {
  final String estabelecimentoId;

  const CreateCampo({Key key, this.estabelecimentoId}) : super(key: key);
  @override
  _CreateCampoState createState() => _CreateCampoState();
}

class _CreateCampoState extends State<CreateCampo> {
  FirebaseService firebaseService = new FirebaseService(FirebaseAuth.instance);

  final nomeController = new TextEditingController();
  final limiteJogadores = new TextEditingController();
  final comprimentoController = new TextEditingController();
  final larguraController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Cria Campo",
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(10.0 ),
            color: Colors.white,
            height: 400.0,
            child: Column(
              children: [
                Container(
                  child: Text(
                    "CADASTRO",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 15.0),
                  child: TextField(
                    controller: nomeController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0)
                      ),
                      labelText: "Nome",
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 15.0),
                  child: TextField(
                    controller: limiteJogadores,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0)
                      ),
                      labelText: "Limite jogadores",
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    new Flexible(
                      flex: 5,
                      child: TextField(
                        controller: comprimentoController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0)
                          ),
                          labelText: "Comprimento",
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    new Flexible(
                      flex: 5,
                      child: TextField(
                        controller: larguraController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0)
                          ),
                          labelText: "Largura",
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                RaisedButton(
                    color: Colors.black,
                    child: Container(
                      child: Text(
                        "Cadastrar",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    onPressed: () {
                      firebaseService.createCampo(
                          Campo(
                            nomeController.text,
                            limiteJogadores.text,
                            comprimentoController.text,
                            larguraController.text
                          ),
                          widget.estabelecimentoId
                      );
                    }
                ),
              ],
            ),
          ),
        ),
      );
  }
}
