import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Item {
  double height = 1;
  Color color = const Color.fromARGB(255, 100, 0, 0);
  String str = "";
  GlobalKey gk = GlobalKey();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  double doubleHeight = 1;
  List<Item> listDouble = List.generate(
      3,
      (index) => Item()
        ..height = (index + 1)
        ..color = Color.fromARGB(255, (index + 1) * 100, 0, 0));

  static const data = "Lorem Ipsum is simply dummy text of the printing and typesetting industry."
      " Lorem"
      " Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.";
  List<String> splitList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    splitList = data.split(" ");
    var length2 = splitList.length;
    listDouble = List.generate(
        length2,
        (index) => Item()
          ..height = (index + 1)
          ..color = Color.fromARGB(255, (index + 1) * 100, 0, 0)
          ..str = data.substring(0, data.indexOf(splitList[index])));
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          //  title: Text(widget.title),
          ),
      body: LayoutBuilder(builder: (context, constraints) {
        debugPrint('constraints ${constraints.maxHeight}');
        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 500,
                    color: Colors.blue,
                  ),
                  Container(
                    width: double.infinity,
                    height: 600,
                    color: Colors.green,
                  ),
                  Container(
                    width: double.infinity,
                    height: 700,
                    color: Colors.orange,
                    margin: EdgeInsets.only(bottom: doubleHeight),
                    alignment: Alignment.bottomCenter,
                    child: const Text(
                      'Hi',
                      textAlign: TextAlign.end,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: doubleHeight,
                child: PageView.builder(
                  itemCount: splitList.length,
                  controller: PageController(),
                  itemBuilder: (context, index) {
                    debugPrint('Itembuilder $index $doubleHeight');

                    return Container(
                      color: listDouble[index].color,
                      child: SingleChildScrollView(
                        /// Additional Builder to get context closer to Child i.e., Text
                        /// This enables to find renderObject - Constrained Box of Container
                        child: RepaintBoundary(
                          key: listDouble[index].gk,
                          child: LayoutBuilder(
                              builder: (BuildContext context, BoxConstraints constraints) {
                            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                              final RenderBox renderBox = listDouble[index]
                                  .gk
                                  .currentContext
                                  ?.findRenderObject() as RenderBox;
                              final double doubleHeightRendered = renderBox.size.height * 2;
                              debugPrint("doubleHeightRendered $doubleHeightRendered");


                              if (listDouble[index].height != doubleHeightRendered) {
                                setState(() {
                                  listDouble[index].height = doubleHeightRendered;
                                  doubleHeight = doubleHeightRendered;
                                  debugPrint('height ${listDouble[index].height}');
                                });
                              }
                            });

                            return Text(
                              listDouble[index].str,
                              style: const TextStyle(fontSize: 20),
                            );
                          }),
                        ),
                      ),
                    );
                  },
                  onPageChanged: (index) {
                    if (doubleHeight != listDouble[index].height) {
                      setState(() {
                        debugPrint("onPageChanged $index");
                        doubleHeight = listDouble[index].height;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
