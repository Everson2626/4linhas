import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:projeto/object/Match.dart';
import 'package:projeto/object/User.dart';
import 'package:projeto/object/UserFinishedMatch.dart';

class FinishedMatch extends StatefulWidget {

  final String matchId;

  const FinishedMatch({Key key, this.matchId}) : super(key: key);

  @override
  _FinishedMatchState createState() => _FinishedMatchState();
}

class _FinishedMatchState extends State<FinishedMatch> {
  Match match = new Match();
  List<UserPlayer> listUsers = new List<UserPlayer>();
  UserFinishedMatch userTeste = new UserFinishedMatch();
  bool dadosCarregados = false;

  List<double> arrayGols = new List();
  List<double> arrayAssistencia = new List();


  @override
  void initState() {
    this.getJogadores();
    this.getMatchData();
    Timer(Duration(seconds: 1), () {
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            "Partida finalizada",
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
        ),
        body: Center(
          child: Column(
            children: [
              Text(
                "Desempenho dos jogadores",
                style: TextStyle(color: Colors.black, fontSize: 25.0),
              ),
              Divider(color: Colors.black),
              Expanded(
                flex: 9,
                child: retornoTela(),
              ),
              RaisedButton(
                  color: Colors.black,
                  child: Text("Finalizar partida", style: TextStyle(color: Colors.white),),
                  onPressed: (){
                    this.loadDados();
                  }
              ),


            ],
          ),
        ));
  }

  Widget retornoTela(){

    if(this.listUsers.isNotEmpty && dadosCarregados){
      return SizedBox(
        child: ListView.builder(
          itemCount: listUsers.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: cardJogador(listUsers[index], index),
            );
          },
        ),
      );
    }else{
      return Text("Jogadores ainda não encontrados");
    }
  }

  Future<void> loadDados() async {
    this.listUsers.forEach((element) {
      salvarDadosDoJogadorNaPartida(element);
    });

    await FirebaseFirestore.instance
        .collection('match')
        .doc(widget.matchId)
        .set({
      'status': "finalizada",
      'nome': match.nome,
      'data': match.data,
      'preco': match.preco,
      'campoUid': match.campoId,
      'estabelecimentoUid': match.estabelecimentoId,
      'criador': match.userAdm,
      'urlImage': match.urlImage
    }).then((result){
      match.status = "finalizada";
      mensagem("Partida finalizada");
      setState(() {});
    }).catchError((onError){
      mensagem("Ocorreu algum erro");
    });
    this.arrayAssistencia = new List();
    this.arrayGols = new List();
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 2);
  }

  void salvarDadosDoJogadorNaPartida(UserPlayer user){
    FirebaseFirestore.instance
        .collection("User")
        .doc(user.uid)
        .get()
        .then((value) => {
      if(value['gols'] != null){
        user.gols = value['gols']+user.gols,
      },
      if(value['assistencia'] != null){
        user.assistencias = value['assistencia'] + user.assistencias,
      }
    }).whenComplete(() => {
      user.atualizarUsuario().whenComplete(() => {
        user.gols = 0,
        user.assistencias = 0,
      }),
    });
  }

  Widget cardJogador(UserPlayer user, index) {
    return Container(
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: Colors.lightGreen,
        border: Border.all(color: Colors.blueGrey, width: 1.0),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Column(
        children: [
          Text(user.name, style: TextStyle(fontSize: 25),),
          Row(
            children: [
              Expanded(
                  flex: 3,
                  child: imagemProfile(user)
              ),
              Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      Text(user.positions, style: TextStyle(fontSize: 20.0),),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Icon(Icons.sports_soccer),
                          ),
                          Expanded(
                            flex: 9,
                            child: Slider(
                              value: this.arrayGols[index],
                              min: 0,
                              max: 10,
                              divisions: 11,
                              label: this.arrayGols[index].round().toString(),
                              onChanged: (double value) {
                                setState(() {
                                  user.gols = value.round();
                                  this.arrayGols[index] = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Icon(Icons.local_parking_sharp),
                          ),
                          Expanded(
                            flex: 9,
                            child: Slider(
                              value: this.arrayAssistencia[index],
                              min: 0,
                              max: 10,
                              divisions: 11,
                              label: this.arrayAssistencia[index].round().toString(),
                              onChanged: (double value) {
                                setState(() {
                                  this.arrayAssistencia[index] = value;
                                  user.assistencias = value.round();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
              )
            ],
          )
        ],
      ),
    );
  }

  Future<void> getJogadores() async {
    UserPlayer userAtual = new UserPlayer();
    UserPlayer newUser;
    print(arrayGols.length);
    await FirebaseFirestore.instance
        .collection('match')
        .doc(widget.matchId)
        .collection('players')
        .get()
        .then((value) =>
        value.docs.forEach((element) async => {

          userAtual.uid = element.data()['userUid'],

          await userAtual.getUsetAuthData().whenComplete(() => {
            print("Posições: "+userAtual.positions),
            this.arrayGols.add(0.0),
            this.arrayAssistencia.add(0.0),
            this.listUsers.add(userAtual.retornaNovoJogador(element.data()['userUid'], userAtual.name)),

          })
        })).whenComplete(() => {dadosCarregados = true, setState(() {})});
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

  void mensagem(String mensagem) {
    final snackBar = SnackBar(
      content: Text(mensagem),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  Widget imagemProfile(UserPlayer user) {
    if (user.urlImageProfile != null) {
      return ClipOval(
          child: Image.network(
            user.urlImageProfile,
            height: 100.0,
            //width: 90.0,
            fit: BoxFit.fill,
          ));
    } else {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey,
        child: Icon(
          Icons.person,
          color: Colors.black,
          size: 70.0,
        ),
      );
    }
  }
}
