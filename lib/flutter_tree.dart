library packages;

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'flutter_tree_pro.dart';

enum DataType {
  DataList,
  DataMap,
}

/// @create at 2021/7/15 15:01
/// @create by kevin
/// @desc  参数类型配置
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

var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
  ),
);

/// @create at 2021/7/15 15:01
/// @create by kevin
/// @desc components
class FlutterTreePro extends StatefulWidget {
  /// source data type Map
  final List<Map<String, dynamic>> treeData;

  ///  source data type List
  final List<Map<String, dynamic>> listData;

  ///  initial source data type Map
  final Map<String, dynamic> initialTreeData;

  ///  initial source data type List
  final List<Map<String, dynamic>> initialListData;

  final Function(List<Map<String, dynamic>>) onChecked;

  ///  Config
  final Config config;

  /// if expanded items
  final bool isExpanded;

  /// is right to left
  final bool isRTL;

  /// is single select
  final bool isSingleSelect;

  /// initial select value
  final int initialSelectValue;

  FlutterTreePro({
    Key? key,
    this.treeData = const <Map<String, dynamic>>[],
    this.initialTreeData = const <String, dynamic>{},
    this.config = const Config(),
    this.listData = const <Map<String, dynamic>>[],
    this.initialListData = const <Map<String, dynamic>>[],
    required this.onChecked,
    this.isExpanded = false,
    this.isRTL = false,
    this.isSingleSelect = false,
    this.initialSelectValue = 0,
  }) : super(key: key);

  @override
  _FlutterTreeProState createState() => _FlutterTreeProState();
}

class _FlutterTreeProState extends State<FlutterTreePro> {
  ///
  List<Map<String, dynamic>> sourceTreeMapList = [];

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

  // 单选功能 当前选中的ID
  int currentSelectId = 0;

  @override
  initState() {
    super.initState();
    currentSelectId = widget.initialSelectValue;
    // set default select
    if (widget.config.dataType == DataType.DataList) {
      final list = DataUtil.convertData(widget.listData);
      sourceTreeMapList
        ..clear()
        ..addAll(list);
      log(sourceTreeMapList.toString());
      logger.t(sourceTreeMapList);
      sourceTreeMapList.forEach((element) {
        factoryTreeData(element);
      });
      widget.initialListData.forEach((element) {
        element['checked'] = 0;
      });
      if (widget.isSingleSelect) {
        for (var item in treeMap.values.toList()) {
          if (item['id'] == widget.initialSelectValue) {
            setCheckStatus(item);
            break;
          }
        }
      } else {
        for (var item in widget.initialListData) {
          for (var element in treeMap.values.toList()) {
            if (item['id'] == element['id']) {
              setCheckStatus(element);
              break;
            }
          }
          selectCheckedBox(item, initial: true);
        }
      }
    } else {
      sourceTreeMapList = widget.treeData;
      sourceTreeMapList.forEach((element) {
        factoryTreeData(element);
      });
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
    treeModel['open'] = widget.isExpanded;
    treeModel['checked'] = 0;
    treeMap.putIfAbsent(treeModel[widget.config.id], () => treeModel);
    (treeModel[widget.config.children] ?? []).forEach((element) {
      factoryTreeData(element);
    });
  }

  /// @params
  /// @desc render parent
  buildTreeParent(sourceTreeMap) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => onOpenNode(sourceTreeMap),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(
              left: 20,
              top: 15,
            ),
            child: Column(
              children: [
                Row(
                  textDirection:
                      widget.isRTL ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    (sourceTreeMap[widget.config.children] ?? []).isNotEmpty
                        ? Icon(
                            (sourceTreeMap['open'] ?? false)
                                ? Icons.keyboard_arrow_down_rounded
                                : (widget.isRTL
                                    ? Icons.keyboard_arrow_left_rounded
                                    : Icons.keyboard_arrow_right_rounded),
                            size: 20,
                          )
                        : SizedBox(
                            width: widget.isRTL ? 30 : 0,
                          ),
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
                        textAlign:
                            widget.isRTL ? TextAlign.end : TextAlign.start,
                        '${sourceTreeMap[widget.config.label]}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                (sourceTreeMap['open'] ?? false)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
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
            color: Colors.white,
            // width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 20, top: 15),
            child: Column(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  textDirection:
                      widget.isRTL ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    SizedBox(
                      width: widget.isRTL ? 20 : 0,
                    ),
                    (e[widget.config.children] ?? []).isNotEmpty
                        ? Icon(
                            (e['open'] ?? false)
                                ? Icons.keyboard_arrow_down_rounded
                                : (widget.isRTL
                                    ? Icons.keyboard_arrow_left_rounded
                                    : Icons.keyboard_arrow_right_rounded),
                            size: 20,
                          )
                        : SizedBox(
                            width: widget.isRTL ? 30 : 10,
                          ),
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
                        textAlign:
                            widget.isRTL ? TextAlign.end : TextAlign.start,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                (e['open'] ?? false)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
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
    if (widget.isSingleSelect) {
      return _buildSingleSelectIcon(e);
    } else {
      return _buildMultiSelectIcon(e);
    }
  }

  Icon _buildSingleSelectIcon(Map<String, dynamic> e) {
    if (e['children'] == null || e['children'].isEmpty) {
      return Icon(
        currentSelectId == e['id']
            ? Icons.check_box
            : Icons.check_box_outline_blank,
        color:
            currentSelectId == e['id'] ? Color(0X990000FF) : Color(0XFFCCCCCC),
      );
    } else {
      return Icon(
        Icons.check_box_outline_blank,
        color: Color(0XFFCCCCCC),
      );
    }
  }

  Icon _buildMultiSelectIcon(Map<String, dynamic> e) {
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
      sourceTreeMapList = sourceTreeMapList;
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
  /// @params
  /// @desc 选中帅选框
  void selectCheckedBox(Map<String, dynamic> dataModel,
      {bool initial = false}) {
    if (widget.isSingleSelect) {
      _handleSingleSelect(dataModel, initial);
    } else {
      _handleMultiSelect(dataModel, initial);
    }
  }

  void _handleSingleSelect(Map<String, dynamic> dataModel, bool initial) {
    if (dataModel['children'] != null && dataModel['children'].isNotEmpty) {
      return;
    }
    // 设置单选
    currentSelectId = dataModel['id'];
    if (!initial) {
      widget.onChecked([dataModel]);
    }
  }

  void _handleMultiSelect(Map<String, dynamic> dataModel, bool initial) {
    int checked = dataModel['checked']!;
    _toggleCheckState(dataModel, checked);

    // 更新父节点
    if (dataModel[widget.config.parentId]! > 0) {
      updateParentNode(dataModel);
    }
    setState(() {
      sourceTreeMapList = sourceTreeMapList;
    });

    // 获取选中的最小条目
    List<Map<String, dynamic>> checkedItems = _getCheckedItems(initial);

    // 调用 onChecked 回调函数
    if (!initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onChecked(checkedItems);
      });
    }
  }

  void _toggleCheckState(Map<String, dynamic> dataModel, int checked) {
    if ((dataModel[widget.config.children] ?? []).isNotEmpty) {
      var stack = MStack();
      stack.push(dataModel);
      while (stack.top > 0) {
        Map<String, dynamic> node = stack.pop();
        for (var item in node[widget.config.children] ?? []) {
          stack.push(item);
        }
        node['checked'] = checked == 2 ? 0 : 2;
      }
    } else {
      dataModel['checked'] = checked == 2 ? 0 : 2;
    }
  }

  List<Map<String, dynamic>> _getCheckedItems(bool initial) {
    List<Map<String, dynamic>> checkedItems = [];
    sourceTreeMapList.forEach((element) {
      checkedItems.addAll(getCheckedItems(element, initial: initial));
    });
    return checkedItems;
  }

  /// @params
  /// @desc 获取选中的条目
  /// @params
  /// @desc 获取选中的条目
  List<Map<String, dynamic>> getCheckedItems(sourceTreeMap,
      {bool initial = false}) {
    var stack = MStack();
    var checkedList = [];
    stack.push(sourceTreeMap);
    while (stack.top > 0) {
      var node = stack.pop();
      for (var item in (node[widget.config.children] ?? [])) {
        stack.push(item);
      }
      if (node['checked'] == 2 &&
          (node[widget.config.children] ?? []).isEmpty) {
        checkedList.add(node);
      }
    }

    // List中多余的元素
    var list1 = [];
    for (var value2 in checkedList) {
      if (value2['children'] != null && value2['children'].isNotEmpty) {
        for (var value in checkedList) {
          if (value2['id'] == value['parentId']) {
            list1.add(value);
          }
        }
      }
    }

    // 移除List中多余的元素
    var set = Set.from(checkedList);
    var set2 = Set.from(list1);
    List<Map<String, dynamic>> filterList = List.from(set.difference(set2));


    return filterList;
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
    } else if (partChecked ||
        (checkLen < (par[widget.config.children] ?? []).length &&
            checkLen > 0)) {
      par['checked'] = 1;
    } else {
      par['checked'] = 0;
    }

    // 如果还有父节点 解析往上更新
    if (treeMap[par[widget.config.parentId]] != null ||
        treeMap[par[widget.config.parentId]] == 0) {
      updateParentNode(par);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: sourceTreeMapList.map<Widget>((e) {
            return buildTreeParent(e);
          }).toList(),
        ),
      ),
    );
  }
}
