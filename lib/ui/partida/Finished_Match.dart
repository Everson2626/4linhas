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
              retornoTela(),
              RaisedButton(
                  color: Colors.black,
                  child: Text("Finalizar partida", style: TextStyle(color: Colors.white),),
                  onPressed: (){
                    this.loadDados();
                  }
              )
            ],
          ),
        ));
  }

  Widget retornoTela(){

    if(this.listUsers.isNotEmpty && dadosCarregados){
      return SizedBox(
        height: 500.0,
        child: ListView.builder(
          itemCount: listUsers.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: cardJogador(listUsers[index]),
            );
          },
        ),
      );
    }else{
      return Text("Jogadores ainda não encontrados");
    }
  }

  Future<void> loadDados(){
    this.listUsers.forEach((element) {
      salvarDadosDoJogadorNaPartida(element);
    });

    FirebaseFirestore.instance
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
      FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .update(
          {
            'nome': user.name,
            'gols': user.gols.round(),
            'assistencia': user.assistencias.round()
          }
      ),
    });
  }

  Widget cardJogador(UserPlayer user) {
    return Container(
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: Colors.grey,
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
                  child: Container(
                    height: 100.0,
                    child: Image.network(
                        "https://firebasestorage.googleapis.com/v0/b/linhas-62812.appspot.com/o/estabelecimento%2FRjtmH5D6HoausaojXXBQT2b2nPk2%2FGRAwCdLcgQ24A8c2FSel?alt=media&token=8c52036f-6c87-440b-a9aa-8b459a32568e"),
                  )),
              Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      Text("Posições: ZG LT", style: TextStyle(fontSize: 20.0),),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Icon(Icons.sports_soccer),
                          ),
                          Expanded(
                            flex: 9,
                            child: Slider(
                              value: user.gols,
                              min: 0,
                              max: 10,
                              divisions: 11,
                              label: user.gols.round().toString(),
                              onChanged: (double value) {
                                setState(() {
                                  user.gols = value;
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
                              value: user.assistencias,
                              min: 0,
                              max: 10,
                              divisions: 11,
                              label: user.assistencias.round().toString(),
                              onChanged: (double value) {
                                setState(() {
                                  user.assistencias = value;
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
    await FirebaseFirestore.instance
        .collection('match')
        .doc(widget.matchId)
        .collection('players')
        .get()
        .then((value) =>
        value.docs.forEach((element) async => {

          userAtual.uid = element.data()['userUid'],

          await FirebaseFirestore.instance
            .collection("User")
            .doc(userAtual.uid)
            .get()
            .then((value) => {
              userAtual.name = value.data()['nome'],
            }).whenComplete(() => {
              this.listUsers.add(userAtual.retornaNovoJogador(element.data()['userUid'], userAtual.name))
              , print("User atual: "+element.data()['userUid']),
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
      action: SnackBarAction(
        label: 'Desfazer',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
