import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RedefinirPage extends StatefulWidget {
  const RedefinirPage({Key key}) : super(key: key);

  @override
  _RedefinirPageState createState() => _RedefinirPageState();
}

class _RedefinirPageState extends State<RedefinirPage> {
  TextEditingController emailController = new TextEditingController();
  FirebaseAuth user;
  List<String> listaDeEmails = new List();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Redefinir senha",
          style: TextStyle(
            color: Colors.white
          ),
        ),
        backgroundColor: Colors.black,
      ),
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
                      "Informe o seu email",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25.0,
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
                        labelText: "E-mail",
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
                          "Redefinir",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      onPressed: () {
                        if(emailController.text == null || emailController.text == ''){
                          mensagem("Informe um E-mail");
                        }else{
                          String emailAddress = emailController.text;
                          if(!listaDeEmails.contains(emailAddress)){
                            bool emailOk = true;
                            FirebaseAuth.instance.sendPasswordResetEmail(email: emailAddress)
                            .onError((error, stackTrace) => {
                              emailOk = false,
                              mensagem("Esse e-mail não está cadastrado"),
                            })
                            .whenComplete(() => {
                              if(emailOk){
                                mensagem("E-mail para redefinir senha foi enviado para: "+emailAddress),
                                listaDeEmails.add(emailAddress)
                              }
                              
                            });
                            
                          }else{
                            mensagem("E-mail já enviado");
                          }
                        }
                      }
                    ),
                ],
              ),
            ),
          )),
    );
  }
  Widget mensagem(String mensagem) {
    final snackBar = SnackBar(
      content: Text(mensagem),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
