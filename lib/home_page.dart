import 'dart:convert';
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'auth.dart';
import 'notificaciones.dart';

class HomePage extends StatefulWidget {
/*  HomePage({this.auth, this.onSignedOut});

  final BaseAuth auth;
  final VoidCallback onSignedOut; */

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<MenuItem> menuItems = <MenuItem>[];
  String _name = "Android", _email = "";
  bool charger = false;

 /* void onSignOut() async {
    try {
      await widget.auth.signOut();
      print("Signed Out");
      widget.onSignedOut();
    } catch (e) {
      print("Error: $e");
    }
  } */


/*
  void validate() async {
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        Navigator.pushNamed(
          context,
          '/message',
        );
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;

      if (notification != null && android != null) {
        showNotification(message.notification);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      Navigator.pushNamed(
        context,
        '/message',
      );
    });

    /*
    FirebaseMessaging().requestNotificationPermissions();

    FirebaseMessaging().configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      showNotification(message['notification']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });*/

    FirebaseMessaging.instance.getToken().then((token) {
      FirebaseFirestore.instance
          .collection('token')
          .doc('token')
          .update({'pushToken': token});
    }).catchError((err) {
      //   Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    FlutterLocalNotificationsPlugin().initialize(initializationSettings);
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      UniversalPlatform.isAndroid
          ? 'com.cosetimx.tienda_clente'
          : 'com.cosetimx.tienda_clente',
      'tienda_cliente',
      "Administracion APP",
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    print('Mensaje ${message['title']}');
    await FlutterLocalNotificationsPlugin().show(
        0, message['title'], message['body'], platformChannelSpecifics,
        payload: json.encode(message));
  }
*/

  @override
  void initState() {
    super.initState();
   /* widget.auth.currentUser().then((user) {
      setState(() {
        if (user != null) {
          _email = user.email.toString();
        } else {
          _email = "Loading...";
        }
      });
    }); */
    getUsers();
    // validate();
    // configLocalNotification();
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
  Widget build(BuildContext context) {


    return

      Scaffold(
        appBar: AppBar(
          title: Text('Pantalla Principal'),
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
        Navigator.of(context).push(
          new MaterialPageRoute(
            builder: (BuildContext context) => menuItem.page,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildMenu(this.item, context);
  }
}
