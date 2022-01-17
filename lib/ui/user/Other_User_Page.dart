import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto/object/User.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:clipboard/clipboard.dart';

class OtherUserPage extends StatefulWidget {
  final String userId;
  final String acao;
  final String match;

  const OtherUserPage({Key key, this.userId, this.acao = '', this.match = ''}) : super(key: key);

  @override
  _OtherUserPageState createState() => _OtherUserPageState();
}

class _OtherUserPageState extends State<OtherUserPage> {
  UserPlayer user = new UserPlayer();
  bool isFriend = false;

  @override
  void initState() {
    user.uid = widget.userId;
    this.getUsetAuthData();
    verificaSeJaEAmigo().then((value) => {
          this.isFriend = value,
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(255, 255, 255, 0),
        title: Text(
          "Adicionar amigo",
          style: TextStyle(
            fontSize: 30.0,
          ),
        ),
      ),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                child: imagemProfile(),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                child: Text(
                  user.name,
                  style: TextStyle(color: Colors.white, fontSize: 35.0),
                ),
              ),
              Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                  child: GestureDetector(
                    onTap: () {
                      FlutterClipboard.copy(user.uid);
                      mensagem("Código copiado");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Código: " + user.uid,
                          style: TextStyle(color: Colors.white, fontSize: 15.0),
                        ),
                        Icon(
                          Icons.copy,
                          color: Colors.white,
                          size: 15.0,
                        )
                      ],
                    ),
                  )),
              Container(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                child: Acao(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget imagemProfile() {
    if (user.urlImageProfile != null) {
      return Container(
        width: 200.0,
        height: 200.0,
        child: ClipOval(
          child: Image.network(
            user.urlImageProfile,
            height: 200.0,
            width: 200.0,
            fit: BoxFit.fill,
          ),
        ),
      );
    } else {
      return Container(
        width: 200.0,
        height: 200.0,
        child: Icon(
          Icons.person,
          size: 19.0,
          color: Colors.white,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 5.0),
          borderRadius: BorderRadius.circular(180.0),
        ),
      );
    }
  }

  Future<void> getUsetAuthData() async {
    FirebaseFirestore.instance
        .collection('User')
        .doc(user.uid)
        .get()
        .then((value) => {
              user.name = value['nome'],
            });

    user.urlImageProfile = await firebase_storage.FirebaseStorage.instance
        .ref('image_profile/' + user.uid)
        .getDownloadURL();

    setState(() {});
    print(user.uid);
  }

  Widget Acao() {
    if (widget.acao == "add" && isFriend != null) {
      if (isFriend) {
        return RaisedButton(
            color: Colors.red,
            child: Container(
              child: Text(
                "Excluir amigo",
                style: TextStyle(color: Colors.white),
              ),
            ),
            onPressed: () {
              String userAuthId = FirebaseAuth.instance.currentUser.uid;

              FirebaseFirestore.instance
                        .collection("User")
                        .doc(userAuthId)
                        .collection("Friends")
                        .doc(user.uid)
                        .delete();

                      FirebaseFirestore.instance
                          .collection("User")
                          .doc(user.uid)
                          .collection("Friends")
                          .doc(userAuthId)
                          .delete();
              mensagem("Amigo excluid");
            });
      } else {
        return RaisedButton(
            color: Colors.white,
            child: Container(
              child: Text(
                "Adicionar amigo",
                style: TextStyle(color: Colors.black),
              ),
            ),
            onPressed: () {
              String userAuthUid = FirebaseAuth.instance.currentUser.uid;

              FirebaseFirestore.instance
                  .collection("Request")
                  .doc(user.uid)
                  .collection("Friend")
                  .doc(userAuthUid)
                  .set({"uid": userAuthUid, "nome": user.name});
              mensagem("Pedido enviado");
            });
      }
    } else if(widget.acao == "request_match"){
      return RaisedButton(
          color: Colors.white,
          child: Container(
            child: Text(
              "Convidar",
              style: TextStyle(color: Colors.black),
            ),
          ),
          onPressed: () {
            String userAuthUid = FirebaseAuth.instance.currentUser.uid;
            FirebaseFirestore.instance
                .collection("Request")
                .doc(user.uid)
                .collection("Match")
                .doc(userAuthUid)
                .set({"matchUid": widget.match, "playerUid": userAuthUid});
            mensagem("Pedido enviado");
          });

    }
    else {
      return Container();
    }
  }

  Widget mensagem(String mensagem) {
    return SnackBar(
      content: Text(mensagem),
    );
  }

  Future<bool> verificaSeJaEAmigo() async {
    String userAuthUid = FirebaseAuth.instance.currentUser.uid;
    bool resposta;
    await FirebaseFirestore.instance
        .collection("User")
        .doc(userAuthUid)
        .collection("Friends")
        .where(FieldPath.documentId, isEqualTo: user.uid)
        .get()
        .then((value) => {
              if (value.size > 0)
                {
                  resposta = true,
                }
              else
                {
                  resposta = false,
                }
            });
    return resposta;
  }
}
