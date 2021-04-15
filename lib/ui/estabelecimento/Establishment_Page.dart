import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto/service/firebaseService.dart';

class EstablishmentPage extends StatefulWidget {
  @override
  _EstablishmentPageState createState() => _EstablishmentPageState();
}

class _EstablishmentPageState extends State<EstablishmentPage> {

  final firestoreInstance = FirebaseFirestore.instance;
  FirebaseService firebaseService = FirebaseService();
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
                    child: establishmentCard(
                      doc.data()['nome'],
                      doc.data()['endereco'],
                    ),
                    onTap: (){
                      print("doc.data()");
                    },
                  );

                }).toList(),
              );
          }
          return Text('');
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_establishment');
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
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
