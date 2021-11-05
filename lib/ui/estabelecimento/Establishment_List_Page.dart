import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto/service/firebaseService.dart';
import 'package:projeto/ui/estabelecimento/Establishment_Page.dart';

class EstablishmentListPage extends StatefulWidget {
  @override
  _EstablishmentListPageState createState() => _EstablishmentListPageState();

}

class _EstablishmentListPageState extends State<EstablishmentListPage> {

  final firestoreInstance = FirebaseFirestore.instance;
  FirebaseService firebaseService = FirebaseService(FirebaseAuth.instance);
  final db = FirebaseFirestore.instance;
  CollectionReference establishment = FirebaseFirestore.instance.collection('match');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Estabelecimentos", style: TextStyle(color: Colors.white),),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Establishment").snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.waiting:
              LinearProgressIndicator();
              break;
            default:
              return ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: snapshot.data.docs.map<Widget>((DocumentSnapshot doc){

                  return GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => EstablishmentPage(estabelecimentoId: doc.id,)));
                    },
                    child: establishmentCard(
                      doc.data()['nome'],
                      doc.data()['endereco'],
                    ),
                  );

                }).toList(),
              );
          }
          return Text('');
        },
      ),

    );
  }
}
Widget establishmentCard(String nome, String endereco,) {
  return Card(
    child: Container(
      color: Colors.grey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 10,
                child: Container(
                  color: Colors.lightGreen,
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
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 5.0),
                            child: Text(
                              "Endereço: $endereco",
                              style: TextStyle(fontSize: 15.0),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          child: Text(
                            "Detalhes",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0
                            ),
                          ),
                          onTap: (){
                          },
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    ),
  );
}
