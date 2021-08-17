import 'package:boleta_notificacion/notificaciones.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'splash_screen.dart';
import 'auth.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MyAppMap();
  }
}
class MyAppMap extends StatefulWidget {

  final BaseAuth auth = Auth();
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyAppMap> {

  final routes = <String, WidgetBuilder>{
    // '/' : (context) =>  LoginPage(),
    '/' : (context) =>  LoginPage(),
    '/home': (context) => HomePage(),
    '/notify': (context) => NotificacionesPage()
  };


  @override
  Widget build(BuildContext context) {
    final BaseAuth auth = Auth();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Administrador",
        initialRoute: '/',
        routes: routes,
      home:  HomePage(),
    );
  }
}





