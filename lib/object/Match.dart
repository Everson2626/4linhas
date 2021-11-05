import 'dart:core';

import 'package:projeto/object/CampoRetorno.dart';

class Match {
  Match() {
    this.nome = '';
    this.preco = '';
    this.data = '';
    this.hora = '';
    this.status = '';
    this.uid = '';
    this.userAdm = '';
    this.estabelecimentoId = CampoRetorno.establishmentUid;
    this.campoId = CampoRetorno.campoUid;
    this.urlImage = '';
    this.timeUid = '';
  }

  int id = 0;
  String uid;
  String nome;
  String preco;
  String data;
  String hora;
  String timeUid;
  String userAdm;
  String status;
  String estabelecimentoId;
  String campoId;
  String urlImage;
}