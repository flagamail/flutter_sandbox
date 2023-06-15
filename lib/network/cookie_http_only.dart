import 'dart:convert' show json, base64, ascii;
import 'dart:html' show window, HttpRequest;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

const SERVER_IP = 'localhost';
const PORT = 3000;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentication Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Builder(builder: (context) {
        var csrfTokenOrEmpty =
            window.localStorage.containsKey("csrf") ? window.localStorage["csrf"] : "";
        if (csrfTokenOrEmpty != null && csrfTokenOrEmpty != "") {
          String str = csrfTokenOrEmpty;
          print('csrfTokenOrEmpty - $csrfTokenOrEmpty');
          var token = str.split(".");
          print('token - $token');

          if (token.length != 3) {
            window.localStorage.remove("csrf");
            return LoginPage();
          } else {
            var payload = json.decode(ascii.decode(base64.decode(base64.normalize(token[1]))));
            print(
                'DateTime.fromMillisecondsSinceEpoch(payload["exp"] * 1000) - ${DateTime.fromMillisecondsSinceEpoch(payload["exp"] * 1000)}');
            if (DateTime.fromMillisecondsSinceEpoch(payload["exp"] * 1000)
                .isAfter(DateTime.now())) {
              return HomePage(str, payload);
            } else {
              window.localStorage.remove("csrf");
              return LoginPage();
            }
          }
        } else {
          window.localStorage.remove("csrf");
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
                      window.localStorage["csrf"] = jwt;
                      Navigator.push(context,
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
              onPressed: () {
                window.localStorage.remove("csrf");
              },
              icon: const Icon(Icons.logout))
        ]),
        body: Center(
          child: FutureBuilder(
              future: HttpRequest.request("http://localhost:3000/data",
                  method: "GET", withCredentials: true),
/*
              future: http.read(Uri(scheme: 'http', host: SERVER_IP, port: PORT, path: '/data'),
                  headers: {"CSRF": jwt}),
*/
              builder: (context, snapshot) {
                return snapshot.hasData
                    ? Column(
                        children: <Widget>[
                          Text("${payload['username']}, here's the data:"),
                          Text(/*snapshot.data ?? */ '',
                              style: Theme.of(context).textTheme.headlineMedium)
                        ],
                      )
                    : snapshot.hasError
                        ? Text("An error occurred ${snapshot.error}")
                        : const CircularProgressIndicator();
              }),
        ),
      );
}
