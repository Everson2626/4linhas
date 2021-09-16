import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto/object/Campo.dart';
import 'package:projeto/object/CampoRetorno.dart';
import 'package:projeto/service/firebaseService.dart';
import 'package:projeto/ui/campo/Create_Campo.dart';

import 'Establishment_List_Page.dart';

class EstablishmentPage extends StatefulWidget {
  final String estabelecimentoId;

  const EstablishmentPage({Key key, this.estabelecimentoId}) : super(key: key);



  @override
  _EstablishmentState createState() => _EstablishmentState();
}

class _EstablishmentState extends State<EstablishmentPage> {
  final firestoreInstance = FirebaseFirestore.instance;
  FirebaseService firebaseService = FirebaseService();
  final db = FirebaseFirestore.instance;

  CollectionReference collection;
  List<Campo> listaCampo  = List<Campo>();

  @override
  void initState() {
    //LARGURA, LIMITE, COMPRIMENTO, NOME
    //print(listaCampo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Estabelecimentos", style: TextStyle(color: Colors.white),),
      ),

      body: Column(
        children: [
          Text(""),
          Expanded(
            child: SizedBox(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Establishment')
                    .doc(widget.estabelecimentoId)
                    .collection('campo')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return CircularProgressIndicator();
                    default:
                      if(snapshot.data.docs.length > 0){
                        return ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot document = snapshot.data.docs[index];
                            return GestureDetector(
                              onTap: (){
                                CampoRetorno.establishmentUid = widget.estabelecimentoId;
                                CampoRetorno.campoUid = snapshot.data.docs[index].id;
                                CampoRetorno.nome = document["nome"];
                                setState(() {});
                                int count = 0;
                                Navigator.of(context).popUntil((_) => count++ >= 2);
                              },
                              child: campoCard(document["nome"],document["limite_jogadores"],document["largura"],document["comprimento"]),
                            );
                          },
                        );
                      }else{
                        return Text("Nenhum campo cadastrado");
                      }
                  }
                },
              ),
            ),
          ),
        ],
      ),

    );
  }
}
Widget campoCard(String nome,int lim_jogador, int largura, int comprimento) {
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
                      Padding(
                        padding: EdgeInsets.only(right: 5.0),
                        child: Text(
                          "Jogadores: (0/$lim_jogador)",
                          style: TextStyle(fontSize: 15.0),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 5.0),
                        child: Text(
                          "Dimensões: $comprimento/$largura",
                          style: TextStyle(fontSize: 15.0),
                        ),
                      ),
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
