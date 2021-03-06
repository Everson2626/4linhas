import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projeto/object/CampoRetorno.dart';
import 'package:projeto/object/User.dart';
import 'package:projeto/object/Match.dart';
import 'package:projeto/service/firebaseService.dart';
import 'package:projeto/ui/estabelecimento/Establishment_List_Page.dart';

class CreateMatchPage extends StatefulWidget {
  @override
  _CreateMatchPageState createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends State<CreateMatchPage> {
  DateTime selectedDate = DateTime.now();
  FirebaseService firebaseService;

  Match match;
  String campoId;
  String estabelecimentoId;
  final nomeController = TextEditingController();
  final precoController = TextEditingController();
  final dataController = TextEditingController();
  final f = new DateFormat('dd-MM-yyyy hh:mm');


  String dataPartida = "Data";
  String buttonLocal;


  @override
  void initState() {
    CampoRetorno.establishmentUid = null;
    CampoRetorno.campoUid = null;
    this.buttonLocal = "Selecione o local";
  }

  @override
  Widget build(BuildContext context) {

    firebaseService = new FirebaseService(FirebaseAuth.instance);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(255, 255, 255, 0),
        title: Text(
          "Cria uma partida",
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Container(
            padding: EdgeInsets.all(10.0 ),
            color: Colors.white,
            height: 450.0,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(0, 30, 0, 30),
                  child: Text(
                    "CRIE SUA PARTIDA",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30.0,
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
                    controller: precoController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0)
                      ),
                      labelText: "Pre??o",
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: RaisedButton(
                          color: Colors.greenAccent,
                          child: Text(
                            this.buttonLocal,
                            style: TextStyle(
                                color: Colors.black
                            ),
                          ),
                          onPressed: () async {
                            await Navigator.pushNamed(context, '/establishment_list');
                            this.estabelecimentoId = CampoRetorno.establishmentUid;
                            this.campoId = CampoRetorno.campoUid;
                            this.buttonLocal = CampoRetorno.nome+" - "+CampoRetorno.dia.replaceAll("-", "/")+" "+CampoRetorno.hora;
                            setState(() {});
                          }
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
                      match = Match();
                      match.nome = nomeController.text;
                      match.preco = precoController.text;
                      match.data = CampoRetorno.dia;
                      match.hora = CampoRetorno.hora;
                      match.userAdm = FirebaseAuth.instance.currentUser.uid;
                      match.status = "pendente";
                      match.timeUid = CampoRetorno.timeUid;
                      print(match.data);
                      firebaseService.createMatch(match).then((value) => {
                        mensagem(value),
                        if(value == "Partida criada\n\nAguarde ser confirmada pelo estabelecimento"){
                          Navigator.pop(context),
                        }
                      });
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
      initialEntryMode: DatePickerEntryMode.input,
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        this.dataPartida = "${f.format(selectedDate.toLocal())}".split(' ')[0];
        print("Data: "+dataPartida);
      });

  }
  Widget mensagem(String mensagem) {
    final snackBar = SnackBar(
      content: Text(mensagem),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  }
