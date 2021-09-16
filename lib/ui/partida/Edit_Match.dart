import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projeto/object/User.dart';
import 'package:projeto/object/Match.dart';
import 'package:projeto/service/firebaseService.dart';
import 'package:projeto/ui/partida/Details_Match.dart';

class EditMatchPage extends StatefulWidget {
  final String matchId;

  const EditMatchPage({Key key, this.matchId}) : super(key: key);

  @override
  _CreateMatchPageState createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends State<EditMatchPage> {
  DateTime selectedDate = DateTime.now();
  FirebaseService firebaseService;
  UserPlayer userAuth = new UserPlayer();

  Match match;

  final nomeController = TextEditingController();
  final precoController = TextEditingController();
  final dataController = TextEditingController();

  @override
  void initState() {
    match = Match();
    userAuth.uid = FirebaseAuth.instance.currentUser.uid;

    this
        .getMatchData()
        .then((value) => {setState(() {}), print(nomeController.text)});
  }

  @override
  Widget build(BuildContext context) {
    firebaseService = new FirebaseService();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(255, 255, 255, 0),
        title: Text(
          "Edite a partida",
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Container(
            padding: EdgeInsets.all(10.0),
            color: Colors.white,
            height: 400.0,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(0, 30, 0, 30),
                  child: Text(
                    "EDITE A PARTIDA",
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
                          borderRadius: BorderRadius.circular(15.0)),
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
                          borderRadius: BorderRadius.circular(15.0)),
                      labelText: "Preço",
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Text(
                  "${selectedDate.toLocal()}".split(' ')[0],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 15.0),
                  child: RaisedButton(
                    onPressed: () => _selectDate(context), // Refer step 3
                    child: Text(
                      'date',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    color: Colors.greenAccent,
                  ),
                ),
                //acaoButton()
                Row(
                  children: [
                    Expanded(
                        child: RaisedButton(
                            color: Colors.black,
                            child: Container(
                              child: Text(
                                "Salvar",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            onPressed: () {
                              match.uid = widget.matchId;
                              match.nome = nomeController.text;
                              match.preco = precoController.text;
                              match.data =
                              "${selectedDate.toLocal()}".split(' ')[0];
                              match.userAdm = FirebaseAuth.instance.currentUser.uid;
                              firebaseService.updateMatch(match);

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DetailsMatch(matchId: widget.matchId)));
                            }),
                    ),
                    Expanded(
                        child: RaisedButton(
                            color: Colors.red,
                            child: Container(
                              child: Text(
                                "EXCLUIR PARTIDA",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            onPressed: () {
                              firebaseService.deleteMatch(match.uid);
                              Navigator.pushNamed(context, '/home_page');
                            }
                        ),
                    ),
                  ],
                )
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
        final f = new DateFormat('dd-MM-yyyy hh:mm');
        selectedDate = picked;
        print("Data: "+f.format(selectedDate.toLocal()));
      });
  }

  Widget acaoButton() {
    if (match.userAdm == userAuth.uid) {
      return Container();
    } else {
      return Container();
    }
  }

  Future<void> getMatchData() async {
    await FirebaseFirestore.instance
        .collection('match')
        .doc(widget.matchId)
        .get()
        .then((value) => {
              nomeController.text = value['nome'],
              dataController.text = value['data'],
              precoController.text = value['preco'],
              match.userAdm = value['criador'],
            });
  }
}
