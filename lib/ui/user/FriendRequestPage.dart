import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto/service/firebaseService.dart';
import 'package:projeto/ui/estabelecimento/Establishment_Page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendRequestPage extends StatefulWidget {
  @override
  _FriendRequestPageState createState() => _FriendRequestPageState();
}

class _FriendRequestPageState extends State<FriendRequestPage> {
  String userAuthId;
  final firestoreInstance = FirebaseFirestore.instance;
  FirebaseService firebaseService = FirebaseService();
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
          "Pedidos de amizade",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Request")
            .doc(userAuthId)
            .collection("Friend")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
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
                  return playerCard(doc.data()['nome'], doc.data()['uid']);
                }).toList(),
              );
          }
          return Text('');
        },
      ),
    );
  }
}

Widget playerCard(String nome, String uid) {
  String userAuthId = FirebaseAuth.instance.currentUser.uid;

  return Card(
    child: Container(
      color: Colors.lightGreen,
      child: Row(
        children: [
          Expanded(
            flex: 8,
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
                    ),
                  ),

                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
              child: Row(
                children: [
                  GestureDetector(
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      child: Icon(
                        Icons.person_remove_sharp,
                        size: 25.0,
                        color: Colors.red,
                      ),
                    ),
                    onTap: (){
                      FirebaseFirestore.instance
                          .collection("Request")
                          .doc(userAuthId)
                          .collection("Friend")
                          .doc(uid)
                          .delete();

                      mensagem("Solicitação recusada");
                    },
                  ),
                  GestureDetector(
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      child: Icon(
                        Icons.person_add,
                        size: 25.0,
                        color: Colors.white,
                      ),
                    ),
                    onTap: (){
                      FirebaseFirestore.instance
                        .collection("User")
                        .doc(userAuthId)
                        .collection("Friends")
                        .doc(uid)
                        .set({"uid": uid});

                      FirebaseFirestore.instance
                          .collection("User")
                          .doc(uid)
                          .collection("Friends")
                          .doc(userAuthId)
                          .set({"uid": userAuthId});

                      FirebaseFirestore.instance
                          .collection("Request")
                          .doc(userAuthId)
                          .collection("Friend")
                          .doc(uid)
                          .delete();

                      mensagem("Solicitação aceita");
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

Widget mensagem(String mensagem) {
  final snackBar = SnackBar(
    content: Text(mensagem),
  );
}
