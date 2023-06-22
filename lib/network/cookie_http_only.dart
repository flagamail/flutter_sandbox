import 'dart:convert' show json, base64, ascii;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

const SERVER_IP = 'localhost';
const PORT = 3000;

void main() async {
  GetStorage.init();
  print('main');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final storage = GetStorage();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentication Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Builder(builder: (context) {
        var csrfTokenOrEmpty = storage.read("csrf");
        if (csrfTokenOrEmpty != null && csrfTokenOrEmpty != "") {
          String str = csrfTokenOrEmpty;
          print('csrfTokenOrEmpty - $csrfTokenOrEmpty');
          var token = str.split(".");
          print('token - $token');

          if (token.length != 3) {
            storage.remove("csrf");
            return LoginPage();
          } else {
            var payload = json.decode(ascii.decode(base64.decode(base64.normalize(token[1]))));
            print(
                'DateTime.fromMillisecondsSinceEpoch(payload["exp"] * 1000) - ${DateTime.fromMillisecondsSinceEpoch(payload["exp"] * 1000)}');
            if (DateTime.fromMillisecondsSinceEpoch(payload["exp"] * 1000)
                .isAfter(DateTime.now())) {
              return HomePage(str, payload);
            } else {
              //   window.localStorage.remove("csrf");
              return LoginPage();
            }
          }
        } else {
          //   window.localStorage.remove("csrf");
          return LoginPage();
        }
      }),
    );
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void displayDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) => AlertDialog(title: Text(title), content: Text(text)),
      );

  Future<String?> attemptLogIn(String username, String password) async {
    var body2 = {"username": username, "password": password};

    try {
      Response res = await GetConnect(withCredentials: true)
          .post("http://localhost:3000/login", body2, contentType: "application/json");
      print('res.body ${res.body}');
      return res.body;
    } catch (e) {
      print('error GetConnect $e');
      return "Failed login";
    }
  }

  Future<int> attemptSignUp(String username, String password) async {
    Response res = await GetConnect(withCredentials: true).post(
        "http://localhost:3000/signup", {"username": username, "password": password},
        contentType: "application/json");
    print('res.body ${res.body}');
    return res.statusCode ?? 404;

    /* var res = await http.post(Uri(scheme: 'http', host: SERVER_IP, port: PORT, path: '/signup'),
        body: {"username": username, "password": password});
    return res.statusCode;*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Log In"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              OutlinedButton(
                  onPressed: () async {
                    var username = _usernameController.text;
                    var password = _passwordController.text;
                    var jwt = await attemptLogIn(username, password);
                    if (jwt != null && context.mounted) {
                      GetStorage().write("csrf", jwt);
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => HomePage.fromBase64(jwt)));
                    } else {
                      displayDialog(context, "An Error Occurred",
                          "No account was found matching that username and password");
                    }
                  },
                  child: const Text("Log In")),
              OutlinedButton(
                  onPressed: () async {
                    var username = _usernameController.text;
                    var password = _passwordController.text;
                    print('username $username password $password');
                    if (context.mounted) {
                      if (username.length < 4) {
                        displayDialog(context, "Invalid Username",
                            "The username should be at least 4 characters long");
                      } else if (password.length < 4) {
                        displayDialog(context, "Invalid Password",
                            "The password should be at least 4 characters long");
                      } else {
                        var res = await attemptSignUp(username, password);
                        if (context.mounted) {
                          if (res == 201) {
                            displayDialog(context, "Success", "The user was created. Log in now.");
                          } else if (res == 409) {
                            displayDialog(
                                context,
                                "That username is already registered",
                                "Please try to sign up using another username or log in if you "
                                    "already have an account.");
                          } else {
                            displayDialog(context, "Error", "An unknown error occurred.");
                          }
                        }
                      }
                    }
                  },
                  child: const Text("Sign Up"))
            ],
          ),
        ));
  }
}

class HomePage extends StatelessWidget {
  const HomePage(this.jwt, this.payload, {super.key});

  factory HomePage.fromBase64(String jwt) =>
      HomePage(jwt, json.decode(ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1])))));

  final String jwt;
  final Map<String, dynamic> payload;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text("Secret Data Screen"), actions: [
          IconButton(
              onPressed: () async {
                GetStorage().remove("csrf");
                Response res = await GetConnect(withCredentials: true).get(
                    "http://localhost:3000/logout",
                    contentType: "application/json",
                    headers: {"CSRF": jwt});
                if (res.statusCode == 200) {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => LoginPage()));
                }
              },
              icon: const Icon(Icons.logout))
        ]),
        body: Center(
          child: FutureBuilder<Response<dynamic>>(
              future: GetConnect(withCredentials: true).get("http://localhost:3000/data",
                  contentType: "application/json", headers: {"CSRF": jwt}),
              builder: (BuildContext context, snapshot) {
                return snapshot.hasData
                    ? Column(
                        children: <Widget>[
                          Text("${payload['username']}, here's the data:"),
                          Text(
                            snapshot.data?.body ?? '',
                          )
                        ],
                      )
                    : snapshot.hasError
                        ? Text("An error occurred ${snapshot.error}")
                        : const CircularProgressIndicator();
              }),
        ),
      );
}
