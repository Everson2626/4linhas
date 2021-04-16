import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto/service/firebaseService.dart';

class HomePlayer extends StatefulWidget {
  @override
  _HomePlayerState createState() => _HomePlayerState();
}

int _index = 1;


class _HomePlayerState extends State<HomePlayer> {
  List<Match> match;
  FirebaseService firebaseService = FirebaseService();
  final firestoreInstance = FirebaseFirestore.instance;

  @override
  void initState() {

  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    switch(_index){
      case 0:
        child = perfilTela();
        break;
      case 1:
        child = pesquisarTela();
        break;
      case 2:
        child = partidasTelas();
        break;
    }
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(255, 255, 255, 0),
        title: Text(
          "4 LINHAS",
          style: TextStyle(
            fontSize: 30.0,
          ),
        ),
      ),

      body: SizedBox.expand(child: child),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 60.0,
              child: DrawerHeader(
                child: Text(
                  '4 LINHAS',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.all(0.0),
              ),
            ),
            ListTile(
              title: Text('Estabelecimentos'),
              onTap: () {
                Navigator.pushNamed(context, '/establishment_list');
              },
            ),
            ListTile(
              title: Text('Criar campo'),
              onTap: () {
                Navigator.pushNamed(context, '/create_campo');
              },
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_match');
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (newIndex) => setState(() => _index = newIndex),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Pesquisar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            label: 'Partidas',
          ),
        ],
        selectedItemColor: Colors.green,
      ),
    );
  }

  Widget perfilTela(){
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          Container(
            child: Icon(
              Icons.person,
              size: 200.0,
              color: Colors.white,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white,width: 5.0),
              borderRadius: BorderRadius.circular(180.0),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
            child: Text(
              "Nome Completo",
              style: TextStyle(color: Colors.white, fontSize: 35.0),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white,width: 5.0),
            ),
            child: Icon(
              Icons.qr_code,
              color: Colors.white,
              size: 200.0,
            ),
          )
        ],
      ),
    );
  }

  Widget pesquisarTela(){
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 135.0,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      child: Icon(
                        Icons.person,
                        color: Colors.black,
                        size: 70.0,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      Text(
                        "Éverson Luiz Santos",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 5.0),
                            child: Text(
                              "Posição: ",
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection("match").snapshots(),
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
                      return jogo(
                        doc.data()['nome'],
                        doc.data()['data'],
                        doc.data()['preco'].toString(),
                        2
                      );
                    }).toList(),
                  );
              }
              return Text('');
            },
          ),

        ],
      ),
    );
  }

  Widget partidasTelas(){
    return SingleChildScrollView(
      child: Column(
        children: [
          historico("Hoje"),
          historico("Ontem"),
          historico("Domingo"),
          historico("Sabado"),
        ],
      ),
    );
  }

  Widget historico(String dia){
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10.0, 0, 5.0),
      child: Column(
        children: [
          Text(dia, style: TextStyle(color: Colors.white, fontSize: 30.0),),
          jogo("Partida", "16/01/2021", "0.0", 2),
        ],
      ),
    );
  }

  Widget jogo(String nome, String data, String preco, int km) {
    return Card(
      child: Container(
        color: Colors.grey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    child: Icon(
                      Icons.image,
                      size: 60.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 7,
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
                                "Data: $data",
                                style: TextStyle(fontSize: 15.0),
                              ),
                            ),
                            Text(
                              "${km} Km",
                              style: TextStyle(fontSize: 13.0),
                            ),
                          ],
                        ),
                        Text(
                          "Preço: R\$ $preco",
                          style: TextStyle(fontSize: 15.0),
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
                              firebaseService.getMatch();
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


}
