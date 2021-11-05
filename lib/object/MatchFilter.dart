import 'dart:core';

class MatchFilter{
  String nomePartida;
  String endereco;
  double latitude;
  double longitude;
  int distance;
  bool jogadorInscrito = false;

  MatchFilter(){
    nomePartida = '';
    endereco = '';
    longitude = 0;
    latitude = 0;
    distance = 0;
  }
}