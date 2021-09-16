import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:projeto/object/User.dart';

class UserFinishedMatch{
  UserPlayer player;
  double gols;
  double assistencia;

  UserFinishedMatch(){
    UserPlayer player = new UserPlayer();
    double gols = 0;
    double assistencia = 0;
  }
}