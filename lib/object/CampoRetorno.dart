import 'dart:io';

class CampoRetorno{
  static String establishmentUid;
  static String campoUid;
  static String nome;
  static String timeUid;
  static String dia;
  static String hora;

  static resetValue(){
    CampoRetorno.establishmentUid = null;
    CampoRetorno.campoUid = null;
    CampoRetorno.timeUid = null;
    CampoRetorno.timeUid = null;
    CampoRetorno.dia = null;
    CampoRetorno.hora = null;
  }
}