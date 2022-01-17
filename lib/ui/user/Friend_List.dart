import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto/object/User.dart';
import 'package:projeto/service/firebaseService.dart';
import 'package:projeto/ui/estabelecimento/Establishment_Page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class FiendList extends StatefulWidget {
  final String acao;
  final String matchUid;
  const FiendList({Key key, this.acao, this.matchUid}) : super(key: key);

  @override
  _FiendListState createState() => _FiendListState();
}

class _FiendListState extends State<FiendList> {
  String userAuthId;
  final firestoreInstance = FirebaseFirestore.instance;
  FirebaseService firebaseService = FirebaseService(FirebaseAuth.instance);
  final db = FirebaseFirestore.instance;
  CollectionReference establishment =
  FirebaseFirestore.instance.collection('match');

  @override
  Widget build(BuildContext context) {
    userAuthId = FirebaseAuth.instance.currentUser.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Amigos",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("User")
            .doc(userAuthId)
            .collection("Friends")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //if(snapshot) return Text('');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              LinearProgressIndicator();
              break;
            default:
              return ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children:
                snapshot.data.docs.map<Widget>((DocumentSnapshot doc) {
                  return Container(
                    child: FutureBuilder(
                        future: getFutureDados(doc.data()['uid']),
                        builder: (context, snapshot) {
                          if(snapshot.data.name != null){
                            if(widget.acao == 'request_match'){
                              return GestureDetector(
                                onTap: (){
                                  _showDialog(context);
                                },
                                child: playerCardMatch(snapshot.data.name, snapshot.data.uid, snapshot.data.urlImageProfile, widget.matchUid),
                              );

                            }
                            if (snapshot.hasData){
                              return playerCard(snapshot.data.name, snapshot.data.uid, snapshot.data.urlImageProfile);
                            }else{
                              return playerCard(doc.data()['nome'], doc.data()['uid'], null);
                            }
                          }else{
                            return Text('');
                          }


                        }
                    ),
                  );

                  //return playerCard(doc.data()['nome'], doc.data()['uid']);
                }).toList(),
              );
          }
          return Text('');
        },
      ),
    );
  }
}

Widget playerCard(String nome, String uid, String image) {
  String userAuthId = FirebaseAuth.instance.currentUser.uid;
  return Card(
    child: Container(
      color: Colors.lightGreen,
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: campoImage(image),
                ),
                Expanded(
                  flex: 7,
                  child: Container(
                    padding: EdgeInsets.only(left: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 5.0),
                          child: Text(
                            nome,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      ],
                    ),
                  ),
                )

              ],
            ),
          ),
          Expanded(
              flex: 2,
              child: Row(
                children: [
                  GestureDetector(
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      child: Icon(
                        Icons.person_remove_sharp,
                        size: 50.0,
                        color: Colors.red,
                      ),
                    ),
                    onTap: (){
                      FirebaseFirestore.instance
                          .collection("User")
                          .doc(userAuthId)
                          .collection("Friends")
                          .doc(uid)
                          .delete();

                      FirebaseFirestore.instance
                          .collection("User")
                          .doc(uid)
                          .collection("Friends")
                          .doc(userAuthId)
                          .delete();

                      mensagem("Solicitação recusada");
                    },
                  ),
                ],
              )
          ),
        ],
      ),
    ),
  );
}

Widget playerCardMatch(String nome, String uid, String image, String matchUid) {
  return Card(
      child: Container(
        color: Colors.lightGreen,
        child: Row(
          children: [
            Expanded(
              flex: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: campoImage(image),
                  ),
                  Expanded(
                    flex: 7,
                    child: Container(
                      padding: EdgeInsets.only(left: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 5.0),
                            child: Text(
                              nome,
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                        ],
                      ),
                    ),
                  )

                ],
              ),
            ),
          ],
        ),
      ),
    );
}

Widget mensagem(String mensagem) {
  final snackBar = SnackBar(
    content: Text(mensagem),
  );
}

Widget campoImage(String urlImage) {
  if (urlImage != null) {
    return Image.network(
      urlImage,
      height: 100.0,
      width: 70.0,
      fit: BoxFit.fill,
    );
  } else {
    return Container(
      height: 90.0,
      width: 70.0,
      color: Colors.grey,
      child: Icon(
        Icons.image,
        size: 60.0,
        color: Colors.white,
      ),
    );
  }
}

Future<UserPlayer> getFutureDados(String userUid) async {
  UserPlayer userAtual = new UserPlayer();
  userAtual.uid = userUid;
  await FirebaseFirestore.instance
          .collection('User')
          .doc(userUid)
          .get().then((value) => {
            userAtual.name = value.data()['nome']
          });
  userAtual.urlImageProfile = await firebase_storage.FirebaseStorage.instance
                                .ref('/image_profile/' + userUid)
                                .getDownloadURL();

  return userAtual;
}

_showDialog(BuildContext context)
{

  VoidCallback continueCallBack = () => {
    Navigator.of(context).pop(),
    // code on continue comes here

  };
  BlurryDialog  alert = BlurryDialog("Enviar convite","Deseja convidar esse jogador ?");


  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
class BlurryDialog extends StatelessWidget {

  String title;
  String content;

  BlurryDialog(this.title, this.content);
  TextStyle textStyle = TextStyle (color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child:  AlertDialog(
          title: new Text(title,style: textStyle,),
          content: new Text(content, style: textStyle,),
          actions: <Widget>[
            new FlatButton(
              child: Text("Sim"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ));
  }
}