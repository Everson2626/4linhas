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

  int gols = 0;
  int assistencias = 0;
  int jogos = 0;

  UserPlayer() {
    if (this.uid == null) {
      this.email = '';
      this.password = '';
      this.confirmPassword = '';
      this.name = '';
      this.positions = '';
    } else {
      this.getUsetAuthData();
    }
  }

  UserPlayer retornaNovoJogador(String uid, String name) {
    UserPlayer newUser = new UserPlayer();
    newUser.uid = uid;
    newUser.getUsetAuthData();

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
    await FirebaseFirestore.instance
        .collection('User')
        .doc(this.uid)
        .get()
        .then((value) => {
              this.name = value['nome'],
              this.gols = value['gols'].toInt(),
              this.assistencias = value['assistencia'].toInt(),
            });

    this.urlImageProfile = await firebase_storage.FirebaseStorage.instance
        .ref('/image_profile/' + this.uid)
        .getDownloadURL();

    await FirebaseFirestore.instance
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
            });
    await FirebaseFirestore.instance
        .collection('User')
        .doc(this.uid)
        .collection('matchs')
        .get()
        .then((value) => this. jogos = value.docs.length);
  }

  Future<void> atualizarUsuario() async {
      await FirebaseFirestore.instance
        .collection('User')
        .doc(this.uid)
        .get()
        .then((value) => {
              if (this.name == null)
                {
                  this.name = value.data()['nome'],
                },
              if (this.gols == null || this.gols == 0)
                {
                  this.gols = value.data()['gols'].toInt(),
                },
              if (this.assistencias == null || this.assistencias == 0)
                {
                  this.assistencias = value.data()['assistencia'].toInt(),
                },
              FirebaseFirestore.instance
                  .collection('User')
                  .doc(this.uid)
                  .update({
                'uid': this.uid,
                'nome': this.name,
                'gols': this.gols,
                'assistencia': this.assistencias
              }),
            });
  }
}
