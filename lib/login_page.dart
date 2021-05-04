import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:boleta_notificacion/auth.dart';
//import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.auth, this.onSignedIn});
  final BaseAuth auth;
  final VoidCallback onSignedIn;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  AnimationController animationController;
  Animation logoanimation;
  String _email, _password, _emailpassword;
  FocusNode focusNode;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final formKey1 = GlobalKey<FormState>();
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    logoanimation =
        CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    logoanimation.addListener(() => this.setState(() {}));
    animationController.forward();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animationController.dispose();
    super.dispose();
  }

  void _submit() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      print("Email: $_email Password: $_password");
      _login();
    }
  }

  void _login() async {
    try {
      String uid = await widget.auth.signIn(_email, _password);
      print("Signed in : $uid");
      await widget.auth.isEmailVerified().then((isVerified) async {
        if (isVerified) {
          print("Verified");
          widget.onSignedIn();
        } else {
          final snackBar = SnackBar(
            content: Text("Email Not Verified!"),
            duration: Duration(seconds: 1),
            action: SnackBarAction(
                label: "Send Again",
                onPressed: () async {
                  await widget.auth.sendEmailVerification();
                }),
          );
          scaffoldKey.currentState.showSnackBar(snackBar);
          await Future.delayed(Duration(milliseconds: 1001));
          await widget.auth.signOut();
        }
      });
    } catch (e) {
      final snackBar = SnackBar(content: Text("Error in Signing in!"));
      scaffoldKey.currentState.showSnackBar(snackBar);
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          /*     Image.asset(
            "images/login.jpg",
            fit: BoxFit.cover,
            color: Colors.black87,
            colorBlendMode: BlendMode.darken,
          ), */
          Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: ListView(
              children: <Widget>[
                Container(
                  height: 25.0,
                ),
                Image.asset(
                  "assets/logo_notificaciones.png",
                  height: logoanimation.value * 150,
                  width: logoanimation.value * 150,
                ),
                Padding(padding: EdgeInsets.only(top: 60.0)),
                Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Ingrese Correo Electrónico",
                          labelText: "Correo Electrónico",
                          labelStyle: TextStyle(color: Colors.blueGrey),
                          hintStyle: TextStyle(
                              color: Colors.blueAccent.withOpacity(.45)),
                          icon: Icon(
                            Icons.mail,
                            color: Colors.blueGrey,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                        ),
                        style: TextStyle(color: Colors.blue),
                        validator: (val) => !val.contains('@')
                            ? "Correo Electrónico Inválido"
                            : null,
                        onSaved: (val) => _email = val,
                        onFieldSubmitted: (val) =>
                            FocusScope.of(context).requestFocus(focusNode),
                      ),
                      new Padding(padding: EdgeInsets.only(top: 30.0)),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: "Ingrese Contraseña",
                          labelText: "Contraseña",
                          labelStyle: TextStyle(color: Colors.blueGrey),
                          hintStyle: TextStyle(
                              color: Colors.blueAccent.withOpacity(.45)),
                          icon: Icon(
                            Icons.lock,
                            color: Colors.blueGrey,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                        ),
                        obscureText: true,
                        style: TextStyle(color: Colors.blue),
                        validator: (val) =>
                            val.length < 6 ? "Contraseña muy Corta" : null,
                        onSaved: (val) => _password = val,
                        focusNode: focusNode,
                      ),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 60.0)),
                Container(
                  height: 45.0,
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: Colors.blueGrey.withOpacity(.6),
                      borderRadius: BorderRadius.circular(30.0)),
                  child: FlatButton(
                    onPressed: _submit,
                    child: Text(
                      "Iniciar Sesión",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontFamily: "Karla",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    splashColor: Colors.blue[800],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
/*
class PageNavigate extends CupertinoPageRoute {
  final BaseAuth auth;
  PageNavigate({this.auth})
      : super(
            builder: (BuildContext context) => RegistrationPage(
                  auth: auth,
                ));
}
*/