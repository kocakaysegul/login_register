import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _isLogin = false;
  final cont_login_user = TextEditingController();
  final cont_login_pass = TextEditingController();
  var _message = "";
  var _token = null;
  var _expireDate = null;
  var _userId = null;

  Future<void> signUpFunction() async {
    var url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyCiH0caU4L8FWb_tllR_WCWgBtdS9BDMFQ');
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': cont_login_user.text,
            'password': cont_login_pass.text,
            'returnSecureToken': true
          }));
      final returnData = json.decode(response.body);
      if (returnData['error'] != null) {
        setState(() {
          _message = returnData['error']['message'];
        });
      }
      if (returnData['kind'] != null) {
        setState(() {
          _message = returnData['kind'];
        });
      }
      print(returnData);
    } catch (e)
    {
      print(e.toString());
    }
  }

  Future<void> signInFunction() async {
    var url = Uri.parse(

        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCiH0caU4L8FWb_tllR_WCWgBtdS9BDMFQ');
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': cont_login_user.text,
            'password': cont_login_pass.text,
            'returnSecureToken': true
          }));
      final returnData = json.decode(response.body);
      if (returnData['error'] != null) {
        setState(() {
          _message = returnData['error']['message'];
        });
      }
      if (returnData['kind'] != null) {
        setState(() {
          _message = returnData['kind'];
          _isLogin = true;
          _userId = returnData['localId'];
          _token = returnData['idToken'];
          _expireDate = DateTime.now().add(Duration(seconds:
          int.parse(returnData['expiresIn'])));
        });
      }
      print(_expireDate.toString());
    } catch (e) {
      print(e.toString());
    }
  }

  void signOutFunction() {
    setState(() {
      _isLogin = false;
      _token = null;
      _expireDate = null;
    });
  }

  Future<void> getDataFunction() async {
    var url = Uri.parse(
        'https://flutter-demo-b5b5c-default-rtdb.europewest1.firebasedatabase.app/test1.json?auth=$_token');
    try {
      var response = await http.get(url);
      //print(response.body);
      var data = json.decode(response.body);
      print(data);
      data.forEach((k, v) {
        print('${k}');
        var data2 = v;
        data2.forEach((k2, v2) {
          print('${k2}:${v2}');
        });
      });
    } catch (error) {
      throw (error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _isLogin
                ? Column(
              children: [
                Text(
                  'You have logged in.',
                ),
                TextButton(onPressed: () {
                  getDataFunction();
                }, child: const Text('Get Data')),
                TextButton(onPressed: () {
                  signOutFunction();
                }, child: const Text('Logout'))
              ],
            )
                : Column(
              children: [
                Text(
                  'No one logged in. $_message',
                ),
                TextField(
                  controller: cont_login_user,
                  decoration: InputDecoration(border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
                TextField(
                  controller: cont_login_pass,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    signUpFunction();
                  },
                  child: const Text('Register'),
                ),
                TextButton(
                  onPressed: () {
                    signInFunction();
                  },
                  child: const Text('Login'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
