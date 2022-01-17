import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projeto/object/CampoRetorno.dart';
import 'package:projeto/object/Establishment.dart';
import 'package:projeto/object/MatchFilter.dart';
import 'package:projeto/object/User.dart';
import 'package:projeto/service/firebaseService.dart';
import 'package:projeto/ui/partida/Details_Match.dart';
import 'package:projeto/ui/user/Edit_User_Page.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:projeto/ui/user/Other_User_Page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clipboard/clipboard.dart';
import 'package:dwds/dwds.dart';
import 'package:geocoding/geocoding.dart';
import 'package:projeto/object/Location.dart';
import 'package:hexcolor/hexcolor.dart';





class HomePlayer extends StatefulWidget {
  @override
  _HomePlayerState createState() => _HomePlayerState();
}

int _index = 1;

class _HomePlayerState extends State<HomePlayer> {
  List<Match> match;
  PickedFile imageFile;
  FirebaseService firebaseService = FirebaseService(FirebaseAuth.instance);
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  final firestoreInstance = FirebaseFirestore.instance;
  TextEditingController userSearch = new TextEditingController();
  UserPlayer userAuth = new UserPlayer();
  List<String> partidas = [];
  String statusFiltro = 'pendente';
  bool selectPendente = true;
  bool selectConfirmado = false;
  bool selectIniciado = false;
  bool selectFinalizado = false;


  @override
  Future<void> initState() {
    userAuth.uid = FirebaseAuth.instance.currentUser.uid;
    _getCurrentLocation();
    this.userAuth.getUsetAuthData().whenComplete(() => setState(() => {}));
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
              title: Text('Lista de amigos'),
              onTap: () {
                Navigator.pushNamed(context, '/friend_list');
              },
            ),
            ListTile(
              title: Text('Pedidos de amizade'),
              onTap: () {
                Navigator.pushNamed(context, '/friend_request');
              },
            ),
            ListTile(
              title: Text('Sair'),
              onTap: () {
                firebaseService.sair();
              },
            ),
            
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/create_match');
          CampoRetorno.resetValue();
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
              overflow: TextOverflow.ellipsis,
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
                                builder: (context) => UserEditPage())).whenComplete(() =>
                        {this.userAuth.getUsetAuthData().whenComplete(() => setState(() => {}))});
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
                              overflow: TextOverflow.ellipsis,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 5.0),
                                    child: Text(
                                      "Posições: " + userAuth.positions,
                                      style: TextStyle(
                                          fontSize: 15.0, color: Colors.white),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 5.0),
                                    child: Text(
                                      "Jogos: "+this.userAuth.jogos.toString(),
                                      style: TextStyle(
                                          fontSize: 15.0, color: Colors.white),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 5.0),
                                    child: Text(
                                      "Gols: "+this.userAuth.gols.toString(),
                                      style: TextStyle(
                                          fontSize: 15.0, color: Colors.white),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 5.0),
                                    child: Text(
                                      "Assistencias: "+this.userAuth.assistencias.toString(),
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
                  FirebaseFirestore.instance
                      .collection("match")
                      .where("status", isEqualTo: "confirmada")
                      .snapshots(),
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
                        return Container(
                            child: FutureBuilder(
                              future: getFutureDados(doc.data()['estabelecimentoUid'], "Não filtrar"),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data.distance <= 50) {
                                  return jogo(
                                      doc.data()['nome'],
                                      doc.data()['data'],
                                      doc.data()['preco'].toString(),
                                      snapshot.data.distance,
                                      doc.id,
                                      doc.data()['status'],
                                      doc.data()['urlImage'],
                                      snapshot.data.endereco);
                                } else {
                                  return Container();
                                }
                              }
                            ),
                          );
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
    return SingleChildScrollView(
      child: Column(
        children: [
          SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(left: 5.0, right: 5.0),
            child: InputChip(
              backgroundColor: HexColor("#8B0000"),
              selectedColor: HexColor("#FF0000"),
              label: Text('Pendentes'),
              selected: selectPendente,
              onSelected: (bool value) {
                statusFiltro = 'pendente';
                setState(() {
                  selectPendente = true;
                  selectConfirmado = false;
                  selectIniciado = false;
                  selectFinalizado = false;
                });
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 5.0),
            child: InputChip(
              backgroundColor: HexColor("#006400"),
              selectedColor: HexColor("#00FF00"),
              label: Text('Confirmadas'),
              selected: selectConfirmado,
              onSelected: (bool value) {
                statusFiltro = 'confirmada';
                setState(() {
                  selectPendente = false;
                  selectConfirmado = true;
                  selectIniciado = false;
                  selectFinalizado = false;
                });
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 5.0),
            child: InputChip(
              backgroundColor: HexColor("#FFD700"),
              selectedColor: HexColor("#FFFF00"),
              label: Text('Em andamento'),
              selected: selectIniciado,
              onSelected: (bool value) {
                statusFiltro = 'iniciada';
                setState(() {
                  selectPendente = false;
                  selectConfirmado = false;
                  selectIniciado = true;
                  selectFinalizado = false;
                });
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 5.0),
            child: InputChip(
              backgroundColor: HexColor("#A9A9A9"),
              selectedColor: HexColor("#FFFFFF"),
              label: Text('Finalizado'),
              selected: selectFinalizado,
              onSelected: (bool value) {
                statusFiltro = 'finalizada';
                setState(() {
                  selectPendente = false;
                  selectConfirmado = false;
                  selectIniciado = false;
                  selectFinalizado = true;
                });
              },
            ),
          )
        ],
      ),
    ),
          //historico("Partidas criadas"),
          historico("Partidas inscritas"),
        ],
      ),
    );
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
                  //.where(FieldPath.documentId, whereIn: this.partidas)
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

                          return Container(
                            child: FutureBuilder(
                              future: getFutureDados(doc.data()['estabelecimentoUid'], doc.id),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data.jogadorInscrito) {
                                  return jogo(
                                      doc.data()['nome'],
                                      doc.data()['data'],
                                      doc.data()['preco'].toString(),
                                      snapshot.data.distance,
                                      doc.id,
                                      doc.data()['status'],
                                      doc.data()['urlImage'],
                                      snapshot.data.endereco);
                                } else {
                                  return Container();
                                }
                              }
                            ),
                          );

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

  getFutureDados(String estabelecimentoUid, String matchUid) async {
    MatchFilter estabelecimento = new MatchFilter();
    if(matchUid != "Não filtrar"){
      FirebaseFirestore
        .instance
        .collection("match")
        .doc(matchUid)
        .collection("players")
        .get().then((value) => {
          value.docs.forEach((element) {
            if(element.data()['userUid'] == this.userAuth.uid){
              estabelecimento.jogadorInscrito = true;
            }
          })
      });
      
    }else{
      estabelecimento.jogadorInscrito = true;
    }

    await FirebaseFirestore.instance
        .collection('Establishment')
        .doc(estabelecimentoUid)
        .get()
        .then((value) => {
      estabelecimento.endereco = value.data()['endereco'],
      estabelecimento.latitude = value.data()['latitude'],
      estabelecimento.longitude = value.data()['longitude'],
    }).whenComplete(() => {
      estabelecimento.distance = (Geolocator.distanceBetween(LocationUser.latitude,
                                                             LocationUser.longitude,
                                                             estabelecimento.latitude,
                                                             estabelecimento.longitude)/1000).round(),
    });

    return estabelecimento;
  }


  Widget jogo(String nome, String data, String preco, int km, String id,
      String status, String urlImage, String endereco)  {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context,
            MaterialPageRoute(builder: (context) => DetailsMatch(matchId: id))).then((value) => {
              userAuth.getUsetAuthData(),
              setState(() { }),
        });
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
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 5.0),
                                child: Text(
                                  "Data: $data",
                                  style: TextStyle(fontSize: 15.0),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                "${km} Km",
                                style: TextStyle(fontSize: 13.0),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Text(
                            "Endereço: "+endereco,
                            style: TextStyle(fontSize: 15.0),
                            overflow: TextOverflow.ellipsis,
                          ),
                        
                          Text(
                            "Preço: R\$ $preco",
                            style: TextStyle(fontSize: 15.0),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Status: $status",
                            style: TextStyle(fontSize: 15.0),
                            overflow: TextOverflow.ellipsis,
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
    if (urlImage == null || urlImage == "") {
      return Container(
        height: 100.0,
        width: 70.0,
        color: Colors.grey,
        child: Icon(
          Icons.image,
          size: 60.0,
          color: Colors.white,
        ),
      );
    } else {
      return Image.network(
        urlImage,
        height: 100.0,
        width: 70.0,
        fit: BoxFit.fill,
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

  void _getCurrentLocation() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        });
      }else{
        var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        setState(() {
          LocationUser.longitude = position.longitude;
          LocationUser.latitude = position.latitude;
        });
      }
    }else{
      var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        LocationUser.longitude = position.longitude;
        LocationUser.latitude = position.latitude;
      });
    }
  }
}

Widget mensagem(String mensagem) {
  final snackBar = SnackBar(
    content: Text(mensagem),
  );
}


