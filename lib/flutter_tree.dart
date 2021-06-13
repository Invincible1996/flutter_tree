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
  /// source data type Map
  final Map<String, dynamic> treeData;

  ///  source data type List
  final List<Map<String, dynamic>> listData;

  ///  initial source data type Map
  final Map<String, dynamic> initialTreeData;

  ///  initial source data type List
  final List<Map<String, dynamic>> initialListData;

  ///  Config
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

  /// @params
  /// @desc expand map tree to map
  Map treeMap = {};

  @override
  initState() {
    super.initState();
    // set default select
    if (widget.config.dataType == DataType.DataList) {
      var listToMap = DataUtil.transformListToMap(widget.listData, widget.config);
      sourceTreeMap = listToMap;
      factoryTreeData(sourceTreeMap);
      widget.initialListData.forEach((element) {
        element['checked'] = 0;
      });
      for (var item in widget.initialListData) {
        for (var element in treeMap.values.toList()) {
          if (item['id'] == element['id']) {
            setCheckStatus(element);
            break;
          }
        }
        selectCheckedBox(item);
      }
    } else {
      sourceTreeMap = widget.treeData;
    }
  }

  /// @params
  /// @desc set current item checked
  setCheckStatus(item) {
    item['checked'] = 2;
    if (item['children'] != null) {
      item['children'].forEach((element) {
        setCheckStatus(element);
      });
    }
  }

  /// @params
  /// @desc expand tree data to map
  factoryTreeData(treeModel) {
    treeModel['open'] = false;
    treeModel['checked'] = 0;
    treeMap.putIfAbsent(treeModel[widget.config.id], () => treeModel);
    (treeModel[widget.config.children] ?? []).forEach((element) {
      factoryTreeData(element);
    });
  }

  /// @params
  /// @desc render parent
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
  /// @desc render item
  buildTreeNode(Map<String, dynamic> data) {
    return (data[widget.config.children] ?? []).map<Widget>(
      (e) {
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

  /// @params
  /// @desc render icon by checked type
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
  /// @desc expand item if has item has children
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
  /// @desc 选中帅选框
  selectCheckedBox(Map<String, dynamic> dataModel) {
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
    }
    getCheckedItems();
    setState(() {
      sourceTreeMap = sourceTreeMap;
    });
  }

  /// @params
  /// @desc 获取选中的条目
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
        checkedList.add(node);
      }
    }
    // logger.v(checkedList);
    // var filterChildrenList = checkedList.where((element) => ((element['children'] ?? []).isNotEmpty)).toList();
    // var filterNoChildrenList = checkedList.where((element) => ((element['children'] ?? []).isEmpty)).toList();
    // var newList = [];
    // for (var item1 in filterChildrenList) {
    //   for (var item2 in filterNoChildrenList) {
    //     if (item1['id'] != item2['parentId']) {
    //       newList.add(item2);
    //       // break;
    //     }
    //   }
    // }
    // newList.addAll(filterChildrenList);
    // newList.forEach((element) {
    //   element['children'] = [];
    // });
    // logger.v(newList);
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
    }
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
