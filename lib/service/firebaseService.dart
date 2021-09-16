import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto/object/Campo.dart';
import 'package:projeto/object/Establishment.dart';
import 'package:projeto/object/User.dart';
import 'package:projeto/object/Match.dart';
import 'package:projeto/service/firebaseService.dart';
import 'package:projeto/ui/autenticacao/Cadastro_Page.dart';
import 'package:projeto/ui/home_player.dart';

class FirebaseService {
  FirebaseAuth auth = FirebaseAuth.instance;
  final databaseReference = FirebaseDatabase.instance.reference();
  final firestoreInstance = FirebaseFirestore.instance;
  //final CollectionReference collectionReference = new CollectionReference();
  BuildContext get context => null;

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

  void addUserData(UserPlayer player) {
    firestoreInstance.collection("User").doc(player.uid).set({
      "uid": player.uid,
      "nome": player.name,
    }).then((value) {});
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

  bool createMatch(Match match) {
    if (match.campoId != null) {
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
                  "data": match.data,
                  "criador": match.userAdm,
                  "estabelecimentoUid": match.estabelecimentoId,
                  "campoUid": match.campoId,
                  "urlImage": urlImage,
                  "status": 'pendente'
                }).then((value) {
                  var user = FirebaseAuth.instance.currentUser.uid;
                  print(user);
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
                })
              });
    } else {}
  }

  void updateMatch(Match match) {
    firestoreInstance.collection("match").doc(match.uid).update({
      "nome": match.nome,
      "preco": match.preco,
      "data": match.data,
      "criador": match.userAdm,
      "status": 'pendente'
    });
  }

  void deleteMatch(String matchUid) {
    firestoreInstance.collection("match").doc(matchUid).delete();
  }

  getMatch() {}

  Widget mensagem(String mensagem) {
    final snackBar = SnackBar(
      content: Text(mensagem),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
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
