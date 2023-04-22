import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

import 'Building_Model.dart';
import 'Image_Zoom.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textSelectionTheme:
            TextSelectionThemeData(cursorColor: Colors.deepOrangeAccent),
        appBarTheme: AppBarTheme(
          color: Colors.deepOrangeAccent,
        ),
      ),
      home: const MyHomePage(title: ' '),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String search_text = "";
  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Image.asset(
              "images/buddha.png",
              height: 300,
              width: 300,
            ),
          ),
        ),
        body: Center(
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepOrange,
                Colors.lightGreenAccent,
              ],
            )),
            child: Column(children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    focusColor: Colors.deepOrangeAccent,
                    hoverColor: Colors.deepOrangeAccent,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrangeAccent),
                    ),
                    // enabledBorder: OutlineInputBorder(
                    //   borderSide: BorderSide(
                    //       width: 2, color: Colors.black), //<-- SEE HERE
                    // ),
                    hintText: "ရှာဖွေပါ....",
                  ),
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  onChanged: (value) => {
                    setState(() {
                      search_text = value.toString();
                    })
                  },
                ),
              ),
              Expanded(
                  child: Container(
                child: FutureBuilder(
                    future: (search_text == "")
                        ? readJson()
                        : searchJson(search_text.toString()),
                    builder: (context, data) {
                      if (data.hasError) {
                        return Center(child: Text("${data.error}"));
                      } else if (data.hasData) {
                        var items = data.data as List<Building>;
                        return ListView.builder(
                            itemCount: items == null ? 0 : items.length,
                            itemBuilder: (context, index) {
                              return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 5,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 20),
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    child: Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                              child: Expanded(
                                                  child: Column(
                                            children: [
                                              Text(
                                                items[index].name.toString(),
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                items[index]
                                                    .building_number
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                              Text(
                                                items[index].donor.toString(),
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                              Column(children: [
                                                Image.asset(
                                                  "images/photo/Picture${items[index].id_en}.jpg",
                                                  height: 300,
                                                  width: 500,
                                                  fit: BoxFit.cover,
                                                ),
                                                Divider(height: 50),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          width: 3,
                                                          color:
                                                              Colors.black45),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  8))),
                                                  child:
                                                      ImageFullScreenWrapperWidget(
                                                    dark: true,
                                                    child: Image.asset(
                                                      "images/map/${items[index].id_en}.png",
                                                      // height: 500,
                                                      width: 500,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                            ],
                                          )))
                                        ],
                                      ),
                                    ),
                                  ));
                            });
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    }),
              ))
            ]),
          ),
        ));
  }

  Future<List<Building>?> searchJson(String search_texts) async {
    final jsonData = await rootBundle.loadString('Withuta.json');
    final list = json.decode(jsonData) as List<dynamic>;

    final search_list = list.where((element) {
      if (element["name"] == null) element["name"] = "";
      if (element["donor"] == null) element["donor"] = "";
      return element["id_en"].toString() == search_texts ||
          element["id_mm"].toString() == search_texts ||
          ratio(element["number"].replaceAll(' ', '').trim(), search_texts) >
              90 ||
          ratio(element["name"].replaceAll(' ', ''), search_texts) > 50 ||
          ratio(element["donor"].replaceAll(' ', ''), search_texts) > 30;
    });

    return search_list.map((e) => Building.fromJson(e)).toList();
  }

  Future<List<Building>> readJson() async {
    final jsonData = await rootBundle.loadString('Withuta.json');
    final list = json.decode(jsonData) as List<dynamic>;
    return list.map((e) => Building.fromJson(e)).toList();
  }
}
