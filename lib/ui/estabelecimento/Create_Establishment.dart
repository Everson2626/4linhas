import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto/object/Establishment.dart';
import 'package:projeto/service/firebaseService.dart';

class CreateEstablishment extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<CreateEstablishment> {

  final nomeController = TextEditingController();
  final enderecoController = TextEditingController();
  FirebaseService firebaseService = FirebaseService(FirebaseAuth.instance);
  Establishment establishment = Establishment();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Container(
            padding: EdgeInsets.all(10.0 ),
            color: Colors.white,
            height: 400.0,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(0, 30, 0, 30),
                  child: Text(
                    "ESTABELECIMENTO",
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
                    controller: enderecoController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0)
                      ),
                      labelText: "Endereço",
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
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
                      establishment.nome = nomeController.text;
                      establishment.endereco = enderecoController.text;
                      firebaseService.createEstablishment(establishment);
                    }),
              ],
            ),
          ),
        ),
      ),
    );;
  }
}
