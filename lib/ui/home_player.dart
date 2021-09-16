import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projeto/object/User.dart';
import 'package:projeto/service/firebaseService.dart';
import 'package:projeto/ui/partida/Details_Match.dart';
import 'package:projeto/ui/user/Edit_User_Page.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:projeto/ui/user/Other_User_Page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clipboard/clipboard.dart';
import 'package:dwds/dwds.dart';


class HomePlayer extends StatefulWidget {
  @override
  _HomePlayerState createState() => _HomePlayerState();
}

int _index = 1;

class _HomePlayerState extends State<HomePlayer> {
  List<Match> match;
  PickedFile imageFile;
  FirebaseService firebaseService = FirebaseService();
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  final firestoreInstance = FirebaseFirestore.instance;
  TextEditingController userSearch = new TextEditingController();
  UserPlayer userAuth = new UserPlayer();
  List<String> partidas = [];
  String statusFiltro = 'pendente';

  @override
  void initState() {
    userAuth.uid = FirebaseAuth.instance.currentUser.uid;
    //this.userAuth.clearDataCache();
    this.userAuth.getUsetAuthData();
    this.partidas = [];
    this.getMatchs();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    switch (_index) {
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
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.all(0.0),
              ),
            ),
            ListTile(
              title: Text('Pedidos de amizade'),
              onTap: () {
                Navigator.pushNamed(context, '/friend_request');
              },
            ),
            ListTile(
              title: Text('Sair'),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
                Navigator.pushNamed(context, '/');
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
        onTap: (newIndex) => {
          if (newIndex == 2)
            {
              this
                  .getMatchs()
                  .whenComplete(() => setState(() => _index = newIndex))
            }
          else
            {setState(() => _index = newIndex)}
        },
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

  Widget perfilTela() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.visiblePassword,
            controller: userSearch,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderSide: new BorderSide(color: Colors.white, width: 0.0),
                  borderRadius: BorderRadius.circular(15.0)),
              labelText: "Codigo do jogador",
              labelStyle: TextStyle(
                color: Colors.black,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  firebaseService
                      .verificarSeJogadorExiste(userSearch.text)
                      .then((value) => {
                            if (value)
                              {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => OtherUserPage(
                                            userId: userSearch.text,
                                            acao: "add")))
                              }
                            else
                              {
                                mensagem("Jogador não existe"),
                              }
                          });
                },
                icon: Icon(Icons.search),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
            child: GestureDetector(
                onTap: () {
                  this
                      ._openGallery(context)
                      .then((value) => uploadFile(value.path));
                },
                child: imagemProfile()),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
            child: Text(
              userAuth.name,
              style: TextStyle(color: Colors.white, fontSize: 35.0),
            ),
          ),
          Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
              child: GestureDetector(
                onTap: () {
                  FlutterClipboard.copy(userAuth.uid);
                  mensagem("Código copiado");
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Código: " + userAuth.uid,
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
          /*Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 5.0),
            ),
            child: QrImage(
              backgroundColor: Colors.white,
              data: this.userAuth.uid,
              version: 11,
              size: 250.0,
            ),
          ),*/
        ],
      ),
    );
  }

  Widget pesquisarTela() {
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
                      child: pesquisaImagemProfile()),
                ),
                Expanded(
                    flex: 7,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserEditPage()));
                      },
                      child: Container(
                        child: Column(
                          children: [
                            Text(
                              userAuth.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22.0,
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 5.0),
                                    child: Text(
                                      "Posiçãos: " + userAuth.positions,
                                      style: TextStyle(
                                          fontSize: 15.0, color: Colors.white),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 5.0),
                                    child: Text(
                                      "Jogos: 15",
                                      style: TextStyle(
                                          fontSize: 15.0, color: Colors.white),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 5.0),
                                    child: Text(
                                      "Gols: 3",
                                      style: TextStyle(
                                          fontSize: 15.0, color: Colors.white),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 5.0),
                                    child: Text(
                                      "Assistencias: 7",
                                      style: TextStyle(
                                          fontSize: 15.0, color: Colors.white),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ))
              ],
            ),
          ),
          SingleChildScrollView(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection("match").snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    LinearProgressIndicator();
                    break;
                  default:
                    return ListView(
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: snapshot.data.docs
                          .map<Widget>((DocumentSnapshot doc) {
                        return jogo(
                            doc.data()['nome'],
                            doc.data()['data'],
                            doc.data()['preco'].toString(),
                            2,
                            doc.id,
                            doc.data()['status'],
                            doc.data()['urlImage']);
                      }).toList(),
                    );
                }
                return Text('');
              },
            ),
          )
        ],
      ),
    );
  }

  Widget partidasTelas() {
    if (this.partidas.isEmpty) {
      return Text(
        "Não possui partidas",
        style: TextStyle(color: Colors.white),
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  InputChip(
                    backgroundColor: Colors.red,
                    label: Text('Pendentes'),
                    onSelected: (bool value) {
                      statusFiltro = 'pendente';
                      setState(() {});
                    },
                  ),
                  InputChip(
                    backgroundColor: Colors.green,
                    label: Text('Confirmadas'),
                    onSelected: (bool value) {
                      statusFiltro = 'confirmada';
                      setState(() {});
                    },
                  ),
                  InputChip(
                    backgroundColor: Colors.yellow,
                    label: Text('Em andamento'),
                    onSelected: (bool value) {
                      statusFiltro = 'iniciada';
                      setState(() {});
                    },
                  ),
                  InputChip(
                    backgroundColor: Colors.white,
                    label: Text('Finalizado'),
                    onSelected: (bool value) {
                      statusFiltro = 'finalizada';
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            historico("Partidas criadas"),
            //historico("Partidas inscritas"),
          ],
        ),
      );
    }
  }

  Widget historico(String dia) {
    userAuth.uid = FirebaseAuth.instance.currentUser.uid;
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10.0, 0, 5.0),
      child: Column(
        children: [
          Text(
            dia,
            style: TextStyle(color: Colors.white, fontSize: 30.0),
          ),
          SingleChildScrollView(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("match")
                  .where(FieldPath.documentId, whereIn: this.partidas)
                  .where("status", isEqualTo: statusFiltro)
                  .get()
                  .asStream(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    LinearProgressIndicator();
                    break;
                  default:
                    if (snapshot.data == null && this.partidas.isEmpty) {
                      return LinearProgressIndicator();
                    }
                    return ListView(
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: snapshot.data.docs
                          .map<Widget>((DocumentSnapshot doc) {
                        if (doc.data() != null) {
                          return jogo(
                              doc.data()['nome'],
                              doc.data()['data'],
                              doc.data()['preco'].toString(),
                              2,
                              doc.id,
                              doc.data()['status'],
                              doc.data()['urlImage']);
                        } else {
                          return Container();
                        }
                      }).toList(),
                    );
                }
                return Text('');
              },
            ),
          )
        ],
      ),
    );
  }

  Widget jogo(String nome, String data, String preco, int km, String id,
      String status, String urlImage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => DetailsMatch(matchId: id)));
        firebaseService.getMatch();
      },
      child: Card(
        child: Container(
          color: Colors.lightGreen,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: campoImage(urlImage),
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
                          Text(
                            "Status: $status",
                            style: TextStyle(fontSize: 15.0),
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
      ),
    );
  }

  Widget campoImage(String urlImage) {
    if (urlImage != null) {
      return Image.network(
        urlImage,
        height: 90.0,
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

  Future<void> getMatchs() async {
    this.partidas = [];
    await FirebaseFirestore.instance
        .collection('User')
        .doc(userAuth.uid)
        .collection('matchs')
        .get()
        .then((value) => value.docs.forEach((element) => {
              this.partidas.add(element.data()['matchUid']),
            }));
  }

  Future<PickedFile> _openGallery(BuildContext context) async {
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );
    this.imageFile = pickedFile;
    return this.imageFile;
  }

  Future<void> uploadFile(String filePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    File file = File(filePath);

    await firebase_storage.FirebaseStorage.instance
        .ref('/image_profile/' + userAuth.uid)
        .putFile(file);
    this.userAuth.getUsetAuthData().whenComplete(() => setState(() => {}));
  }

  Widget imagemProfile() {
    if (userAuth.urlImageProfile != null) {
      return Container(
        width: 200.0,
        height: 200.0,
        child: ClipOval(
          child: Image.network(
            userAuth.urlImageProfile,
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
          size: 150.0,
          color: Colors.white,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 5.0),
          borderRadius: BorderRadius.circular(180.0),
        ),
      );
    }
  }

  Widget pesquisaImagemProfile() {
    if (userAuth.urlImageProfile != null) {
      return ClipOval(
          child: Image.network(
        userAuth.urlImageProfile,
        height: 90.0,
        //width: 90.0,
        fit: BoxFit.fill,
      ));
    } else {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey,
        child: Icon(
          Icons.person,
          color: Colors.black,
          size: 70.0,
        ),
      );
    }
  }
}

Widget mensagem(String mensagem) {
  final snackBar = SnackBar(
    content: Text(mensagem),
  );
}
