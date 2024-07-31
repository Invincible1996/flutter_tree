import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tree_pro/flutter_tree_pro.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Tree Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> treeListData = [];

  //默认数据
  List<Map<String, dynamic>> initialTreeData = [
    {"parentId": 1009, "value": "Suzhou", "id": 1011},
    {"parentId": 1009, "value": "Wuxi", "id": 1012},
    {"parentId": 1001, "value": "Brooklyn", "id": 10005},
  ];

  List<Map<String, dynamic>> _checkedList = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    var response = await rootBundle.loadString('assets/data.json');
    setState(() {
      json.decode(response)['country'].forEach((item) {
        treeListData.add(item);
      });
    });
  }

  bool isRTL = false;
  bool isExpanded = true;
  bool isSingleSelect = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(widget.title),
      ),
      body: treeListData.isNotEmpty
          ? Column(
              children: [
                // switch RTL
                Container(
                  padding: EdgeInsets.all(10),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'RTL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      CupertinoSwitch(
                        value: isRTL,
                        onChanged: (value) {
                          setState(() {
                            // RTL
                            isRTL = value;
                          });
                        },
                        activeColor: Colors.indigo,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FlutterTreePro(
                      initialSelectValue: 1012,
                      isSingleSelect: isSingleSelect,
                      isRTL: isRTL,
                      isExpanded: isExpanded,
                      listData: treeListData,
                      initialListData: initialTreeData,
                      config: Config(
                        parentId: 'parentId',
                        dataType: DataType.DataList,
                        label: 'value',
                      ),
                      onChecked: (List<Map<String, dynamic>> checkedList) {
                        logger.i(checkedList);
                        setState(() {
                          _checkedList = checkedList;
                        });
                      },
                    ),
                  ),
                ),
                //_checkedList count
                Container(
                  padding: EdgeInsets.all(10),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Checked Count: ${_checkedList.length}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
