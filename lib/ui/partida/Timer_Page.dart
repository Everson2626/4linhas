import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:projeto/object/CampoRetorno.dart';

class TimePage extends StatefulWidget {
  final String campoId;
  final String establishmentUid;

  const TimePage({Key key, this.campoId, this.establishmentUid}) : super(key: key);

  @override
  _TimePageState createState() => _TimePageState();
}

class _TimePageState extends State<TimePage> {
  final precoController = new TextEditingController();
  DateTime dateTime = DateTime.now();
  String dia = DateTime.now().day.toString() +"-" +DateTime.now().month.toString() + "-" +DateTime.now().year.toString();
  String hora = DateTime.now().hour.toString()+":"+DateTime.now().minute.toString();
  String campoName = '';


  @override
  void initState() {
    this.getCampoName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Horários"),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            child: DateTimePicker(
              type: DateTimePickerType.date,
              dateMask: 'd MMM, yyyy',
              initialValue: DateTime.now().toString(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              icon: Icon(Icons.event),
              dateLabelText: 'Data',
              timeLabelText: "Hora",
              selectableDayPredicate: (date) {
                return true;
              },
              onChanged: (val) => {
                dateTime = DateTime.parse(val),
                dia = dateTime.day.toString() +"-" +dateTime.month.toString() + "-" +dateTime.year.toString(),
                hora = dateTime.hour.toString()+":"+dateTime.minute.toString(),
                setState(() => {}),
              },
              validator: (val) {
                print(val);
                return null;
              },
              onSaved: (val) => print(val),
            ),
          ),
          Divider(
            color: Colors.black,
            height: 5.0,
          ),
          Expanded(
              child: SingleChildScrollView(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("Establishment")
                        .doc(widget.establishmentUid)
                        .collection("campo")
                        .doc(widget.campoId)
                        .collection("horarios")
                        .doc("info")
                        .collection(dia)
                        .snapshots(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return LinearProgressIndicator();
                          break;
                        default:
                          return ListView(
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            children: snapshot.data.docs
                                .map<Widget>((DocumentSnapshot doc) {
                                  print(doc.data()['dia']);
                              return timeCard(doc.data()['dia'], doc.data()['hora'], doc.data()['preco'], doc.data()['Status'], doc.id);

                            }).toList(),
                          );
                      }
                    }

                ),
              )
          )

        ],
      ),
    );
  }

  void getCampoName(){
    print(widget.campoId);
    FirebaseFirestore
        .instance
        .collection("Establishment")
        .doc(widget.establishmentUid)
        .collection("campo")
        .doc(widget.campoId)
        .get().then((value) => {
       this.campoName = value.data()['nome'],
      print(value.data()['nome']),
    });
  }

  Widget timeCard(String dia, String hora, String preco, String status, String timeUid) {
    MaterialColor cor;
    if(status == "livre"){
      cor = Colors.lightGreen;
    }else if(status == "pendente"){
      cor = Colors.yellow;
    }else if(status == "ocupado"){
      cor = Colors.red;
    }


    return GestureDetector(
      onTap: (){
        if(status == "livre"){
          CampoRetorno.establishmentUid = widget.establishmentUid;
          CampoRetorno.campoUid = widget.campoId;
          CampoRetorno.nome = this.campoName;
          CampoRetorno.timeUid = timeUid;
          CampoRetorno.hora = hora;
          CampoRetorno.dia = dia;
          setState(() {});
          int count = 0;
          Navigator.of(context).popUntil((_) => count++ >= 3);
        }else{
          mensagem("Partida $status");
        }

      },
      child: Card(
        child: Container(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: Container(
                      color: cor,
                      padding: EdgeInsets.only(left: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 5.0),
                            child: Text(
                              dia.replaceAll("-", "/"),
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 5.0),
                            child: Text(
                              "Horario: $hora",
                              style: TextStyle(fontSize: 15.0),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 5.0),
                            child: Text(
                              "Valor: R\$ $preco",
                              style: TextStyle(fontSize: 15.0),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 5.0),
                            child: Text(
                              "Status: $status",
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
      ),
    );
  }

  Widget mensagem(String mensagem) {
    final snackBar = SnackBar(
      content: Text(mensagem),
      action: SnackBarAction(
        label: 'Desfazer',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
