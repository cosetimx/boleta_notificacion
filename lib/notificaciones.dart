import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificacionesPage extends StatelessWidget {
  static String tag = 'notificaciones';
  final NumEmp;
  final Nombre;
  final id;

  NotificacionesPage({this.NumEmp, this.id, this.Nombre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: NotificacionesPageMap(NumEmp: NumEmp, id: id, Nombre: Nombre),
      ),
    );
  }
}

class NotificacionesPageMap extends StatefulWidget {
  final NumEmp;
  final id;
  final Nombre;
  NotificacionesPageMap({this.NumEmp, this.id, this.Nombre});

  State<NotificacionesPageMap> createState() =>
      NotificacionesPageState(NumEmp: NumEmp, id: id, Nombre: Nombre);
}

class NotificacionesPageState extends State<NotificacionesPageMap> {
  List<MenuItem> menuItems = <MenuItem>[];

  final NumEmp;
  final id;
  final Nombre;
  NotificacionesPageState({this.NumEmp, this.id, this.Nombre});
  TextEditingController mensaje = TextEditingController();
  String pushToken;
  bool charger = false;

  _sendMessage() async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(NumEmp)
        .collection('notificaciones')
        .add({
      'title': 'Notificacion',
      'body': mensaje.text,
      'created_at': DateTime.now(),
      'leido': 'no',
      'type': '1'
    }).then((error) {
      _getToken(mensaje.text);
      print('Then Add $error');
    });
    setState(() {
      mensaje = TextEditingController();
    });
  }

  void getUsers() async {
    FirebaseFirestore.instance.collection('user').get().then((value) {
      value.docs.forEach((element) {
        print('Users ${element.get('NumEmp')}');

        MenuItem users = new MenuItem();
        users.NumEmp = element.get('NumEmp');
        users.title = element.get('Nombre');
        users.page =  NotificacionesPage(
          NumEmp: element.get('NumEmp'),
          Nombre: element.get('Nombre'),
          id: element.id,
        );

        users.icon = Icons.supervised_user_circle;
        setState(() {
          menuItems.add(users);
        });
      });
    });
    setState(() {
      charger = true;
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUsers();
    setState(() {});
    _CheckNotify();

  }

  Future _CheckNotify() {
    FirebaseFirestore.instance
        .collection('user')
        .doc(NumEmp)
        .collection('notificaciones')
        .where('type', isEqualTo: '2')
        .where('leido', isEqualTo: 'no')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        element.reference.update(<String, dynamic>{'leido': 'si'});
      });
    });
  }

  _getToken(String mensajeS) {
    FirebaseFirestore.instance.collection('user').doc(id).get().then((value) {
      String Token = value.get('pushToken');
      print('Push Token $id $Token ');
      SendNotify(mensajeS, Token);
    });
  }

  Future SendNotify(String mensajeS, String Token) async {
    var client = http.Client();
    print("Emp $NumEmp");
    print("Token $Token");

    Map message = {
      "notification": {
        "title": "Atencion",
        "body": mensajeS,"sound": "default"
      },
      "to": Token
    };

    var header = {
      "Content-Type": "application/json",
      "Authorization":
          "key=AAAAf7yCKjw:APA91bEZfnkKP9EFISIsbYY1r8TOrEwXfK40lw_1Jxt93QKFiJ_09J7mkvLwNc3Ei6vvVD_pBlWGWFz_nieo7ai09FePmzFR8FmyPu5QdLduNqIbEhjM9gjPksVkNA7jQkEA8LjaDMYZ"
    };
    String URL = "https://fcm.googleapis.com/fcm/send";

    try {
      var uriResponse =
          await client.post(URL, headers: header, body: jsonEncode(message));
      print('Response ${jsonDecode(uriResponse.body)}');
    } catch (e) {
      print('Error $e');
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final EnvioMensaje = Container(
      margin: EdgeInsets.all(15.0),
      height: 61,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35.0),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 3), blurRadius: 5, color: Colors.grey)
                ],
              ),
              child: Row(
                children: [
                  /*  IconButton(
                    icon: Icon(
                      Icons.face,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {}), */
                  Expanded(
                    child: TextField(
                      controller: mensaje,
                      decoration: InputDecoration(
                          hintText: "Escriba su mensaje...",
                          hintStyle: TextStyle(color: Colors.blueAccent),
                          border: InputBorder.none),
                    ),
                  ),
                  /*  IconButton(
                    icon: Icon(Icons.photo_camera, color: Colors.blueAccent),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.attach_file, color: Colors.blueAccent),
                    onPressed: () {},
                  ) */
                ],
              ),
            ),
          ),
          SizedBox(width: 15),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration:
                BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.white,
              ),
              onPressed: () {
                _sendMessage();
              },
            ),
          )
        ],
      ),
    );

    // TODO: implement build
    return Scaffold(
        resizeToAvoidBottomInset: false,
      //  backgroundColor: Colors.brown[100],
        appBar: AppBar(
          title: Text('Notificaciones $Nombre'),
        ),
        body:
        Container(
            width:   MediaQuery.of(context).size.width,
            child :
            Column(
                children: <Widget>[
                  Expanded(
                      child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Flexible(
                                child: ListView(
                                  children: <Widget>[
                                    ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemBuilder: (BuildContext context, int index) {
                                        print('Menu Items ${menuItems.length}');
                                        return MenuItemWidget(menuItems[index]);
                                      },
                                      itemCount: menuItems.length,
                                    ),
                                  ],
                                )),
                            Expanded(
                              child: Container(
                                child: SingleChildScrollView(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Container(
                                              width: MediaQuery.of(context).size.width,
                                              height: MediaQuery.of(context).size.height - 170,
                                              child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [
                                                    StreamBuilder(
                                                        stream: FirebaseFirestore.instance
                                                            .collection('user')
                                                            .doc(NumEmp)
                                                            .collection('notificaciones')
                                                            .orderBy('created_at', descending: true)
                                                            .snapshots(),
                                                        builder: (context, orderSnapshot) {
                                                          return orderSnapshot.hasData
                                                              ? Flexible(
                                                              child: ListView.builder(
                                                                reverse: true,
                                                                shrinkWrap: true,
                                                                itemCount: orderSnapshot.data.docs.length,
                                                                itemBuilder: (context, index) {
                                                                  DocumentSnapshot orderData =
                                                                  orderSnapshot.data.docs[index];
                                                                  _CheckNotify();
                                                                  bool isMe = orderData.get('type') == '2'
                                                                      ? true
                                                                      : false;
                                                                  bool delivered =
                                                                  orderData.get('leido') == 'si'
                                                                      ? true
                                                                      : false;

                                                                  final bg = isMe
                                                                      ? Colors.white
                                                                      : Colors.greenAccent.shade100;
                                                                  final align = isMe
                                                                      ? CrossAxisAlignment.start
                                                                      : CrossAxisAlignment.end;
                                                                  final icon = delivered
                                                                      ? Icons.done_all
                                                                      : Icons.done;
                                                                  final radius = isMe
                                                                      ? BorderRadius.only(
                                                                    topRight: Radius.circular(5.0),
                                                                    bottomLeft:
                                                                    Radius.circular(10.0),
                                                                    bottomRight:
                                                                    Radius.circular(5.0),
                                                                  )
                                                                      : BorderRadius.only(
                                                                    topLeft: Radius.circular(5.0),
                                                                    bottomLeft:
                                                                    Radius.circular(5.0),
                                                                    bottomRight:
                                                                    Radius.circular(10.0),
                                                                  );

                                                                  return Column(
                                                                    crossAxisAlignment: align,
                                                                    children: <Widget>[
                                                                      Container(
                                                                        margin: const EdgeInsets.all(3.0),
                                                                        padding:
                                                                        const EdgeInsets.all(8.0),
                                                                        decoration: BoxDecoration(
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                                blurRadius: .5,
                                                                                spreadRadius: 1.0,
                                                                                color: Colors.black
                                                                                    .withOpacity(.12))
                                                                          ],
                                                                          color: bg,
                                                                          borderRadius: radius,
                                                                        ),
                                                                        child: Stack(
                                                                          children: <Widget>[
                                                                            Padding(
                                                                              padding: EdgeInsets.only(
                                                                                  right: 48.0),
                                                                              child: Text(
                                                                                  orderData.get('body')),
                                                                            ),
                                                                            Positioned(
                                                                              bottom: 0.0,
                                                                              right: 0.0,
                                                                              child: Row(
                                                                                children: <Widget>[
                                                                                  SizedBox(width: 3.0),
                                                                                  isMe
                                                                                      ? SizedBox(
                                                                                      width: 3.0)
                                                                                      : Icon(
                                                                                    icon,
                                                                                    size: 12.0,
                                                                                    color: delivered
                                                                                        ? Colors
                                                                                        .blue
                                                                                        : Colors
                                                                                        .black38,
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      )
                                                                    ],
                                                                  );
                                                                },
                                                              ))
                                                              : CircularProgressIndicator();
                                                        }),
                                                  ])),
                                          EnvioMensaje,
                                        ])),
                                color: Colors.black26,
                              ),
                            ),

                          ]))]))




    );
  }
}

class MenuItem {
  MenuItem();
  String NumEmp;
  String title;
  StatelessWidget page;
  IconData icon;
}

class MenuItemWidget extends StatelessWidget {
  final MenuItem item;

  const MenuItemWidget(this.item);

  Widget _buildMenu(MenuItem menuItem, context) {
    return ListTile(
      leading: new CircleAvatar(
        backgroundImage: NetworkImage(
            'https://www.halcontracking.com/php/boleta/images/image_${menuItem.NumEmp}.png'),
      ),
      title: Text(
        menuItem.title,
        style: TextStyle(color: Colors.teal),
      ),
      onTap: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => menuItem.page,),
          ModalRoute.withName('/notify'),
        );

   /*     Navigator.of(context).push(
          new MaterialPageRoute(
            builder: (BuildContext context) => menuItem.page,
          ),
        ); */
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildMenu(this.item, context);
  }
}
