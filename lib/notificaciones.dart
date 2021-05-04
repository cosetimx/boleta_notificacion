
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificacionesPage extends StatelessWidget {
  static String tag = 'notificaciones';
  final NumEmp;
  final pushToken;

  NotificacionesPage({this.NumEmp, this.pushToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: NotificacionesPageMap(NumEmp : NumEmp, pushToken : pushToken),
      ),
    );
  }
}

class NotificacionesPageMap extends StatefulWidget {
  final NumEmp;
  final pushToken;
  NotificacionesPageMap({this.NumEmp, this.pushToken});

  State<NotificacionesPageMap> createState() => NotificacionesPageState(NumEmp : NumEmp, pushToken : pushToken);
}

class NotificacionesPageState extends State<NotificacionesPageMap> {
  final NumEmp;
  final pushToken;
  NotificacionesPageState({this.NumEmp, this.pushToken});
  TextEditingController mensaje = TextEditingController();

  _sendMessage() async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(NumEmp)
        .collection('notificaciones')
        .add(
        { 'title' : 'Notificacion',
          'body' : mensaje.text,
          'created_at' : DateTime.now(),
          'leido' : 'no',
          'type' : '1'
        }
    ).then((error) {
      SendNotify(mensaje.text);
      print('Then Add $error');
    });
    setState(() {
      mensaje = TextEditingController();
    });

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
    });
    _CheckNotify();
  }


  Future _CheckNotify() {
    FirebaseFirestore.instance
        .collection('user')
        .doc(NumEmp)
        .collection('notificaciones')
        .where('type', isEqualTo: '2')
        .where('leido', isEqualTo: 'no').get()
        .then((value) {
          value.docs.forEach((element) {
            element.reference.update(<String, dynamic>{
              'leido' : 'si'
            });
          });

    });
  }
  Future SendNotify(String mensajeS) async {
    var client = http.Client();
    print("Token $NumEmp");
    print("Token $pushToken");

    Map message = {
      "notification": {
        "title": "Atencion",
        "body": mensajeS,
        "sound": "default"
      },
      "to": pushToken
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
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        title: Text('Notificaciones'),
      ),
      body:
      SingleChildScrollView(
          child :
          Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
      Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height -170,
        child:
        Column(
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
                        ?
                    Flexible(
                        child:
                        ListView.builder(
                          reverse: true,
                          shrinkWrap: true,
                          itemCount: orderSnapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot orderData =
                        orderSnapshot.data.docs[index];
                         _CheckNotify();
                        bool isMe = orderData.get('type') == '2' ? true : false;
                        bool delivered =
                        orderData.get('leido') == 'si' ? true : false;

                        final bg =
                        isMe ? Colors.white : Colors.greenAccent.shade100;
                        final align = isMe
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end;
                        final icon = delivered ? Icons.done_all : Icons.done;
                        final radius = isMe
                            ? BorderRadius.only(
                          topRight: Radius.circular(5.0),
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(5.0),
                        )
                            : BorderRadius.only(
                          topLeft: Radius.circular(5.0),
                          bottomLeft: Radius.circular(5.0),
                          bottomRight: Radius.circular(10.0),
                        );


                        return Column(
                          crossAxisAlignment: align,
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.all(3.0),
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: .5,
                                      spreadRadius: 1.0,
                                      color: Colors.black.withOpacity(.12))
                                ],
                                color: bg,
                                borderRadius: radius,
                              ),
                              child: Stack(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(right: 48.0),
                                    child: Text(orderData.get('body')),
                                  ),
                                  Positioned(
                                    bottom: 0.0,
                                    right: 0.0,
                                    child: Row(
                                      children: <Widget>[
                                        SizedBox(width: 3.0),
                                        isMe ?

                                        SizedBox(width: 3.0)
                                        :
                                    Icon(
                                    icon,
                                    size: 12.0,
                                    color: delivered ? Colors.blue : Colors.black38,
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
                    )
                    )
                        : CircularProgressIndicator();
                  }),
            ])
      ),
        EnvioMensaje,

        ]
    ))
    );
  }
}
