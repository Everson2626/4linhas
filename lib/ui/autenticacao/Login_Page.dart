import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:projeto/object/Location.dart';
import 'package:projeto/object/User.dart';
import 'package:projeto/service/firebaseService.dart';
import 'package:projeto/ui/autenticacao/Redefinir_Page.dart';
import 'package:projeto/ui/home_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dwds/dwds.dart';

import 'package:projeto/ui/autenticacao/Cadastro_Page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseService firebaseService = FirebaseService(FirebaseAuth.instance);

  UserPlayer player;

  Position position;
  String currentLocation;

  @override
  Widget build(BuildContext context) {
    player = UserPlayer();

    final emailController = TextEditingController();
    final passwordController = TextEditingController();



    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
          child: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Container(
          padding: EdgeInsets.all(10.0),
          color: Colors.white,
          //height: 400.0,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, 30, 0, 30),
                child: Text(
                  "4 LINHAS",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 50.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 30.0),
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    labelText: "Email",
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.visiblePassword,
                      controller: passwordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        labelText: "Senha",
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5.0, left: 5.0),
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RedefinirPage()));
                        },
                        child: Text(
                          "Redefinir senha",
                        ),
                      ),
                    )
                  ],
                ),

              ),
              RaisedButton(
                  color: Colors.black,
                  child: Container(
                    child: Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  onPressed: () {
                    String userUid;
                    player.email = emailController.text;
                    player.password = passwordController.text;
                    SharedPreferences prefs;
                    firebaseService.login(player).then((value) async => {
                          if (value)
                            {
                              prefs = await SharedPreferences.getInstance(),
                              prefs.setString("email", emailController.text),
                              prefs.setString(
                                  "password", passwordController.text),

                              userUid = FirebaseAuth.instance.currentUser.uid,
                              firebaseService.verificaSePossuiCollection(userUid).whenComplete(() => {
                                Navigator.pushNamed(context, '/home_page'),

                                mensagem("Login realizado!")
                              }),

                            }
                          else
                            {mensagem("Falha ao realizar o login!")}
                        });
                  }),
              GestureDetector(
                child: Text("Cadastrar"),
                onTap: () {
                  Navigator.pushNamed(context, '/cadastro_page');
                },
              )
            ],
          ),
        ),
      )),
    );
  }

  @override
  void initState() {
    verificarAutenticacao();
    this._getCurrentLocation();
  }

  Widget mensagem(String mensagem) {
    final snackBar = SnackBar(
      content: Text(mensagem),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> verificarAutenticacao() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("uid") != null) {
      player.email = prefs.getString("email");
      player.password = prefs.getString("password");
      firebaseService.login(player).then((value) => {
            if (value)
              {
                Navigator.pushNamed(context, '/home_page'),
              }
          });
    }
  }

  void _getCurrentLocation() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        });
      }else{
        var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        setState(() {
          LocationUser.longitude = position.longitude;
          LocationUser.latitude = position.latitude;
        });
      }
    }else{
      var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        LocationUser.longitude = position.longitude;
        LocationUser.latitude = position.latitude;
      });
    }
  }
}
