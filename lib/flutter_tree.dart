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

  DataType dataType;

  ///父级id key
  String parentId;

  ///value key
  String value;

  ///
  String label;

  ///
  String id;

  ///
  String children;

  Config({
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
  final treeData;
  final initialTreeData;
  final Config config;

  const FlutterTree({
    Key? key,
    required this.treeData,
    required this.initialTreeData,
    required this.config,
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

  @override
  initState() {
    super.initState();

    // set default select
    if (widget.config.dataType == DataType.DataList) {
      treeList = widget.treeData;
      checkedTreeList = widget.initialTreeData;
      var listToMap = DataUtil.transformListToMap(widget.treeData, widget.config);
      // logger.i(listToMap);
      setState(() {
        sourceTreeMap = listToMap;
      });
      factoryTreeData(sourceTreeMap, 1);
      var listToMap2 = DataUtil.transformListToMap(widget.initialTreeData, widget.config);
      // logger.i(listToMap2);
      factoryTreeData(listToMap2, 2);
      // selectCheckedBox(listToMap2);
    } else {
      sourceTreeMap = widget.treeData;
    }
  }

  /// @params
  /// @desc 将树形结构数据平铺开
  factoryTreeData(treeModel, type) {
    treeModel['open'] = false;
    treeModel['checked'] = type == 1 ? 0 : 2;
    treeMap.putIfAbsent(treeModel[widget.config.id], () => treeModel);
    (treeModel[widget.config.children] ?? []).forEach((element) {
      factoryTreeData(element, type);
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
    if (dataModel[widget.config.parentId]! >= 0) {
      updateParentNode(dataModel);
    } else {}
    getCheckedItems();
    setState(() {});
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
    setState(() {});
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
