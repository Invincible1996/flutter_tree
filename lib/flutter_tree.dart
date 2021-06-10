library packages;

import 'package:flutter/material.dart';
import 'package:flutter_tree/data/feak_data.dart';
import 'package:flutter_tree/model/tree_data_model.dart';
import 'package:flutter_tree/model/tree_list_data_model.dart';
import 'package:flutter_tree/utils/util.dart';

class FlutterTree extends StatefulWidget {
  final Map<String, dynamic> treeData;

  const FlutterTree({Key? key, required this.treeData}) : super(key: key);

  @override
  _FlutterTreeState createState() => _FlutterTreeState();
}

class _FlutterTreeState extends State<FlutterTree> {
  ///
  TreeDataModel treeModel = TreeDataModel();

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

  Map treeData = {};

  ///
  List treeList = [];

  @override
  initState() {
    super.initState();
    treeModel = TreeDataModel.fromJson(widget.treeData);
    factoryTreeData(treeModel);
    factoryListData();
  }

  /// @params
  /// @desc List结构转化成树形结构
  factoryListData() {
    List<TreeListDataModel> newList = [];
    TreeListDataModel treeDataModel = TreeListDataModel();
    Map obj = {};
    int? rootId;
    treeListData.forEach((element) {
      newList.add(TreeListDataModel.fromJson(element));
    });

    print(newList);

    newList.forEach((element) {
      if (element.parentId != 0) {
      } else {
        // parenId 为0 设为根节点
        // treeDataModel.parentId = element.parentId;
      }
    });

    treeListData.forEach((v) {
      // 根节点
      if (v['parentId'] != 0) {
        if (obj[v['parentId']] != null) {
          if (obj[v['parentId']]['children'] != null) {
            obj[v['parentId']]['children'].add(v);
          } else {
            obj[v['parentId']]['children'] = [v];
          }
        } else {
          obj[v['parentId']] = {
            "children": [v],
          };
        }
      } else {
        rootId = v['id'];
      }
      if (obj[v['id']] != null) {
        v['children'] = obj[v['id']]['children'];
      }
      obj[v['id']] = v;
    });

    setState(() {
      treeData = obj[rootId];
    });
    print(treeData);
  }

  /// @params
  /// @desc 将树形结构数据平铺开
  factoryTreeData(TreeDataModel treeModel) {
    (treeModel.children ?? []).forEach((element) {
      treeMap.putIfAbsent(element.id, () => element);
      factoryTreeData(element);
    });
  }

  /// @params
  /// @desc
  buildTreeParent() {}

  /// @params
  /// @desc
  buildTreeNode(TreeDataModel data) {
    return (data.children ?? [])
        .map<Widget>(
          (e) => GestureDetector(
            onTap: () => onOpenNode(e),
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 20, top: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      (e.children ?? []).isNotEmpty
                          ? Icon(
                              e.open! ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right,
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
                        // child: Icon(
                        //   buildCheckBoxIcon(e),
                        //   color: Colors.lightGreen,
                        //   size: 20,
                        // ),
                        child: buildCheckBoxIcon(e),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        '${e.label}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  e.open!
                      ? Column(
                          children: buildTreeNode(e),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ),
        )
        .toList();
  }

  Icon buildCheckBoxIcon(TreeDataModel e) {
    switch (e.checked) {
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
  onOpenNode(TreeDataModel model) {
    if ((model.children ?? []).isEmpty) return;
    model.open = !model.open!;
    setState(() {
      treeModel = treeModel;
    });
  }

  /// @params
  /// @desc
  selectNode(TreeDataModel dataModel) {
    setState(() {
      selectValue = dataModel.value!;
    });
  }

  /// @params
  /// @desc
  selectCheckedBox(TreeDataModel dataModel) {
    int checked = dataModel.checked!;
    if ((dataModel.children ?? []).isNotEmpty) {
      var stack = MStack();
      stack.push(dataModel);
      while (stack.top > 0) {
        TreeDataModel node = stack.pop();
        for (var item in node.children ?? []) {
          stack.push(item);
        }
        if (checked == 2) {
          node.checked = 0;
        } else {
          node.checked = 2;
        }
      }
    } else {
      if (checked == 2) {
        dataModel.checked = 0;
      } else {
        dataModel.checked = 2;
      }
    }

    // 父节点
    if (dataModel.pid! > 0 || dataModel.pid == 0) {
      updateParentNode(dataModel);
    } else {}
    getCheckedItems();
    setState(() {});
  }

  getCheckedItems() {
    var stack = MStack();
    var checkedList = [];
    stack.push(treeModel);
    while (stack.top > 0) {
      var node = stack.pop();
      for (var item in (node.children ?? [])) {
        stack.push(item);
      }
      if (node.checked == 2) {
        checkedList.add(node.value);
      }
    }
  }

  /// @params
  /// @desc
  updateParentNode(TreeDataModel dataModel) {
    var par = treeMap[dataModel.pid];
    if (par == null) return;
    int checkLen = 0;
    bool partChecked = false;
    for (var item in (par.children ?? [])) {
      if (item.checked == 2) {
        checkLen++;
      } else if (item.checked == 1) {
        partChecked = true;
        break;
      }
    }

    // 如果子孩子全都是选择的， 父节点就全选
    if (checkLen == (par.children ?? []).length) {
      par.checked = 2;
    } else if (partChecked || (checkLen < (par.children ?? []).length && checkLen > 0)) {
      par.checked = 1;
    } else {
      par.checked = 0;
    }

    // 如果还有父节点 解析往上更新
    if (treeMap[par.pid] != null || treeMap[par.pid] == 0) {
      updateParentNode(par);
    } else {}

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        children: buildTreeNode(treeModel),
      ),
    );
  }
}
