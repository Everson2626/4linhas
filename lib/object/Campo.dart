import 'dart:io';

class Campo{
  String nome;
  int limite_jogadores;
  int comprimento;
  int largura;

  Campo(String nome, String limite_jogadores, String comprimento, String largura){
    this.nome = nome;
    this.limite_jogadores = int.parse(limite_jogadores);
    this.comprimento = int.parse(comprimento);
    this.largura = int.parse(largura);
  }
}