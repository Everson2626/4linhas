import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter/painting.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:projeto/object/Establishment.dart";
import "package:projeto/ui/estabelecimento/Establishment_Page.dart";
import "package:projeto/ui/estabelecimento/Create_Establishment.dart";
import "package:projeto/ui/estabelecimento/Establishment_List_Page.dart";
import "package:projeto/ui/autenticacao/Cadastro_Page.dart";
import "package:projeto/ui/campo/Create_Campo.dart";
import "package:projeto/ui/partida/Create_Match.dart";
import "package:projeto/ui/autenticacao/Login_Page.dart";
import "package:projeto/ui/home_player.dart";
import "package:projeto/ui/partida/Details_Match.dart";
import "package:projeto/ui/user/Edit_User_Page.dart";
import "package:projeto/ui/user/FriendRequestPage.dart";

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
      '/friend_request': (context) => FriendRequestPage(),
      '/create_establishment': (context) => CreateEstablishment(),
      '/create_list_establishment': (context) => CreateEstablishment(),
      '/create_campo': (context) => CreateCampo(),
      '/details_match': (context) => DetailsMatch(),
      '/edit_user_page': (context) => UserEditPage(),
      '/establishment_list': (context) => EstablishmentListPage(),
    },
    title: "4 Linhas",
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate
    ],
    supportedLocales: [const Locale('pt', 'BR')],
  ));
}
