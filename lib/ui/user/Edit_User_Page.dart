import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projeto/object/User.dart';
import 'package:projeto/ui/home_player.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UserEditPage extends StatefulWidget {
  final String userId;
  const UserEditPage({Key key, this.userId}) : super(key: key);

  @override
  _UserEditPageState createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  UserPlayer userAuth;
  PickedFile imageFile;
  TextEditingController nome = new TextEditingController();

  @override
  void initState() {
    this.userAuth = new UserPlayer();
    this.userAuth.uid = widget.userId;
    setState(() {
      this.getUsetAuthData();
    });
  }

  var positionName = ["GO", "ZG", "LT", "MC", "AT"];
  bool GO = false;
  bool ZG = false;
  bool LT = false;
  bool MC = false;
  bool AT = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(nome.text),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20.0),
              color: Colors.white,
              child: Column(
                children: [
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
                  Row(
                    children: [
                      positionCheckBox(0),
                      positionCheckBox(1),
                      positionCheckBox(2),
                      positionCheckBox(3),
                      positionCheckBox(4),
                    ],
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "Nome do jogador"),
                    controller: nome,
                    onChanged: (nome) {
                      setState(() {});
                    },
                  ),
                  RaisedButton(
                    color: Colors.black,
                    child: Text(
                      "Salvar",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      UserPlayer user = new UserPlayer();
                      user.uid = FirebaseAuth.instance.currentUser.uid;
                      user.name = nome.text;

                      await user.atualizarUsuario().whenComplete(() => {
                            FirebaseFirestore.instance
                                .collection('User')
                                .doc(user.uid)
                                .collection('position')
                                .doc('position')
                                .update({
                              'GO': this.GO,
                              'ZG': this.ZG,
                              'LT': this.LT,
                              'MC': this.MC,
                              'AT': this.AT
                            }).whenComplete(() => Navigator.pop(context)),
                          });
                    },
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Widget positionCheckBox(int position) {
    bool isChecked = false;
    switch (position) {
      case 0:
        isChecked = GO;
        break;
      case 1:
        isChecked = ZG;
        break;
      case 2:
        isChecked = LT;
        break;
      case 3:
        isChecked = MC;
        break;
      case 4:
        isChecked = AT;
        break;
    }
    return Row(children: [
      Checkbox(
        value: isChecked,
        onChanged: (value) {
          setState(() {
            switch (position) {
              case 0:
                if (GO != null) {
                  GO = !isChecked;
                }
                break;
              case 1:
                if (ZG != null) {
                  ZG = !isChecked;
                }
                break;
              case 2:
                if (LT != null) {
                  LT = !isChecked;
                }
                break;
              case 3:
                if (MC != null) {
                  MC = !isChecked;
                }
                break;
              case 4:
                if (AT != null) {
                  AT = !isChecked;
                }
                break;
            }
          });
        },
      ),
      Text(
        positionName[position],
        style: TextStyle(color: Colors.black, fontSize: 12.0),
      ),
    ]);
  }

  Future<void> getUsetAuthData() async {
    var user = FirebaseAuth.instance.currentUser.uid;
    await FirebaseFirestore.instance
        .collection('User')
        .doc(user)
        .get()
        .then((value) => {
              this.nome.text = value['nome'],
            });
    await FirebaseFirestore.instance
        .collection('User')
        .doc(user)
        .collection("position")
        .doc("position")
        .get()
        .then((position) => {
              GO = position['GO'],
              ZG = position['ZG'],
              LT = position['LT'],
              MC = position['MC'],
              AT = position['AT'],
            });

    this.userAuth.urlImageProfile = await firebase_storage
        .FirebaseStorage.instance
        .ref('image_profile/' + user)
        .getDownloadURL();
    setState(() {});
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

  Future<PickedFile> _openGallery(BuildContext context) async {
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );
    this.imageFile = pickedFile;
    return this.imageFile;
  }

  Future<void> uploadFile(String filePath) async {
    File file = File(filePath);
    userAuth.uid = FirebaseAuth.instance.currentUser.uid;
    await firebase_storage.FirebaseStorage.instance
        .ref('/image_profile/' + userAuth.uid)
        .putFile(file);
    this.userAuth.getUsetAuthData().whenComplete(() => setState(() => {}));
  }
}
