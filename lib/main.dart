import 'package:firebase_auth/firebase_auth.dart';
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter/painting.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:projeto/object/Establishment.dart";
import 'package:projeto/service/firebaseService.dart';
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
import 'package:projeto/ui/user/Friend_List.dart';
import 'package:provider/provider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
      MultiProvider(
          providers: [
            Provider<FirebaseService>(
              create: (_) => FirebaseService(FirebaseAuth.instance),
            ),
            StreamProvider(
              create: (context) => context.read<FirebaseService>().authStateChanges,
            )
          ],
        child:MaterialApp(
          initialRoute: '/',
          routes: {
            '/login_page': (context) => LoginPage(),
            '/cadastro_page': (context) => CadastroPage(),
            '/home_page': (context) => HomePlayer(),
            '/create_match': (context) => CreateMatchPage(),
            '/friend_request': (context) => FriendRequestPage(),
            '/friend_list': (context) => FiendList(),
            '/create_establishment': (context) => CreateEstablishment(),
            '/create_list_establishment': (context) => CreateEstablishment(),
            '/create_campo': (context) => CreateCampo(),
            '/details_match': (context) => DetailsMatch(),
            '/edit_user_page': (context) => UserEditPage(),
            '/establishment_list': (context) => EstablishmentListPage(),
          },
          title: "4 Linhas",
          home: AuthenticationWrapper(),
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          supportedLocales: [const Locale('pt', 'BR')],
        ))
      );
}
class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) {
      return HomePlayer();
    }
    return LoginPage();
  }
}