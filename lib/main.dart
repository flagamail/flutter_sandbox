// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  Get.put(LoginInfo());
  runApp(App());
}

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    print("AuthMiddleware REDIRECT route $route");

    return (route == '/login')
        ? null
        : Get.find<LoginInfo>().loggedIn
            ? null
            : const RouteSettings(name: '/login');
  }
}

class LoginMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    print("LoginMiddleware REDIRECT route $route");
    return Get.find<LoginInfo>().loggedIn ? const RouteSettings(name: '/home') : null;
  }
}

/// The main app.
class App extends StatelessWidget {
  /// Creates an [App].
  App({super.key});

  /// The title of the app.
  static const String title = 'Getx: Redirection';

  // add the login info into the tree as app state that can change over time
  @override
  Widget build(BuildContext context) => GetMaterialApp(
        title: title,
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        getPages: [
          GetPage(
            name: '/login',
            page: () => const LoginScreen(),
            transition: Transition.rightToLeft,
            middlewares: [LoginMiddleware()],
          ),
          GetPage(
              name: '/home',
              page: () => const HomeScreen(),
              transition: Transition.rightToLeft,
              middlewares: [
                AuthMiddleware()
              ],
              children: [
                GetPage(
                  name: '/',
                  page: () => const HomeScreen(),
                ),
                GetPage(
                    name: '/:fid', page: () => FamilyScreen(), participatesInRootNavigator: false),
              ]),
        ],
      );
}

/// The login screen.
class LoginScreen extends StatelessWidget {
  /// Creates a [LoginScreen].
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(App.title)),
        body: Column(children: [
          Row(),
          Container(height: 100, color: Colors.blue),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GridView.builder(
                      itemCount: 30,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          childAspectRatio: 3 / 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20),
                      itemBuilder: (index, context) {
                        return Container(
                            width: 150,
                            height: 150,
                            color: Colors.amber,
                            margin: const EdgeInsets.all(8));
                      }),
                  Container(height: 100, color: Colors.deepOrange),
                ],
              ),
            ),
          ),
        ]),
      );
}

/// The home screen.
class HomeScreen extends StatelessWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final LoginInfo info = context.read<LoginInfo>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(App.title),
        actions: <Widget>[
          IconButton(
            onPressed: Get.find<LoginInfo>().logout,
            tooltip: 'Logout: ${Get.find<LoginInfo>().userName}',
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          for (final MapEntry<String, Family> entry in _families.entries)
            ListTile(
              title: Text(entry.value.name),
              onTap: () => Get.toNamed('/home/${entry.key}'),
            )
        ],
      ),
    );
  }
}

/// The screen that shows a list of persons in a family.
class FamilyScreen extends StatelessWidget {
  /// Creates a [FamilyScreen].
  FamilyScreen({super.key}) {
    fid = (Get.parameters.isNotEmpty && Get.parameters.containsKey('fid'))
        ? Get.parameters['fid'] ?? ''
        : '';
  }

  /// The family to display.
  late String fid;

  /// Whether to sort the name in ascending order.
  final bool asc = false;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> newQueries;
    final List<String> names =
        _families[fid]!.people.values.map<String>((Person p) => p.name).toList();
    names.sort();
    if (asc) {
      newQueries = const <String, String>{'sort': 'desc'};
    } else {
      newQueries = const <String, String>{'sort': 'asc'};
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_families[fid]!.name),
        actions: <Widget>[
          IconButton(
            onPressed: () => Get.toNamed(
              '/home',
              parameters: <String, String>{'fid': fid},
              // queryParameters: newQueries),
            ),
            tooltip: 'sort ascending or descending',
            icon: const Icon(Icons.sort),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          for (final String name in (asc ? names : names.reversed))
            ListTile(
              title: Text(name),
            ),
        ],
      ),
    );
  }
}

/// Family data class.
class Family {
  /// Create a family.
  const Family({required this.name, required this.people});

  /// The last name of the family.
  final String name;

  /// The people in the family.
  final Map<String, Person> people;
}

/// Person data class.
class Person {
  /// Creates a person.
  const Person({required this.name, required this.age});

  /// The first name of the person.
  final String name;

  /// The age of the person.
  final int age;
}

const Map<String, Family> _families = <String, Family>{
  'f1': Family(
    name: 'Doe',
    people: <String, Person>{
      'p1': Person(name: 'Jane', age: 23),
      'p2': Person(name: 'John', age: 6),
    },
  ),
  'f2': Family(
    name: 'Wong',
    people: <String, Person>{
      'p1': Person(name: 'June', age: 51),
      'p2': Person(name: 'Xin', age: 44),
    },
  ),
};

/// The login information.
class LoginInfo extends ChangeNotifier {
  /// The username of login.
  String get userName => box.read('login') ?? '';

  final GetStorage box = GetStorage();

  /// Whether a user has logged in.
  bool get loggedIn => userName.isNotEmpty;

  /// Logs in a user.
  void login(String userName) {
    box.write('login', userName);
    notifyListeners();
  }

  /// Logs out the current user.
  void logout() {
    box.write('login', '');
    notifyListeners();
  }
}
