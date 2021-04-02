import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto/object/User.dart';
import 'package:projeto/service/firebaseService.dart';
import 'package:projeto/ui/Cadastro_Page.dart';
import 'package:projeto/ui/home_player.dart';

class FirebaseService {
  FirebaseAuth auth = FirebaseAuth.instance;
  BuildContext get context => null;

  void cadastro(UserPlayer player) async {
    print(player);
    try {
      if (player.password == player.confirmPassword) {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: player.email,
          password: player.password,
        );
        mensagem("Usuario cadastrado");
      } else {
        String msg = '';
        if (player.name.isEmpty) {
          msg = 'Insira um nome\n';
        }
        mensagem(msg + "As senhas não coincidem ");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        mensagem('A senha fornecida é muito fraca.');
      } else if (e.code == 'email-already-in-use') {
        mensagem('Esse E-mail já está cadastrado');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> login(UserPlayer player) async {
    print(player.toString());
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: player.email, password: player.password);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      return false;
    }
  }

  void mensagem(String mensagem) {
    showDialog(
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          title: new Text("4 Linhas"),
          content: new Text(mensagem),
          actions: <Widget>[
            // define os botões na base do dialogo
            new FlatButton(
              child: new Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
