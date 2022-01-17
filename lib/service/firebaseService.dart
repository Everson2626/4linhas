import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto/object/Campo.dart';
import 'package:projeto/object/CampoRetorno.dart';
import 'package:projeto/object/Establishment.dart';
import 'package:projeto/object/User.dart';
import 'package:projeto/object/Match.dart';
import 'package:projeto/service/firebaseService.dart';
import 'package:projeto/ui/autenticacao/Cadastro_Page.dart';
import 'package:projeto/ui/home_player.dart';
import 'package:projeto/service/firebaseService.dart';


class FirebaseService {
  FirebaseAuth auth = FirebaseAuth.instance;
  Stream<User> get authStateChanges => auth.idTokenChanges();
  
  final databaseReference = FirebaseDatabase.instance.reference();
  final firestoreInstance = FirebaseFirestore.instance;
  //final CollectionReference collectionReference = new CollectionReference();
  BuildContext get context => null;

  FirebaseService(this.auth);
  
  Future<String> cadastro(UserPlayer player) async {
    if (player.name.isEmpty ||
        player.email.isEmpty ||
        player.name.isEmpty ||
        player.confirmPassword.isEmpty) {
      String retorno = "";
      if (player.email.isEmpty) {
        retorno += "Insira um email!\n";
      }
      if (player.name.isEmpty) {
        retorno += "Insira um nome!\n";
      }
      if (player.password.isEmpty) {
        retorno += "Insira uma senha!\n";
      }
      if (player.confirmPassword.isEmpty) {
        retorno += "Prencha o campo de confirmação de senha\n";
      }
      return await retorno;
    }
    try {
      if (player.password == player.confirmPassword) {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: player.email, password: player.password);
        player.uid = userCredential.user.uid;
        addUserData(player);
        return await "Usuario cadastrado";
      } else {
        String msg = '';
        if (player.name.isEmpty) {
          return await 'Insira um nome\n';
        }
        return await msg + "As senhas não coincidem ";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return await 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        return await 'Esse E-mail já está cadastrado';
      }
    } catch (e) {
      return await 'Dados Inválidos!';
    }
  }

  Future<void> sair() async {
    await auth.signOut();
  }

  void addUserData(UserPlayer player) {
    firestoreInstance.collection("User").doc(player.uid).set({
      "uid": player.uid,
      "nome": player.name,
      "gols": 0,
      "assistencia": 0
    });
    firestoreInstance
      .collection("User")
      .doc(player.uid)
      .collection("position")
      .doc("position")
      .set({
        "GO": false,
        "ZG": false,
        "LT": false,
        "MC": false,
        "AT": false,
    });
  }

  Future<UserPlayer> getUser() {}

  Future<bool> login(UserPlayer player) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: player.email, password: player.password);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        //mensagem('Não existe um usuario com esse email cadastrado');
      } else if (e.code == 'wrong-password') {
        //mensagem('Senha incoreta');
      }
      return false;
    }
  }

  Future<void> verificaSePossuiCollection(String userUid) async{
    UserPlayer novoUser = new UserPlayer();
    novoUser.uid = userUid;
    await FirebaseFirestore
      .instance
      .collection('User')
      .where(FieldPath.documentId, isEqualTo: userUid)
      .get().then((value) => {
        if(value.size <= 0){
          FirebaseFirestore
            .instance
            .collection('Establishment')
            .doc(userUid)
            .get().then((value) => {
              novoUser.name = value.data()['nome'],
              addUserData(novoUser)
          })
        }
    });
  }

  void createCampo(Campo campo, String establishmentId) async {
    await firestoreInstance
        .collection("Establishment")
        .doc(establishmentId)
        .collection('campo')
        .add({
      "nome": campo.nome,
      "limite_jogadores": campo.limite_jogadores,
      "largura": campo.largura,
      "comprimento": campo.comprimento,
    }).then((value) => {print(value)});
  }

  void createEstablishment(Establishment establishment) async {
    await firestoreInstance.collection("Establishment").add({
      "nome": establishment.nome,
      "endereco": establishment.endereco,
    }).then((value) {
      print(value.id);
    });
  }

  Future<String> createMatch(Match match) async{
    String retornoErro = "";
    if(match.campoId == null || match.campoId == ""){
      if(retornoErro == ""){
        retornoErro += "Não foi possivel cadastrar\n\n";
      }
      retornoErro += "Campo não selecionado\n";
    }
    if(match.data == null  || match.data == ""){
      if(retornoErro == ""){
        retornoErro += "Não foi possivel cadastrar\n\n";
      }
      retornoErro += "Partida não possui data\n";
    }
    if(match.nome == null  || match.nome == ""){
      if(retornoErro == ""){
        retornoErro += "Não foi possivel cadastrar\n\n";
      }
      retornoErro += "Partida não possui nome\n";
    }
    if(match.preco == null  || match.preco == ""){
      match.preco = "0";
    }

    if (retornoErro == "") {
      String urlImage;
      FirebaseFirestore.instance
          .collection("Establishment")
          .doc(match.estabelecimentoId)
          .collection("campo")
          .doc(match.campoId)
          .get()
          .then((value) => urlImage = value.data()['urlImage'])
          .whenComplete(() => {
                firestoreInstance.collection("match").add({
                  "nome": match.nome,
                  "preco": match.preco,
                  "data": match.data+" "+match.hora,
                  "criador": match.userAdm,
                  "estabelecimentoUid": match.estabelecimentoId,
                  "campoUid": match.campoId,
                  "urlImage": urlImage,
                  "timeUid": match.timeUid,
                  "status": 'pendente'
                }).then((value) {
                  var user = FirebaseAuth.instance.currentUser.uid;
                  FirebaseFirestore.instance
                      .collection('match')
                      .doc(value.id)
                      .collection('players')
                      .doc(user)
                      .set({"userUid": user}).catchError((onError) {
                    mensagem("Ocorreu algum erro");
                  });

                  FirebaseFirestore.instance
                      .collection('User')
                      .doc(user)
                      .collection('matchs')
                      .doc(value.id)
                      .set({"matchUid": value.id}).then((result) {
                    mensagem("Usuario cadastrado");
                  }).catchError((onError) {
                    mensagem("Ocorreu algum erro");
                  });

                  FirebaseFirestore.instance
                      .collection("Establishment")
                      .doc(match.estabelecimentoId)
                      .collection("campo")
                      .doc(match.campoId)
                      .collection("horarios")
                      .doc("info")
                      .collection(match.data)
                      .doc(match.timeUid)
                      .update({
                    "Status": "pendente"
                  }).whenComplete(() => CampoRetorno.resetValue());
                })
              });
      return "Partida criada\n\nAguarde ser confirmada pelo estabelecimento";
    } else {
      return retornoErro;
    }
  }

  void updateMatch(Match match) {
    firestoreInstance.collection("match")
        .doc(match.uid)
        .get().then((value) => {
          if(match.nome == null || match.nome == ""){
            match.nome = value.data()['nome']
          },
          if(match.preco == null || match.preco == ""){
            match.preco = value.data()['preco']
          },
          if(match.data == null || match.data == ""){
            match.data = value.data()['data']
          },
          if(match.userAdm == null || match.userAdm == ""){
            match.userAdm = value.data()['criador']
          },
          if(match.status == null || match.status == ""){
            match.status = value.data()['status']
          },
          if(match.campoId == null || match.campoId == ""){
            match.campoId = value.data()['campoUid']
          },
          if(match.estabelecimentoId == null || match.estabelecimentoId == ""){
            match.estabelecimentoId = value.data()['estabelecimentoUid']
          },
          if(match.urlImage == null  || match.urlImage == ""){
            match.urlImage = value.data()['urlImage']
          },
          firestoreInstance.collection("match").doc(match.uid).update({
            "nome": match.nome,
            "preco": match.preco,
            "data": match.data,
            "criador": match.userAdm,
            "status": match.status,
            'campoUid': match.campoId,
            'estabelecimentoUid': match.estabelecimentoId,
            'criador': match.userAdm,
            'urlImage': match.urlImage
          })
    });


  }

  void deleteMatch(String matchUid) {
    firestoreInstance.collection("match").doc(matchUid).delete();
  }

  getMatch() {}

  Widget mensagem(String mensagem) {
    final snackBar = SnackBar(
      content: Text(mensagem),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<bool> verificarSeJogadorExiste(String uid) async {
    int qtdJogador = null;
    await FirebaseFirestore.instance
        .collection("User")
        .where(FieldPath.documentId, isEqualTo: uid)
        .get()
        .then((value) => {qtdJogador = value.size});

    if (qtdJogador > 0) {
      return true;
    } else {
      return false;
    }
  }
}
