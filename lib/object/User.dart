import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UserPlayer {
  String uid;
  String name;
  String email;
  String password;
  String confirmPassword;

  String positions;
  String urlImageProfile;

  double gols;
  double assistencias;
  UserPlayer() {
    if (this.uid == null) {
      this.email = '';
      this.password = '';
      this.confirmPassword = '';
      this.name = '';
      this.positions = '';
      this.gols = 0;
      this.assistencias = 0;
    } else {
      this.getUsetAuthData();
    }
  }

  UserPlayer retornaNovoJogador(String uid, String name) {
    UserPlayer newUser = new UserPlayer();
    newUser.uid = uid;
    newUser.name = name;

    return newUser;
  }

  String getData() {
    String retorno;
    retorno = "Uid: ${this.uid}\n" +
        "Email: ${this.email}\n" +
        "Senha: ${this.password}\n" +
        "Confirma Senha: ${this.confirmPassword}\n" +
        "Nome: ${this.name}";
    return retorno;
  }

  Future<UserPlayer> getDataViaCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    this.uid = prefs.get('uid');
    this.name = prefs.get('nome');
    this.urlImageProfile = prefs.get('urlImageProfile');
  }

  Future<void> setDataViaCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', this.uid);
    prefs.setString('nome', this.name);
    prefs.setString('urlImageProfile', this.urlImageProfile);
  }

  Future<bool> clearDataCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return await prefs.clear();
  }

  Future<void> getUsetAuthData() async {
    bool podeRetornar = false;

    FirebaseFirestore.instance
        .collection('User')
        .doc(this.uid)
        .get()
        .then((value) => {
              this.name = value['nome'],
              this.gols = value['gols'],
              this.assistencias = value['assistencia'],
            });

    this.urlImageProfile = await firebase_storage.FirebaseStorage.instance
        .ref('/image_profile/' + this.uid)
        .getDownloadURL();

    FirebaseFirestore.instance
        .collection('User')
        .doc(this.uid)
        .collection("position")
        .doc("position")
        .get()
        .then((position) => {
              this.positions = "",
              if (position['GO'] == true) {this.positions += "GO "},
              if (position['ZG'] == true) {this.positions += "ZG "},
              if (position['LT'] == true) {this.positions += "LT "},
              if (position['MC'] == true) {this.positions += "MC "},
              if (position['AT'] == true) {this.positions += "AT "},
              if (this.positions == "") {this.positions = "Sem posições"},
            })
        .whenComplete(() => podeRetornar = true);
  }

  Future<void> atualizarUsuario() async {}
}
