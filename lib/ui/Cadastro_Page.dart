import 'package:flutter/material.dart';
import 'package:projeto/object/User.dart';
import 'package:projeto/service/firebaseService.dart';
import 'package:projeto/ui/Login_Page.dart';
import 'package:firebase_auth/firebase_auth.dart';



class CadastroPage extends StatefulWidget {
  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  FirebaseService firebaseService = FirebaseService();

  UserPlayer player;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    player = UserPlayer();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Container(
              padding: EdgeInsets.all(10.0 ),
              color: Colors.white,
              height: 510.0,
              child:
              Column(
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
                    padding: EdgeInsets.only(bottom: 15.0),
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0)
                        ),
                        labelText: "Nome",
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 15.0),
                    child: TextField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0)
                        ),
                        labelText: "Email",
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 15.0),
                    child: TextField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: passwordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0)
                        ),
                        labelText: "Senha",
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 15.0),
                    child: TextField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: confirmController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0)
                        ),
                        labelText: "Confirmar Senha",
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  RaisedButton(
                      color: Colors.black,
                      child: Container(
                        child: Text(
                          "Cadastrar",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      onPressed: () {
                        player.name = nameController.text;
                        player.email = emailController.text;
                        player.password = passwordController.text;
                        player.confirmPassword = confirmController.text;
                        print(player.email);
                        firebaseService.cadastro(player);
                      }
                  ),
                  GestureDetector(
                    child: Text("Já possui login"),
                    onTap: (){
                      Navigator.pushNamed(context, '/');
                    },
                  )
                ],
              ),
            ),
          )
      ),
    );
  }

}
