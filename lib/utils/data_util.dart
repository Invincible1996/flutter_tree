import 'package:flutter_tree_pro/flutter_tree.dart';

/// @create at 2021/7/15 15:01
/// @create by kevin
/// @desc

class DataUtil {
  /// @params
  /// @desc  List to map
  static Map<String, dynamic> transformListToMap(List dataList, Config config) {
    Map obj = {};
    dynamic rootId;
    dataList.forEach((v) {
      // 根节点
      if (v[config.parentId] != 0) {
        if (obj[v[config.parentId]] != null) {
          if (obj[v[config.parentId]][config.children] != null) {
            obj[v[config.parentId]][config.children].add(v);
          } else {
            obj[v[config.parentId]][config.children] = [v];
          }
        } else {
          obj[v[config.parentId]] = {
            config.children: [v],
          };
        }
      } else {
        rootId = v[config.id];
      }
      if (obj[v[config.id]] != null) {
        v[config.children] = obj[v[config.id]][config.children];
      }
      obj[v[config.id]] = v;
    });
    return obj[rootId] ?? {};
  }

  static List<Map<String, dynamic>> convertData(
      List<Map<String, dynamic>> data) {
    Map<dynamic, Map<String, dynamic>> idMap = {};

    // 首先将数据映射到一个 Map 中，键为 id，值为对应的数据项
    for (Map<String, dynamic> item in data) {
      idMap[item['id']] = item;
    }

    List<Map<String, dynamic>> result = [];

    // 遍历每个数据项
    for (Map<String, dynamic> item in data) {
      var parentId = item['parentId'];

      // 如果当前项的父级 ID 不存在于数据中，则它是根节点
      if (!idMap.containsKey(parentId)) {
        result.add(item);
      } else {
        // 否则，将它添加到父级的 children 列表中
        Map<String, dynamic>? parent = idMap[parentId];
        if (parent != null) {
          parent.putIfAbsent('children', () => []);
          parent['children'].add(item);
        }
      }
    }

    return result;
  }

  /// @params
  /// @desc expand tree map
  Map<String, dynamic> expandMap(Map<String, dynamic> dataMap, Config config) {
    dataMap['open'] = false;
    dataMap['checked'] = 0;
    dataMap.putIfAbsent(dataMap[config.id], () => dataMap);
    (dataMap[config.children] ?? []).forEach((element) {
      expandMap(element, config);
    });
    return {"aaa": ""};
  }

  /// @params
  /// @desc 将树形结构数据平铺开
  // factoryTreeData(treeModel ,Config config) {
  //   treeModel['open'] = false;
  //   treeModel['checked'] = 0;
  //   treeMap.putIfAbsent(treeModel[config.id], () => treeModel);
  //   (treeModel[config.children] ?? []).forEach((element) {
  //     factoryTreeData(element);
  //   });
  // }
}
