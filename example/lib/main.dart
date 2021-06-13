import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tree/flutter_tree.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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

  List<Map<String, dynamic>> initialTreeData = [
    {
      "subject": 3,
      "exams": null,
      "parentId": 6,
      "knowledgeNo": "2",
      "knowledgeName": "Atomic Structure",
      "examPaperData": null,
      "id": 1009,
      "level": 2,
    },
    {
      "subject": 3,
      "exams": null,
      "parentId": 6,
      "knowledgeNo": "9",
      "knowledgeName": "Redox Chemistry",
      "examPaperData": null,
      "id": 1016,
      "level": 2,
    },
    {
      "subject": 3,
      "exams": null,
      "parentId": 6,
      "knowledgeNo": "11",
      "knowledgeName": "Nitrogen and sulfur",
      "examPaperData": null,
      "id": 1024,
      "level": 2,
    },
    {
      "subject": 3,
      "exams": null,
      "parentId": 1140,
      "knowledgeNo": "3.2.1",
      "knowledgeName": "formation of ions and the dot-and-cross diagram of ionic compound",
      "examPaperData": null,
      "id": 1685,
      "level": 4
    },
    {
      "subject": 3,
      "exams": null,
      "parentId": 1140,
      "knowledgeNo": "3.2.2",
      "knowledgeName": "evidence for the existence of ions",
      "examPaperData": null,
      "id": 1686,
      "level": 4,
    },
    {
      "subject": 3,
      "exams": null,
      "parentId": 1140,
      "knowledgeNo": "3.2.4",
      "knowledgeName": "definition of ionic bonding",
      "examPaperData": null,
      "id": 1688,
      "level": 4,
    },
    {
      "subject": 3,
      "exams": null,
      "parentId": 1140,
      "knowledgeNo": "3.2.8",
      "knowledgeName": "polarisation of ionic compounds",
      "examPaperData": null,
      "id": 1692,
      "level": 4,
    },
    {
      "subject": 3,
      "exams": null,
      "parentId": 1142,
      "knowledgeNo": "3.3.3",
      "knowledgeName": "dative covalent bond",
      "examPaperData": null,
      "id": 1695,
      "level": 4,
    },
    {
      "subject": 3,
      "exams": null,
      "parentId": 1142,
      "knowledgeNo": "3.3.5",
      "knowledgeName": "electronegativity and polarity of bond",
      "examPaperData": null,
      "id": 1697,
      "level": 4,
    },
    {
      "subject": 3,
      "exams": null,
      "parentId": 1142,
      "knowledgeNo": "3.3.6",
      "knowledgeName": "(continuum of bonding type from perfect ionic to non-polar covalent bond)",
      "examPaperData": null,
      "id": 1698,
      "level": 4
    },
    {
      "subject": 3,
      "exams": null,
      "parentId": 1142,
      "knowledgeNo": "3.3.7",
      "knowledgeName": "electron-pair repulsion theory and shape of molecules",
      "examPaperData": null,
      "id": 1699,
      "level": 4,
    }
  ];

  Map<String, dynamic> treeData = {
    "id": 0,
    "value": 0,
    "label": "根节点",
    "pid": null,
    "children": [
      {
        "id": 1,
        "value": 1,
        "label": "父节点01",
        "pid": 0,
        "children": [
          {
            "id": 11,
            "value": 11,
            "label": "父节点11",
            "pid": 1,
            "children": [
              {"id": 111, "value": 111, "label": "子节点111", "pid": 11},
              {"id": 112, "value": 112, "label": "子节点112", "pid": 11},
              {"id": 113, "value": 113, "label": "子节点113", "pid": 11}
            ]
          },
          {
            "id": 12,
            "value": 12,
            "label": "父节点12",
            "pid": 1,
            "children": [
              {"id": 121, "value": 121, "label": "子节点121", "pid": 12},
              {"id": 122, "value": 122, "label": "子节点122", "pid": 12},
              {"id": 123, "value": 123, "label": "子节点123", "pid": 12}
            ]
          },
          {"id": 13, "value": 13, "label": "父节点13", "pid": 1}
        ]
      },
      {
        "id": 2,
        "value": 2,
        "label": "父节点02",
        "pid": 0,
        "children": [
          {"id": 21, "value": 21, "label": "父节点21", "pid": 2},
          {"id": 22, "value": 22, "label": "父节点22", "pid": 2}
        ]
      },
      {
        "id": 3,
        "value": 3,
        "label": "父节点03",
        "pid": 0,
        "children": [
          {"id": 31, "value": 31, "label": "父节点31", "pid": 3},
          {"id": 32, "value": 32, "label": "父节点32", "pid": 3}
        ]
      }
    ],
    "open": true
  };

  List<Map<String, dynamic>> list = [
    {
      "subject": 3,
      "exams": [1],
      "parentId": 1130,
      "knowledgeNo": "2.2.3",
      "knowledgeName": "relative masses of atoms and molecules",
      "examPaperData": null,
      "id": 1665,
      "level": 4,
      "open": false,
      "checked": 2
    },
    {
      "subject": 3,
      "exams": [1],
      "parentId": 1130,
      "knowledgeNo": "2.2.2",
      "knowledgeName": "radioactive isotopes",
      "examPaperData": null,
      "id": 1664,
      "level": 4,
      "open": false,
      "checked": 2
    },
    {
      "subject": 3,
      "exams": [1],
      "parentId": 1009,
      "knowledgeNo": "2.1",
      "knowledgeName": "sub-atomic particles",
      "examPaperData": null,
      "id": 1125,
      "level": 3,
      "children": [
        {
          "subject": 3,
          "exams": [1],
          "parentId": 1125,
          "knowledgeNo": "2.1.1",
          "knowledgeName": "particles in the atom",
          "examPaperData": null,
          "id": 1662,
          "level": 4,
          "open": false,
          "checked": 2
        }
      ],
      "open": true,
      "checked": 2
    },
    {
      "subject": 3,
      "exams": [1],
      "parentId": 1125,
      "knowledgeNo": "2.1.1",
      "knowledgeName": "particles in the atom",
      "examPaperData": null,
      "id": 1662,
      "level": 4,
      "open": false,
      "checked": 2
    }
  ];

  @override
  void initState() {
    super.initState();
    loadData();
    print(list.length);
    var newList = list.where((element) => (element['children'] ?? []).isNotEmpty).toList();
    var newListNoChildren = list.where((element) => (element['children'] ?? []).isEmpty).toList();
    newList.forEach((element) {
      if ((element['children'] ?? []).isNotEmpty) {
        element.remove('children');
      }
    });
    print(newListNoChildren.length);
    print(newList.length);
    print(newList);
  }

  loadData() async {
    var response = await rootBundle.loadString('assets/data.json');
    setState(() {
      json.decode(response)['knowledges'].forEach((item) {
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
          ? FlutterTree(
              listData: treeListData,
              initialListData: [],
              config: Config(parentId: 'parentId', dataType: DataType.DataList, label: 'knowledgeName'),
            )
          : CircularProgressIndicator(),
    );
  }
}
