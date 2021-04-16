import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:projeto/object/Establishment.dart';
import 'package:projeto/ui/estabelecimento/Establishment_Page.dart';
import 'file:///C:/Users/Pichau/AndroidStudioProjects/projeto/lib/ui/estabelecimento/Create_Establishment.dart';
import 'file:///C:/Users/Pichau/AndroidStudioProjects/projeto/lib/ui/estabelecimento/Establishment_List_Page.dart';
import 'file:///C:/Users/Pichau/AndroidStudioProjects/projeto/lib/ui/autenticacao/Cadastro_Page.dart';
import 'file:///C:/Users/Pichau/AndroidStudioProjects/projeto/lib/ui/campo/Create_Campo.dart';
import 'file:///C:/Users/Pichau/AndroidStudioProjects/projeto/lib/ui/partida/Create_Match.dart';
import 'file:///C:/Users/Pichau/AndroidStudioProjects/projeto/lib/ui/autenticacao/Login_Page.dart';
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
      '/establishment_list': (context) => EstablishmentListPage(),
      '/create_establishment': (context) => CreateEstablishment(),
      '/create_list_establishment': (context) => CreateEstablishment(),
      '/create_campo': (context) => CreateCampo(),
    },
    title: "4 Linhas",
  ));
}
