import 'dart:core';

import 'package:projeto/object/CampoRetorno.dart';

class Match {
  Match() {
    this.nome = '';
    this.preco = '';
    this.data = '';
    this.status = '';
    this.uid = '';
    this.userAdm = '';
    this.estabelecimentoId = CampoRetorno.establishmentUid;
    this.campoId = CampoRetorno.campoUid;
    this.urlImage = '';
  }

  int id = 0;
  String uid;
  String nome;
  String preco;
  String data;
  String userAdm;
  String status;
  String estabelecimentoId;
  String campoId;
  String urlImage;
}