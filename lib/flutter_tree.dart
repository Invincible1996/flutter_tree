library packages;

import 'dart:async';

import 'package:flutter/material.dart';

import 'flutter_tree_pro.dart';

enum DataType { DataList, DataMap }

/// 节点选中状态
enum CheckState {
  unchecked(0),
  partial(1),
  checked(2);

  final int value;
  const CheckState(this.value);

  static CheckState fromValue(int? value) {
    return CheckState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CheckState.unchecked,
    );
  }
}

/// 树形连接线样式
class TreeLineStyle {
  /// 线条颜色
  final Color color;

  /// 线条宽度
  final double width;

  /// 缩进宽度（每一级的间距）
  final double indent;

  /// 是否显示竖线
  final bool showVerticalLine;

  /// 是否显示水平连接线
  final bool showHorizontalLine;

  const TreeLineStyle({
    this.color = const Color(0xFFD9D9D9),
    this.width = 1.0,
    this.indent = 24.0,
    this.showVerticalLine = true,
    this.showHorizontalLine = true,
  });
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

  /// 树形连接线样式
  final TreeLineStyle lineStyle;

  const Config({
    this.dataType = DataType.DataMap,
    this.parentId = 'parentId',
    this.value = 'value',
    this.label = 'label',
    this.id = 'id',
    this.children = 'children',
    this.lineStyle = const TreeLineStyle(),
  });
}

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
  List<Map<String, dynamic>> sourceTreeMapList = [];
  bool checkedBox = false;
  int selectValue = 0;
  bool _needUpdate = false;

  Timer? _debounceTimer;

  /// 获取节点的选中状态
  CheckState _getCheckState(Map<String, dynamic> item) {
    return CheckState.fromValue(item['checked'] as int?);
  }

  /// 设置节点的选中状态
  void _setCheckState(Map<String, dynamic> item, CheckState state) {
    item['checked'] = state.value;
  }

  /// @params
  /// @desc expand map tree to map
  Map<dynamic, Map<String, dynamic>> treeMap = {};

  // 单选功能 当前选中的ID
  int currentSelectId = 0;

  void _debouncedUpdate(List<Map<String, dynamic>> checkedItems) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 100), () {
      if (_needUpdate) {
        widget.onChecked(checkedItems);
        _needUpdate = false;
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    currentSelectId = widget.initialSelectValue;
    // set default select
    if (widget.config.dataType == DataType.DataList) {
      final list = DataUtil.convertData(widget.listData, widget.config);
      sourceTreeMapList
        ..clear()
        ..addAll(list);
      sourceTreeMapList.forEach((element) {
        factoryTreeData(element);
      });
      widget.initialListData.forEach((element) {
        element['checked'] = CheckState.unchecked.value;
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
      if (sourceTreeMapList.isEmpty && widget.initialTreeData.isNotEmpty) {
        sourceTreeMapList = [widget.initialTreeData];
      }
      sourceTreeMapList.forEach((element) {
        factoryTreeData(element);
      });
    }
  }

  /// @params
  /// @desc set current item checked
  void setCheckStatus(Map<String, dynamic> item) {
    _setCheckState(item, CheckState.checked);
    if (item['children'] != null) {
      item['children'].forEach((element) {
        setCheckStatus(element);
      });
    }
  }

  /// @params
  /// @desc expand tree data to map
  void factoryTreeData(Map<String, dynamic> treeModel) {
    treeModel['open'] = widget.isExpanded;
    treeModel['checked'] = CheckState.unchecked.value;
    treeMap.putIfAbsent(treeModel[widget.config.id], () => treeModel);
    (treeModel[widget.config.children] ?? []).forEach((element) {
      factoryTreeData(element);
    });
  }

  bool _isLeafNode(Map<String, dynamic> node) {
    return (node[widget.config.children] ?? []).isEmpty;
  }

  bool _canAcceptDrop(
    Map<String, dynamic>? draggedNode,
    Map<String, dynamic> targetNode,
  ) {
    if (draggedNode == null) return false;
    if (!_isLeafNode(draggedNode)) return false;
    if (draggedNode[widget.config.id] == targetNode[widget.config.id]) {
      return false;
    }
    if (draggedNode[widget.config.parentId] == targetNode[widget.config.id]) {
      return false;
    }
    return true;
  }

  void _onLeafDropped(
    Map<String, dynamic> draggedNode,
    Map<String, dynamic> targetNode,
  ) {
    if (!_canAcceptDrop(draggedNode, targetNode)) return;
    _moveLeafNodeByDropPosition(draggedNode, targetNode);
  }

  void _moveLeafNodeByDropPosition(
    Map<String, dynamic> draggedNode,
    Map<String, dynamic> targetNode,
  ) {
    final draggedId = draggedNode[widget.config.id];
    final oldParentId = draggedNode[widget.config.parentId];
    final targetId = targetNode[widget.config.id];
    final targetParentId = targetNode[widget.config.parentId];
    if (draggedId == null || targetId == null) return;

    final dropOnLeaf = _isLeafNode(targetNode);
    final dynamic newParentId = dropOnLeaf ? targetParentId : targetId;
    if (oldParentId == newParentId && !dropOnLeaf) return;

    final oldParent = treeMap[oldParentId];
    if (oldParent != null) {
      final oldChildren = (oldParent[widget.config.children] ?? []) as List;
      oldChildren.removeWhere((item) => item[widget.config.id] == draggedId);
    } else {
      sourceTreeMapList.removeWhere(
        (item) => item[widget.config.id] == draggedId,
      );
    }

    if (dropOnLeaf) {
      if (newParentId == null || newParentId == 0) {
        final insertIndex = sourceTreeMapList.indexWhere(
          (item) => item[widget.config.id] == targetId,
        );
        if (insertIndex == -1) {
          sourceTreeMapList.add(draggedNode);
        } else {
          sourceTreeMapList.insert(insertIndex + 1, draggedNode);
        }
      } else {
        final parentNode = treeMap[newParentId];
        if (parentNode == null) return;
        final siblings =
            parentNode.putIfAbsent(widget.config.children, () => []) as List;
        final insertIndex = siblings.indexWhere(
          (item) => item[widget.config.id] == targetId,
        );
        if (insertIndex == -1) {
          siblings.add(draggedNode);
        } else {
          siblings.insert(insertIndex + 1, draggedNode);
        }
        parentNode['open'] = true;
      }
    } else {
      final targetChildren =
          targetNode.putIfAbsent(widget.config.children, () => []) as List;
      targetChildren.add(draggedNode);
      targetNode['open'] = true;
    }

    draggedNode[widget.config.parentId] = newParentId;

    _rebuildTreeMapWithoutReset();
    _notifyCheckedAfterStructureChange();
    setState(() {});
  }

  void _rebuildTreeMapWithoutReset() {
    treeMap.clear();
    for (final root in sourceTreeMapList) {
      _indexTreeNode(root);
    }
  }

  void _indexTreeNode(Map<String, dynamic> node) {
    treeMap[node[widget.config.id]] = node;
    for (final child in (node[widget.config.children] ?? [])) {
      _indexTreeNode(child as Map<String, dynamic>);
    }
  }

  void _notifyCheckedAfterStructureChange() {
    if (widget.isSingleSelect) {
      final selected = treeMap[currentSelectId];
      widget.onChecked(selected == null ? [] : [selected]);
      return;
    }
    widget.onChecked(_getCheckedItems(false));
  }

  /// @params
  /// @desc render parent
  Widget buildTreeParent(Map<String, dynamic> sourceTreeMap, {int depth = 0}) {
    final lineStyle = widget.config.lineStyle;
    final hasChildren =
        (sourceTreeMap[widget.config.children] ?? []).isNotEmpty;

    return Column(
      children: [
        DragTarget<Map<String, dynamic>>(
          onWillAcceptWithDetails: (details) {
            return _canAcceptDrop(details.data, sourceTreeMap);
          },
          onAcceptWithDetails: (details) {
            _onLeafDropped(details.data, sourceTreeMap);
          },
          builder: (context, candidateData, rejectedData) {
            return GestureDetector(
              onTap: () => onOpenNode(sourceTreeMap),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(left: lineStyle.indent, top: 15),
                color: candidateData.isNotEmpty
                    ? const Color(0xFFE8F5E9)
                    : Colors.white,
                child: Column(
                  children: [
                    Row(
                      textDirection: widget.isRTL
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 绘制层级连接线
                        if (lineStyle.showVerticalLine && depth > 0)
                          _buildParentIndentLines(depth),
                        // 展开/折叠图标
                        hasChildren
                            ? Icon(
                                (sourceTreeMap['open'] ?? false)
                                    ? Icons.keyboard_arrow_down_rounded
                                    : (widget.isRTL
                                          ? Icons.keyboard_arrow_left_rounded
                                          : Icons.keyboard_arrow_right_rounded),
                                size: 20,
                              )
                            : SizedBox(width: widget.isRTL ? 30 : 20),
                        SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            selectCheckedBox(sourceTreeMap);
                          },
                          child: buildCheckBoxIcon(sourceTreeMap),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: _isLeafNode(sourceTreeMap)
                              ? Draggable<Map<String, dynamic>>(
                                  data: sourceTreeMap,
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: const Color(0xFF90CAF9),
                                        ),
                                      ),
                                      child: Text(
                                        '${sourceTreeMap[widget.config.label]}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.4,
                                    child: Text(
                                      textAlign: widget.isRTL
                                          ? TextAlign.end
                                          : TextAlign.start,
                                      '${sourceTreeMap[widget.config.label]}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  child: Text(
                                    textAlign: widget.isRTL
                                        ? TextAlign.end
                                        : TextAlign.start,
                                    '${sourceTreeMap[widget.config.label]}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )
                              : Text(
                                  textAlign: widget.isRTL
                                      ? TextAlign.end
                                      : TextAlign.start,
                                  '${sourceTreeMap[widget.config.label]}',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ],
                    ),
                    if (sourceTreeMap['open'] ?? false)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: buildTreeNode(
                          sourceTreeMap,
                          depth: depth + 1,
                          parentIsLastList: const [],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// @params
  /// @desc render item
  List<Widget> buildTreeNode(
    Map<String, dynamic> data, {
    int depth = 1,
    List<bool> parentIsLastList = const [],
  }) {
    final lineStyle = widget.config.lineStyle;
    final children = data[widget.config.children] ?? [];

    return children.map<Widget>((e) {
      final hasChildren = (e[widget.config.children] ?? []).isNotEmpty;
      final isLast = children.last == e;
      // 传递当前节点的 isLast 状态给子节点
      final currentParentList = [...parentIsLastList, isLast];

      return DragTarget<Map<String, dynamic>>(
        onWillAcceptWithDetails: (details) {
          return _canAcceptDrop(details.data, e);
        },
        onAcceptWithDetails: (details) {
          _onLeafDropped(details.data, e);
        },
        builder: (context, candidateData, rejectedData) {
          return GestureDetector(
            onTap: () => onOpenNode(e),
            child: Container(
              color: candidateData.isNotEmpty
                  ? const Color(0xFFE8F5E9)
                  : Colors.white,
              padding: EdgeInsets.only(left: 0, top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    textDirection: widget.isRTL
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 绘制层级连接线
                      if (lineStyle.showVerticalLine && depth > 0)
                        _buildNodeIndentLines(depth, parentIsLastList, isLast),
                      // 展开/折叠图标
                      hasChildren
                          ? Icon(
                              (e['open'] ?? false)
                                  ? Icons.keyboard_arrow_down_rounded
                                  : (widget.isRTL
                                        ? Icons.keyboard_arrow_left_rounded
                                        : Icons.keyboard_arrow_right_rounded),
                              size: 20,
                            )
                          : SizedBox(width: 20),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          selectCheckedBox(e);
                        },
                        child: buildCheckBoxIcon(e),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: _isLeafNode(e)
                            ? Draggable<Map<String, dynamic>>(
                                data: e,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: const Color(0xFF90CAF9),
                                      ),
                                    ),
                                    child: Text(
                                      '${e[widget.config.label]}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.4,
                                  child: Text(
                                    '${e[widget.config.label]}',
                                    textAlign: widget.isRTL
                                        ? TextAlign.end
                                        : TextAlign.start,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                child: Text(
                                  '${e[widget.config.label]}',
                                  textAlign: widget.isRTL
                                      ? TextAlign.end
                                      : TextAlign.start,
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : Text(
                                '${e[widget.config.label]}',
                                textAlign: widget.isRTL
                                    ? TextAlign.end
                                    : TextAlign.start,
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ],
                  ),
                  if (e['open'] ?? false)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: buildTreeNode(
                        e,
                        depth: depth + 1,
                        parentIsLastList: currentParentList,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    }).toList();
  }

  /// 构建节点缩进竖线（带拐角效果）
  ///
  /// [depth] - 当前深度
  /// [parentIsLastList] - 每一层父节点是否是最后一个的列表
  /// [isLast] - 当前节点是否是最后一个
  Widget _buildNodeIndentLines(
    int depth,
    List<bool> parentIsLastList,
    bool isLast,
  ) {
    final lineStyle = widget.config.lineStyle;
    final indent = lineStyle.indent;

    return SizedBox(
      width: indent * depth,
      height: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(depth, (index) {
          // 当前层级的父节点是否是最后一个
          final parentIsLast = index < parentIsLastList.length
              ? parentIsLastList[index]
              : false;
          // 是否是当前绘制的最后一层（即连接当前节点的线）
          final isCurrentLevel = index == depth - 1;

          return Container(
            width: indent,
            height: double.infinity,
            child: CustomPaint(
              painter: _TreeLinePainter(
                color: lineStyle.color,
                strokeWidth: lineStyle.width,
                isParentLast: parentIsLast,
                isCurrentLevel: isCurrentLevel,
                isLastNode: isLast,
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 构建父节点缩进竖线（用于根节点被嵌套的情况）
  Widget _buildParentIndentLines(int depth) {
    final lineStyle = widget.config.lineStyle;
    final indent = lineStyle.indent;

    return SizedBox(
      width: indent * depth,
      height: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(depth, (index) {
          final isLastLevel = index == depth - 1;

          return Container(
            width: indent,
            height: double.infinity,
            child: CustomPaint(
              painter: _TreeLinePainter(
                color: lineStyle.color,
                strokeWidth: lineStyle.width,
                isParentLast: false, // 父节点不是最后一个，画完整竖线
                isCurrentLevel: isLastLevel,
                isLastNode: false, // 不是最后一个节点，画T形
              ),
            ),
          );
        }),
      ),
    );
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
    return Icon(
      currentSelectId == e['id']
          ? Icons.check_box
          : Icons.check_box_outline_blank,
      color: currentSelectId == e['id'] ? Color(0X990000FF) : Color(0XFFCCCCCC),
    );
  }

  Icon _buildMultiSelectIcon(Map<String, dynamic> e) {
    final state = _getCheckState(e);
    switch (state) {
      case CheckState.unchecked:
        return Icon(Icons.check_box_outline_blank, color: Color(0XFFCCCCCC));
      case CheckState.partial:
        return Icon(Icons.indeterminate_check_box, color: Color(0X990000FF));
      case CheckState.checked:
        return Icon(Icons.check_box, color: Color(0X990000FF));
    }
  }

  /// @params
  /// @desc expand item if has item has children
  void onOpenNode(Map<String, dynamic> model) {
    if ((model[widget.config.children] ?? []).isEmpty) return;
    model['open'] = !model['open'];
    setState(() {});
  }

  /// @params
  /// @desc
  void selectNode(Map<String, dynamic> dataModel) {
    setState(() {
      selectValue = dataModel['value']!;
    });
  }

  /// 选中复选框
  void selectCheckedBox(
    Map<String, dynamic> dataModel, {
    bool initial = false,
  }) {
    if (widget.isSingleSelect) {
      _handleSingleSelect(dataModel, initial);
    } else {
      _handleMultiSelect(dataModel, initial);
    }
  }

  void _handleSingleSelect(Map<String, dynamic> dataModel, bool initial) {
    // 设置单选
    currentSelectId = dataModel['id'];
    if (!initial) {
      widget.onChecked([dataModel]);
    }
  }

  void _handleMultiSelect(Map<String, dynamic> dataModel, bool initial) {
    final currentState = _getCheckState(dataModel);
    _toggleCheckState(dataModel, currentState);

    // 更新父节点
    if (dataModel[widget.config.parentId]! > 0) {
      updateParentNode(dataModel);
    }
    setState(() {
      sourceTreeMapList = sourceTreeMapList;
    });

    // 获取选中的最小条目
    if (!initial) {
      _needUpdate = true;
      List<Map<String, dynamic>> checkedItems = _getCheckedItems(initial);
      _debouncedUpdate(checkedItems);
    }

    // 调用 onChecked 回调函数
    // if (!initial) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     widget.onChecked(checkedItems);
    //   });
    // }
  }

  void _toggleCheckState(
    Map<String, dynamic> dataModel,
    CheckState currentState,
  ) {
    final newState = currentState == CheckState.unchecked
        ? CheckState.checked
        : CheckState.unchecked;
    if ((dataModel[widget.config.children] ?? []).isNotEmpty) {
      var stack = MStack();
      stack.push(dataModel);
      while (stack.top > 0) {
        Map<String, dynamic> node = stack.pop();
        for (var item in node[widget.config.children] ?? []) {
          stack.push(item);
        }
        _setCheckState(node, newState);
      }
    } else {
      _setCheckState(dataModel, newState);
    }
  }

  List<Map<String, dynamic>> _getCheckedItems(bool initial) {
    List<Map<String, dynamic>> checkedItems = [];
    sourceTreeMapList.forEach((element) {
      checkedItems.addAll(getCheckedItems(element, initial: initial));
    });
    return checkedItems;
  }

  /// 获取选中的条目
  List<Map<String, dynamic>> getCheckedItems(
    sourceTreeMap, {
    bool initial = false,
  }) {
    var stack = MStack();
    List<Map<String, dynamic>> checkedList = [];
    stack.push(sourceTreeMap);
    while (stack.top > 0) {
      var node = stack.pop();
      for (var item in (node[widget.config.children] ?? [])) {
        stack.push(item);
      }
      if (_getCheckState(node) == CheckState.checked &&
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

    // if (!initial) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     widget.onChecked(filterList);
    //   });
    // }
    return filterList;
  }

  /// @params
  /// @desc 更新父节点选中状态
  void updateParentNode(Map<String, dynamic> dataModel) {
    var par = treeMap[dataModel[widget.config.parentId]];
    if (par == null) return;
    int checkLen = 0;
    bool partChecked = false;
    for (var item in (par[widget.config.children] ?? [])) {
      final state = _getCheckState(item);
      if (state == CheckState.checked) {
        checkLen++;
      } else if (state == CheckState.partial) {
        partChecked = true;
        break;
      }
    }

    // 如果子孩子全都是选择的， 父节点就全选
    if (checkLen == (par[widget.config.children] ?? []).length) {
      _setCheckState(par, CheckState.checked);
    } else if (partChecked ||
        (checkLen < (par[widget.config.children] ?? []).length &&
            checkLen > 0)) {
      _setCheckState(par, CheckState.partial);
    } else {
      _setCheckState(par, CheckState.unchecked);
    }

    // 如果还有父节点 继续往上更新
    if (treeMap[par[widget.config.parentId]] != null) {
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
            return buildTreeParent(e, depth: 0);
          }).toList(),
        ),
      ),
    );
  }
}

/// 树形连接线绘制器 - 实现 T 形/L 形连接线
class _TreeLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  // 父节点是否是最后一个（决定竖线是否贯穿）
  final bool isParentLast;
  // 是否是当前连接层级（最后一层需要画横线）
  final bool isCurrentLevel;
  // 当前节点是否是最后一个（决定最后一层的竖线长度）
  final bool isLastNode;

  _TreeLinePainter({
    required this.color,
    required this.strokeWidth,
    this.isParentLast = false,
    this.isCurrentLevel = false,
    this.isLastNode = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    // 连接线起点（从左侧开始）
    final startX = 0.0;
    // 连接线中心点（图标位置）
    final centerX = size.width / 2;
    // 垂直中心
    final centerY = size.height / 2;

    if (isCurrentLevel) {
      // 当前层级：需要画横线连接到节点
      if (isLastNode) {
        // L 形：┖ 竖线只画上半部分，然后横线
        // 垂直线（从顶部到中心）
        canvas.drawLine(Offset(startX, 0), Offset(startX, centerY), paint);
        // 水平线（从垂直线到右侧）
        canvas.drawLine(
          Offset(startX, centerY),
          Offset(centerX, centerY),
          paint,
        );
      } else {
        // T 形：├ 竖线贯穿，然后横线
        // 垂直线（完整）
        canvas.drawLine(Offset(startX, 0), Offset(startX, size.height), paint);
        // 水平线（从垂直线到右侧）
        canvas.drawLine(
          Offset(startX, centerY),
          Offset(centerX, centerY),
          paint,
        );
      }
    } else {
      // 非当前层级：只画竖线
      if (isParentLast) {
        // 父节点是最后一个，不需要画竖线（空格）
        // 不绘制任何线条
      } else {
        // 父节点不是最后一个，需要画贯穿的竖线
        canvas.drawLine(Offset(startX, 0), Offset(startX, size.height), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TreeLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.isParentLast != isParentLast ||
        oldDelegate.isCurrentLevel != isCurrentLevel ||
        oldDelegate.isLastNode != isLastNode;
  }
}
