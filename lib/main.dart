import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:projeto/ui/Cadastro_Page.dart';
import 'package:projeto/ui/Create_Match.dart';
import 'package:projeto/ui/Establishment_Page.dart';
import 'package:projeto/ui/Login_Page.dart';
import 'package:projeto/ui/home_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => LoginPage(),
      '/cadastro_page': (context) => CadastroPage(),
      '/home_page': (context) => HomePlayer(),
      '/create_match': (context) => CreateMatchPage(),
      '/create_establishment': (context) => EstablishmentPage(),
    },
    title: "4 Linhas",
  ));
}
