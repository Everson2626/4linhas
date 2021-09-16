import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto/object/Match.dart';
import 'package:projeto/object/User.dart';
import 'package:projeto/ui/partida/Edit_Match.dart';

import 'Finished_Match.dart';

class DetailsMatch extends StatefulWidget {

  final String matchId;

  const DetailsMatch({Key key, this.matchId}) : super(key: key);

  @override
  _DetailsMatchState createState() => _DetailsMatchState();
}

class _DetailsMatchState extends State<DetailsMatch> {

  Match match = new Match();
  UserPlayer userAuth = new UserPlayer();
  List<String> players = [];
  bool listPlayerLoad = false;
  bool possuiJogadores = true;


  @override
  void initState() {
    listPlayerLoad = false;
    userAuth.uid = FirebaseAuth.instance.currentUser.uid;
    this.getUser().whenComplete(() => {
      if(this.players.length > 0){
        this.listPlayerLoad = true,
        this.possuiJogadores = true,
      }else{
        this.possuiJogadores = false,
      }

    });
    getMatchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Detalhes da partida",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10.0),
            child: IconButton(icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => EditMatchPage(matchId: widget.matchId)));
              },
            ),
          )

        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 60),
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: Text(
                  match.nome,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: Text(
                  "Dia: "+match.data,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: Text(
                  "Valor: R\$ "+match.preco,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: Text(
                  "Status: "+match.status,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Divider(color: Colors.black, height: 3.0,),
              SingleChildScrollView(
                child: dataLoad()
              ),
              Divider(color: Colors.black, height: 3.0,),
              buttonConfirm()
            ],
          ),
        ),
      )

    );
  }
  Widget playerCard(DocumentSnapshot doc){
    String positions = "";
    FirebaseFirestore.instance
        .collection('User')
        .doc(doc.id)
        .collection("position")
        .doc("position")
        .get()
        .then((position) => {
      if (position['GO'] == true) {positions += "GO "},
      if (position['ZG'] == true) {positions += "ZG "},
      if (position['LT'] == true) {positions += "LT "},
      if (position['MC'] == true) {positions += "MC "},
      if (position['AT'] == true) {positions += "AT "},
      if (positions == ""){positions = "Sem posições"},
    });

    return Card(

      child: Container(
        padding: EdgeInsets.only(right: 8.0, left: 8.0),
        color: Colors.lightGreen,
        width: 400.0,
        height: 80.0,
        child: Row(
          children: [
            Expanded(
              flex: 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.data()['nome'],
                    style: TextStyle(fontSize: 20.0),
                  ),
                  Divider(),
                  Text(
                    "Posições: "+positions,
                    style: TextStyle(fontSize: 13.0),
                  )
                ],
              )

            ),

            buttonRemove(doc.data()['uid'])

          ],
        ),
      ),
    );
  }

  Widget buttonRemove(String userAtualUid){
    if(userAtualUid != this.userAuth.uid){
      return Expanded(
          flex: 2,
          child: GestureDetector(
            child: Container(
              width: 30,
              height: 60,
              child: Icon(
                Icons.delete,
                size: 30.0,
                color: Colors.red,
              ),
            ),
            onTap: (){
              FirebaseFirestore.instance
                  .collection("match")
                  .doc(widget.matchId)
                  .collection("players")
                  .doc(userAtualUid)
                  .delete().whenComplete(() => setState(() {}));
            },
          )
      );
    }else{
      return Expanded(
        flex: 2,
          child: Container(
            width: 30,
            height: 60,
            child: Icon(
              Icons.people_alt_sharp,
              size: 30.0,
              color: Colors.black,
            ),
          ),
      );
    }
  }

  Future<void> getUser() async{
    await FirebaseFirestore.instance
        .collection('match')
        .doc(widget.matchId)
        .collection('players')
        .get()
        .then((value) => {value.docs.forEach((element) {this.players.add(element.data()['userUid']);})});

    //print(widget.matchId);

    //return this.partidas;

  }

  Widget buttonConfirm(){
    if(userAuth.uid == match.userAdm){
      if(match.status == 'finalizada'){
        return Text("Partida finalizada");
      }
      if(match.status == 'confirmada'){
        return RaisedButton(
          color: Colors.black,
          child: Text("Iniciar partida", style: TextStyle(color: Colors.white),),
          onPressed: (){
            FirebaseFirestore.instance
                .collection('match')
                .doc(widget.matchId)
                .set({
              'status': "iniciada",
              'nome': match.nome,
              'data': match.data,
              'preco': match.preco,
              'campoUid': match.campoId,
              'estabelecimentoUid': match.estabelecimentoId,
              'criador': match.userAdm,
              'urlImage': match.urlImage
            }).then((result){
              match.status = "iniciada";
              mensagem("Partida iniciada");
              setState(() {});
            }).catchError((onError){
              mensagem("Ocorreu algum erro");
            });
          }
        );
      }else if(match.status == 'iniciada'){
        return RaisedButton(
            color: Colors.black,
            child: Text("Finalizar partida", style: TextStyle(color: Colors.white),),
            onPressed: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FinishedMatch(matchId: widget.matchId,)));
            }
        );
      }
      else if(match.status == 'pendente'){
        return Text("Partida pendente");
      }

    }else{
      return RaisedButton(
          color: Colors.red,
          child: Text(
            "Increver-se",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20.0
            ),
          ),
          onPressed: (){
            var user = FirebaseAuth.instance.currentUser.uid;
            FirebaseFirestore.instance
                .collection('match')
                .doc(widget.matchId)
                .collection('players')
                .doc(user)
                .set({
              "userUid": user
            }).catchError((onError){
              mensagem("Ocorreu algum erro");
            });


            FirebaseFirestore.instance
                .collection('User')
                .doc(user)
                .collection('matchs')
                .doc(widget.matchId)
                .set({
              "matchUid": widget.matchId
            }).then((result){
              mensagem("Usuario cadastrado");
            }).catchError((onError){
              mensagem("Ocorreu algum erro");
            });
          });
    }
    return Container();

  }

  Widget dataLoad(){
    if(this.listPlayerLoad){
      return StreamBuilder(
        stream:
        FirebaseFirestore.instance
            .collection("User")
            .where(FieldPath.documentId, whereIn: this.players)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              LinearProgressIndicator();
              break;
            default:
              return ListView(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: snapshot.data.docs
                    .map<Widget>((DocumentSnapshot doc) {
                  return playerCard(doc);
                }).toList(),
              );
          }
          return Text('');
        },
      );
    }else{
      if(this.possuiJogadores){
        return LinearProgressIndicator();
      }else{
        return Text("Não possui jogadores");
      }

    }
  }

  void mensagem(String mensagem) {
    final snackBar = SnackBar(
      content: Text(mensagem),
      action: SnackBarAction(
        label: 'Desfazer',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> getMatchData() async {
    await FirebaseFirestore.instance
        .collection('match')
        .doc(widget.matchId)
        .get()
        .then((value) => {
      match.nome = value['nome'],
      match.data = value['data'],
      match.preco = value['preco'],
      match.status = value['status'],
      match.userAdm = value['criador'],
      match.campoId = value['campoUid'],
      match.estabelecimentoId = value['estabelecimentoUid'],
      match.urlImage = value['urlImage']
    }).whenComplete(() => {
      setState(() {})
    });
  }
}
