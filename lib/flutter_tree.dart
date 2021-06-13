library packages;

import 'package:flutter/material.dart';
import 'package:flutter_tree/utils/data_util.dart';
import 'package:flutter_tree/utils/util.dart';
import 'package:logger/logger.dart';

enum DataType {
  DataList,
  DataMap,
}

class Config {
  ///数据类型

  final DataType dataType;

  ///父级id key
  final String parentId;

  ///value key
  final String value;

  ///
  final String label;

  ///
  final String id;

  ///
  final String children;

  const Config({
    this.dataType = DataType.DataMap,
    this.parentId = 'parentId',
    this.value = 'value',
    this.label = 'label',
    this.id = 'id',
    this.children = 'children',
  });
}

var logger = Logger();

class FlutterTree extends StatefulWidget {
  ///
  final Map<String, dynamic> treeData;

  ///
  final List<Map<String, dynamic>> listData;

  ///
  final Map<String, dynamic> initialTreeData;

  ///
  final List<Map<String, dynamic>> initialListData;

  ///
  final Config config;

  FlutterTree({
    Key? key,
    this.treeData = const <String, dynamic>{},
    this.initialTreeData = const <String, dynamic>{},
    this.config = const Config(),
    this.listData = const <Map<String, dynamic>>[],
    this.initialListData = const <Map<String, dynamic>>[],
  }) : super(key: key);

  @override
  _FlutterTreeState createState() => _FlutterTreeState();
}

class _FlutterTreeState extends State<FlutterTree> {
  ///
  Map<String, dynamic> sourceTreeMap = {};

  ///
  bool checkedBox = false;

  ///
  int selectValue = 0;

  ///
  Map<int, String> checkedMap = {
    0: '',
    1: 'partChecked',
    2: 'checked',
  };

  /// 展开树形结构
  Map treeMap = {};

  Map<String, dynamic> treeData = {};

  ///
  List treeList = [];

  List checkedTreeList = [];

  // Map<String, dynamic> testMap = {
  //   "subject": 3,
  //   "exams": [1],
  //   "parentId": 6,
  //   "knowledgeNo": "7",
  //   "knowledgeName": "Equilibria",
  //   "examPaperData": null,
  //   "id": 1014,
  //   "level": 2,
  //   "children": [
  //     {
  //       "subject": 3,
  //       "exams": [1],
  //       "parentId": 1014,
  //       "knowledgeNo": "7.1",
  //       "knowledgeName": "Le Chatelier Principle",
  //       "examPaperData": null,
  //       "id": 1166,
  //       "level": 3,
  //       "children": [
  //         {
  //           "subject": 3,
  //           "exams": [1],
  //           "parentId": 1166,
  //           "knowledgeNo": "7.1.1",
  //           "knowledgeName": "concept of dynamics equilibrium",
  //           "examPaperData": null,
  //           "id": 1722,
  //           "level": 4,
  //           "open": false,
  //           "checked": 0
  //         },
  //         {
  //           "subject": 3,
  //           "exams": [1],
  //           "parentId": 1166,
  //           "knowledgeNo": "7.1.2",
  //           "knowledgeName": "explain the qualitative effects of changes of temperature, pressure and concentration on the position of equilibrium",
  //           "examPaperData": null,
  //           "id": 1723,
  //           "level": 4,
  //           "open": false,
  //           "checked": 0
  //         },
  //         {
  //           "subject": 3,
  //           "exams": [1],
  //           "parentId": 1166,
  //           "knowledgeNo": "7.1.3",
  //           "knowledgeName": "explain the necessity to reach a compromise between the yield and the rate for industrial processes",
  //           "examPaperData": null,
  //           "id": 1724,
  //           "level": 4,
  //           "open": false,
  //           "checked": 0
  //         }
  //       ],
  //       "open": false,
  //       "checked": 0
  //     },
  //     {
  //       "subject": 3,
  //       "exams": [1],
  //       "parentId": 1014,
  //       "knowledgeNo": "7.2",
  //       "knowledgeName": "equilibrium constant",
  //       "examPaperData": null,
  //       "id": 1169,
  //       "level": 3,
  //       "children": [
  //         {
  //           "subject": 3,
  //           "exams": [1],
  //           "parentId": 1169,
  //           "knowledgeNo": "7.2.1",
  //           "knowledgeName": "expression of Kc for homogeneous system",
  //           "examPaperData": null,
  //           "id": 1725,
  //           "level": 4,
  //           "open": false,
  //           "checked": 0
  //         },
  //         {
  //           "subject": 3,
  //           "exams": [1],
  //           "parentId": 1169,
  //           "knowledgeNo": "7.2.2",
  //           "knowledgeName": "activity series ranks metals according to the ease with which ther undergo oxidation",
  //           "examPaperData": null,
  //           "id": 1726,
  //           "level": 4,
  //           "open": false,
  //           "checked": 0
  //         },
  //         {
  //           "subject": 3,
  //           "exams": [1],
  //           "parentId": 1169,
  //           "knowledgeNo": "7.2.3",
  //           "knowledgeName": "expression of Kp for homogeneous and heterogeneous systems",
  //           "examPaperData": null,
  //           "id": 1727,
  //           "level": 4,
  //           "open": false,
  //           "checked": 0
  //         },
  //         {
  //           "subject": 3,
  //           "exams": [1],
  //           "parentId": 1169,
  //           "knowledgeNo": "7.2.4",
  //           "knowledgeName": "calculating the value of Kc",
  //           "examPaperData": null,
  //           "id": 1728,
  //           "level": 4,
  //           "open": false,
  //           "checked": 0
  //         },
  //         {
  //           "subject": 3,
  //           "exams": [1],
  //           "parentId": 1169,
  //           "knowledgeNo": "7.2.5",
  //           "knowledgeName": "calculating the value of Kp",
  //           "examPaperData": null,
  //           "id": 1729,
  //           "level": 4,
  //           "open": false,
  //           "checked": 0
  //         },
  //         {
  //           "subject": 3,
  //           "exams": [1],
  //           "parentId": 1169,
  //           "knowledgeNo": "7.2.6",
  //           "knowledgeName": "effect of change in temperation on the Kc value",
  //           "examPaperData": null,
  //           "id": 1730,
  //           "level": 4,
  //           "open": false,
  //           "checked": 0
  //         }
  //       ],
  //       "open": false,
  //       "checked": 0
  //     },
  //     {
  //       "subject": 3,
  //       "exams": [1],
  //       "parentId": 1014,
  //       "knowledgeNo": "7.3",
  //       "knowledgeName": "acid and base",
  //       "examPaperData": null,
  //       "id": 1171,
  //       "level": 3,
  //       "children": [
  //         {
  //           "subject": 3,
  //           "exams": [1],
  //           "parentId": 1171,
  //           "knowledgeNo": "7.3.1",
  //           "knowledgeName": "Bronsted-Lowry theory of acids and bases",
  //           "examPaperData": null,
  //           "id": 1731,
  //           "level": 4,
  //           "open": false,
  //           "checked": 0
  //         },
  //         {
  //           "subject": 3,
  //           "exams": [1],
  //           "parentId": 1171,
  //           "knowledgeNo": "7.3.2",
  //           "knowledgeName": "conjugate acid and base pair",
  //           "examPaperData": null,
  //           "id": 1732,
  //           "level": 4,
  //           "open": false,
  //           "checked": 0
  //         },
  //         {
  //           "subject": 3,
  //           "exams": [1],
  //           "parentId": 1171,
  //           "knowledgeNo": "7.3.3",
  //           "knowledgeName": "strong and weak acid/base",
  //           "examPaperData": null,
  //           "id": 1733,
  //           "level": 4,
  //           "open": false,
  //           "checked": 0
  //         }
  //       ],
  //       "open": false,
  //       "checked": 0
  //     }
  //   ],
  //   "open": false,
  //   "checked": 0
  // };
  // Map<String, dynamic> testMap2 = {
  //   "subject": 3,
  //   "exams": [1],
  //   "parentId": 6,
  //   "knowledgeNo": "8",
  //   "knowledgeName": "Periodicity",
  //   "examPaperData": null,
  //   "id": 1015,
  //   "level": 2,
  //   "children": [
  //     {
  //       "subject": 3,
  //       "exams": [1],
  //       "parentId": 1015,
  //       "knowledgeNo": "8.1",
  //       "knowledgeName": "physical Trends",
  //       "examPaperData": null,
  //       "id": 1172,
  //       "level": 3,
  //       "children": [
  //         {
  //           "subject": 3,
  //           "exams": [1],
  //           "parentId": 1172,
  //           "knowledgeNo": "8.1.1",
  //           "knowledgeName": "periodicity",
  //           "examPaperData": null,
  //           "id": 1734,
  //           "level": 4,
  //           "open": false,
  //           "checked": 0
  //         },
  //         {
  //           "subject": 3,
  //           "exams": [1],
  //           "parentId": 1172,
  //           "knowledgeNo": "8.1.2",
  //           "knowledgeName": "trends of electronegativity, IE, conductivity, radius, mp across the period 2 and 3",
  //           "examPaperData": null,
  //           "id": 1735,
  //           "level": 4,
  //           "open": false,
  //           "checked": 0
  //         }
  //       ],
  //       "open": false,
  //       "checked": 0
  //     },
  //     {
  //       "subject": 3,
  //       "exams": [1],
  //       "parentId": 1015,
  //       "knowledgeNo": "8.2",
  //       "knowledgeName": "reactions of period 3 elements",
  //       "examPaperData": null,
  //       "id": 1173,
  //       "level": 3,
  //       "children": [
  //         {
  //           "subject": 3,
  //           "exams": [1],
  //           "parentId": 1173,
  //           "knowledgeNo": "8.2.1",
  //           "knowledgeName": "reaction of the elements with O2 and Cl2",
  //           "examPaperData": null,
  //           "id": 1736,
  //           "level": 4,
  //           "open": false,
  //           "checked": 0
  //         },
  //         {
  //           "subject": 3,
  //           "exams": [1],
  //           "parentId": 1173,
  //           "knowledgeNo": "8.2.2",
  //           "knowledgeName": "variation in oxidation number of the oxides and chlorides",
  //           "examPaperData": null,
  //           "id": 1737,
  //           "level": 4,
  //           "open": false,
  //           "checked": 0
  //         },
  //         {
  //           "subject": 3,
  //           "exams": [1],
  //           "parentId": 1173,
  //           "knowledgeNo": "8.2.3",
  //           "knowledgeName": "reactions of the oxides and hydroxides",
  //           "examPaperData": null,
  //           "id": 1738,
  //           "level": 4,
  //           "open": false,
  //           "checked": 0
  //         },
  //         {
  //           "subject": 3,
  //           "exams": [1],
  //           "parentId": 1173,
  //           "knowledgeNo": "8.2.4",
  //           "knowledgeName": "oxides change from basic through amphoteric to acidic",
  //           "examPaperData": null,
  //           "id": 1739,
  //           "level": 4,
  //           "open": false,
  //           "checked": 0
  //         },
  //         {
  //           "subject": 3,
  //           "exams": [1],
  //           "parentId": 1173,
  //           "knowledgeNo": "8.2.5",
  //           "knowledgeName": "explain and describe the rxn of the chlorides and water",
  //           "examPaperData": null,
  //           "id": 1740,
  //           "level": 4,
  //           "open": false,
  //           "checked": 0
  //         },
  //         {
  //           "subject": 3,
  //           "exams": [1],
  //           "parentId": 1173,
  //           "knowledgeNo": "8.2.6",
  //           "knowledgeName": "the type of chemical bonding present in chlorides and oxides",
  //           "examPaperData": null,
  //           "id": 1741,
  //           "level": 4,
  //           "open": false,
  //           "checked": 0
  //         }
  //       ],
  //       "open": false,
  //       "checked": 0
  //     }
  //   ],
  //   "open": false,
  //   "checked": 0
  // };

  // List initialTreeData = [
  //   {
  //     "subject": 3,
  //     "exams": null,
  //     "parentId": 6,
  //     "knowledgeNo": "2",
  //     "knowledgeName": "Atomic Structure",
  //     "examPaperData": null,
  //     "id": 1009,
  //     "level": 2,
  //   },
  //   {
  //     "subject": 3,
  //     "exams": null,
  //     "parentId": 6,
  //     "knowledgeNo": "9",
  //     "knowledgeName": "Redox Chemistry",
  //     "examPaperData": null,
  //     "id": 1016,
  //     "level": 2,
  //   },
  //   {
  //     "subject": 3,
  //     "exams": null,
  //     "parentId": 6,
  //     "knowledgeNo": "11",
  //     "knowledgeName": "Nitrogen and sulfur",
  //     "examPaperData": null,
  //     "id": 1024,
  //     "level": 2,
  //   },
  //   {
  //     "subject": 3,
  //     "exams": null,
  //     "parentId": 1140,
  //     "knowledgeNo": "3.2.1",
  //     "knowledgeName": "formation of ions and the dot-and-cross diagram of ionic compound",
  //     "examPaperData": null,
  //     "id": 1685,
  //     "level": 4
  //   },
  //   {
  //     "subject": 3,
  //     "exams": null,
  //     "parentId": 1140,
  //     "knowledgeNo": "3.2.2",
  //     "knowledgeName": "evidence for the existence of ions",
  //     "examPaperData": null,
  //     "id": 1686,
  //     "level": 4,
  //   },
  //   {
  //     "subject": 3,
  //     "exams": null,
  //     "parentId": 1140,
  //     "knowledgeNo": "3.2.4",
  //     "knowledgeName": "definition of ionic bonding",
  //     "examPaperData": null,
  //     "id": 1688,
  //     "level": 4,
  //   },
  //   {
  //     "subject": 3,
  //     "exams": null,
  //     "parentId": 1140,
  //     "knowledgeNo": "3.2.8",
  //     "knowledgeName": "polarisation of ionic compounds",
  //     "examPaperData": null,
  //     "id": 1692,
  //     "level": 4,
  //   },
  //   {
  //     "subject": 3,
  //     "exams": null,
  //     "parentId": 1142,
  //     "knowledgeNo": "3.3.3",
  //     "knowledgeName": "dative covalent bond",
  //     "examPaperData": null,
  //     "id": 1695,
  //     "level": 4,
  //   },
  //   {
  //     "subject": 3,
  //     "exams": null,
  //     "parentId": 1142,
  //     "knowledgeNo": "3.3.5",
  //     "knowledgeName": "electronegativity and polarity of bond",
  //     "examPaperData": null,
  //     "id": 1697,
  //     "level": 4,
  //   },
  //   {
  //     "subject": 3,
  //     "exams": null,
  //     "parentId": 1142,
  //     "knowledgeNo": "3.3.6",
  //     "knowledgeName": "(continuum of bonding type from perfect ionic to non-polar covalent bond)",
  //     "examPaperData": null,
  //     "id": 1698,
  //     "level": 4
  //   },
  //   {
  //     "subject": 3,
  //     "exams": null,
  //     "parentId": 1142,
  //     "knowledgeNo": "3.3.7",
  //     "knowledgeName": "electron-pair repulsion theory and shape of molecules",
  //     "examPaperData": null,
  //     "id": 1699,
  //     "level": 4,
  //   }
  // ];

  @override
  initState() {
    super.initState();

    // set default select
    if (widget.config.dataType == DataType.DataList) {
      treeList = widget.listData;
      checkedTreeList = widget.initialListData;
      var listToMap = DataUtil.transformListToMap(widget.listData, widget.config);
      sourceTreeMap = listToMap;

      factoryTreeData(sourceTreeMap);

      // Map<String, dynamic> newMap = {};
      // for (var item in widget.initialTreeData) {
      //   newMap.putIfAbsent(item['parentId'].toString(), () => item);
      // }
      // logger.v(newMap);

      // var newList = newMap.values.toList();
      // for (var item1 in newList) {
      //   item1['checked'] = 0;
      //   item1['children'] = [];
      //   for (var item2 in widget.initialTreeData) {
      //     if (item1['id'] == item2['id']) {
      //       item1['children'].add(item2);
      //     }
      //   }
      // }
      //
      // // logger.v(newList[0]);
      // print(newList);
      //
      // newList.forEach((element) {
      //   print(element['id']);
      //   print(element['children']);
      // });
      // logger.v(testMap);
      // logger.v(initialTreeData);

      widget.initialListData.forEach((element) {
        element['checked'] = 0;
      });

      for (var item in widget.initialListData) {
        for (var element in treeMap.values.toList()) {
          if (item['id'] == element['id']) {
            // element['checked'] = 2;
            // element['children'].forEach((element2) {
            //   element2['checked'] = 2;
            // });
            setCheckStatus(element);
            break;
          }
        }
        selectCheckedBox(item);
      }
      // for (var element in treeMap.values.toList()) {
      //   if (testMap2['id'] == element['id']) {
      //     // element['checked'] = 2;
      //     // element['children'].forEach((element2) {
      //     //   element2['checked'] = 2;
      //     // });
      //     setCheckStatus(element);
      //     break;
      //   }
      // }
      // selectCheckedBox(testMap2);
    } else {
      sourceTreeMap = widget.treeData;
    }
  }

  setCheckStatus(item) {
    item['checked'] = 2;
    if (item['children'] != null) {
      item['children'].forEach((element) {
        setCheckStatus(element);
      });
    }
  }

  /// @params
  /// @desc 将树形结构数据平铺开
  factoryTreeData(treeModel) {
    treeModel['open'] = false;
    treeModel['checked'] = 0;
    treeMap.putIfAbsent(treeModel[widget.config.id], () => treeModel);
    (treeModel[widget.config.children] ?? []).forEach((element) {
      factoryTreeData(element);
    });
  }

  /// @params
  /// @desc
  buildTreeParent() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => onOpenNode(sourceTreeMap),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 20, top: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    (sourceTreeMap[widget.config.children] ?? []).isNotEmpty
                        ? Icon(
                            (sourceTreeMap['open'] ?? false) ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right,
                            size: 20,
                          )
                        : SizedBox.shrink(),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        selectCheckedBox(sourceTreeMap);
                      },
                      child: buildCheckBoxIcon(sourceTreeMap),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(
                        '${sourceTreeMap[widget.config.label]}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                (sourceTreeMap['open'] ?? false)
                    ? Column(
                        children: buildTreeNode(sourceTreeMap),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// @params
  /// @desc
  buildTreeNode(Map<String, dynamic> data) {
    return (data[widget.config.children] ?? []).map<Widget>(
      (e) {
        // logger.v(e);
        return GestureDetector(
          onTap: () => onOpenNode(e),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 20, top: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    (e[widget.config.children] ?? []).isNotEmpty
                        ? Icon(
                            (e['open'] ?? false) ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right,
                            size: 20,
                          )
                        : SizedBox.shrink(),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        selectCheckedBox(e);
                      },
                      child: buildCheckBoxIcon(e),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(
                        '${e[widget.config.label]}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                (e['open'] ?? false)
                    ? Column(
                        children: buildTreeNode(e),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        );
      },
    ).toList();
  }

  Icon buildCheckBoxIcon(Map<String, dynamic> e) {
    switch (e['checked'] ?? 0) {
      case 0:
        return Icon(
          Icons.check_box_outline_blank,
          color: Color(0XFFCCCCCC),
        );
      case 1:
        return Icon(
          Icons.indeterminate_check_box,
          color: Color(0X990000FF),
        );
      case 2:
        return Icon(
          Icons.check_box,
          color: Color(0X990000FF),
        );
      default:
        return Icon(Icons.remove);
    }
  }

  /// @params
  /// @desc
  onOpenNode(Map<String, dynamic> model) {
    if ((model[widget.config.children] ?? []).isEmpty) return;
    model['open'] = !model['open'];
    setState(() {
      sourceTreeMap = sourceTreeMap;
    });
  }

  /// @params
  /// @desc
  selectNode(Map<String, dynamic> dataModel) {
    setState(() {
      selectValue = dataModel['value']!;
    });
  }

  /// @params
  /// @desc
  selectCheckedBox(Map<String, dynamic> dataModel) {
    logger.v(dataModel);
    int checked = dataModel['checked']!;
    if ((dataModel[widget.config.children] ?? []).isNotEmpty) {
      var stack = MStack();
      stack.push(dataModel);
      while (stack.top > 0) {
        Map<String, dynamic> node = stack.pop();
        for (var item in node[widget.config.children] ?? []) {
          stack.push(item);
        }
        if (checked == 2) {
          node['checked'] = 0;
        } else {
          node['checked'] = 2;
        }
      }
    } else {
      if (checked == 2) {
        dataModel['checked'] = 0;
      } else {
        dataModel['checked'] = 2;
      }
    }

    // 父节点
    if (dataModel[widget.config.parentId]! > 0) {
      updateParentNode(dataModel);
    } else {}
    getCheckedItems();
    setState(() {
      sourceTreeMap = sourceTreeMap;
    });
  }

  getCheckedItems() {
    var stack = MStack();
    var checkedList = [];
    stack.push(sourceTreeMap);
    while (stack.top > 0) {
      var node = stack.pop();
      for (var item in (node[widget.config.children] ?? [])) {
        stack.push(item);
      }
      if (node['checked'] == 2) {
        checkedList.add(node['value']);
      }
    }
  }

  /// @params
  /// @desc
  updateParentNode(Map<String, dynamic> dataModel) {
    var par = treeMap[dataModel[widget.config.parentId]];
    if (par == null) return;
    int checkLen = 0;
    bool partChecked = false;
    for (var item in (par[widget.config.children] ?? [])) {
      if (item['checked'] == 2) {
        checkLen++;
      } else if (item['checked'] == 1) {
        partChecked = true;
        break;
      }
    }

    // 如果子孩子全都是选择的， 父节点就全选
    if (checkLen == (par[widget.config.children] ?? []).length) {
      par['checked'] = 2;
    } else if (partChecked || (checkLen < (par[widget.config.children] ?? []).length && checkLen > 0)) {
      par['checked'] = 1;
    } else {
      par['checked'] = 0;
    }

    // 如果还有父节点 解析往上更新
    if (treeMap[par[widget.config.parentId]] != null || treeMap[par[widget.config.parentId]] == 0) {
      updateParentNode(par);
    } else {}
    // setState(() {
    //   sourceTreeMap = sourceTreeMap;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: buildTreeParent(),
      ),
    );
  }
}
