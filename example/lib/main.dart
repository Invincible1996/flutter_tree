import 'dart:convert';

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
        primarySwatch: Colors.indigo,
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
    {"parentId": 1063, "value": "牡丹江市", "id": 1314},
    {"parentId": 1063, "value": "齐齐哈尔市", "id": 1318},
    {"parentId": 1063, "value": "佳木斯市", "id": 1320},
    {"parentId": 1066, "value": "长春市", "id": 1323},
    {"parentId": 1066, "value": "通化市", "id": 1325},
    {"parentId": 1066, "value": "白山市", "id": 1328},
    {"parentId": 1066, "value": "辽源市", "id": 1330},
    {"parentId": 1066, "value": "松原市", "id": 1332},
    {"parentId": 1009, "value": "南京市", "id": 1130},
    {"parentId": 1009, "value": "无锡市", "id": 1132},
    {"parentId": 1009, "value": "常州市", "id": 1133},
    {"parentId": 1009, "value": "镇江市", "id": 1134},
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: treeListData.isNotEmpty
          ? FlutterTreePro(
              listData: treeListData,
              initialListData: initialTreeData,
              config: Config(
                parentId: 'parentId',
                dataType: DataType.DataList,
                label: 'value',
              ),
              onChecked: (List<Map<String, dynamic>> checkedList) {
                logger.v(checkedList);
              },
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
