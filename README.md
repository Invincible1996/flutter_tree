# FlutterTreePro - A Versatile Tree Widget for Flutter

A highly customizable tree view widget for Flutter that supports hierarchical data display, single and multi-node selection, RTL layouts, and configurable data mapping.

![flutter_tree_pro screenshot](https://github.com/Invincible1996/flutter_tree/assets/22675676/4e86a835-abf2-4846-a94d-c1597f2076ad)

## Features

*   Display data in a hierarchical tree structure.
*   Single selection (radio button style) or multi-selection (checkbox style).
*   Configurable mapping for your existing data structures.
*   Right-to-Left (RTL) language support.
*   Set initial expansion state for nodes.
*   Pre-select nodes or set an initial single selected value.
*   Callback function to get informed about selection changes, returning typed `TreeNode` objects.
*   Robust internal structure with clear separation of concerns.

## Getting Started

Add `flutter_tree_pro` to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_tree_pro: ^0.0.14 # Check pub.dev for the latest version
```

Then, run `flutter pub get` in your terminal.

## Usage

Import the package and use the `FlutterTreePro` widget:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_tree_pro/flutter_tree_pro.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyTreePage(),
    );
  }
}

class MyTreePage extends StatefulWidget {
  @override
  _MyTreePageState createState() => _MyTreePageState();
}

class _MyTreePageState extends State<MyTreePage> {
  // Sample data (List<Map<String, dynamic>>)
  final List<Map<String, dynamic>> exampleData = [
    {"id": "1", "parentId": "0", "title": "Root Node 1"},
    {"id": "2", "parentId": "1", "title": "Child of Root 1"},
    {"id": "3", "parentId": "1", "title": "Another Child of Root 1"},
    {"id": "4", "parentId": "2", "title": "Grandchild"},
    {"id": "5", "parentId": "0", "title": "Root Node 2"},
  ];

  // Optional: Data for initially checked nodes
  final List<Map<String, dynamic>> initialSelectionData = [
    {"id": "3", "parentId": "1", "title": "Another Child of Root 1"},
  ];

  List<TreeNode> _checkedNodes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FlutterTreePro Example')),
      body: FlutterTreePro(
        listData: exampleData,
        initialListData: initialSelectionData, // For pre-selecting nodes
        isExpanded: true, // Expand all nodes by default
        isRTL: false, // Right-to-left layout
        isSingleSelect: false, // Allow multiple selections (checkboxes)
        config: Config(
          parentIdKey: 'parentId', // Key for parent ID in your data maps - Corrected from parentId to parentIdKey
          labelKey: 'title',     // Key for node label in your data maps - Corrected from label to labelKey
          dataType: DataType.DataList, // Type of your data structure
        ),
        onChecked: (List<TreeNode> checkedNodes) {
          setState(() {
            _checkedNodes = checkedNodes;
          });
          print('Checked nodes updated:');
          for (var node in checkedNodes) {
            print('Node: ${node.label}, ID: ${node.id}, CheckState: ${node.checkState}');
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Checked node count: ${_checkedNodes.length}'),
      ),
    );
  }
}
```

## Configuration

### Data Mapping (`Config` object)

The `Config` object is crucial for telling `FlutterTreePro` how to interpret your raw data. You pass it to the `config` parameter of the widget.

**`Config` Properties:**

*   **`parentIdKey` (String):** (Default: `'parentId'`)
    The key in your data maps that holds the ID of each node's parent. For root nodes (nodes with no parent), this ID should point to a value not present as an actual node ID in your dataset (e.g., "0", `null`, or any specific identifier you use for virtual roots).
    *Example:* If your node data is `{'nodeId': 'A1', 'pRef': 'A0', ...}`, set `parentIdKey: 'pRef'`.

*   **`labelKey` (String):** (Default: `'label'`)
    The key in your data maps whose value will be displayed as the node's text label.
    *Example:* If your node data is `{'nodeId': 'A1', ..., 'displayText': 'Node A1'}`, set `labelKey: 'displayText'`.

*   **`idKey` (String):** (Default: `'id'`)
     The key in your data maps that holds the unique identifier for each node.
    *Example:* If your node data is `{'custom_id': 'A1', ...}`, set `idKey: 'custom_id'`.

*   **`childrenKey` (String):** (Default: `'children'`)
    The key used in raw map data when `dataType` is `DataType.DataMap` to identify the list of children nodes.
    *Example:* If your nested data uses `{'node_name': 'Parent', 'sub_items': [...] }`, set `childrenKey: 'sub_items'`.

*   **`dataType` (DataType):** (Default: `DataType.DataMap`)
    Specifies the format of the data you provide to `listData` or `treeData`.
    *   **`DataType.DataList`:** Your input is a `List<Map<String, dynamic>>` where each map represents a node. The hierarchy is built using the `idKey` and `parentIdKey` values.
        ```dart
        // Example for DataType.DataList:
        var myFlatData = [
          {"my_id": "101", "my_parent": "0", "node_text": "Electronics"},
          {"my_id": "102", "my_parent": "101", "node_text": "Laptops"},
          // ... more nodes
        ];
        // Config would be: 
        // Config(
        //   idKey: 'my_id', 
        //   parentIdKey: 'my_parent', 
        //   labelKey: 'node_text', 
        //   dataType: DataType.DataList
        // )
        // Pass myFlatData to the `listData` property of FlutterTreePro.
        ```
    *   **`DataType.DataMap`:** Your input is a `List<Map<String, dynamic>>` where each map represents a root node and may contain its children under the key specified by `childrenKey`. This structure can be nested.
        ```dart
        // Example for DataType.DataMap:
        var myHierarchicalData = [
          {
            "node_id": "A", "display_text": "Root A", "child_nodes": [
              {"node_id": "A1", "display_text": "Child A1"},
              {"node_id": "A2", "display_text": "Child A2"},
            ]
          },
          {"node_id": "B", "display_text": "Root B"},
        ];
        // Config would be:
        // Config(
        //   idKey: 'node_id', 
        //   labelKey: 'display_text', 
        //   childrenKey: 'child_nodes', 
        //   dataType: DataType.DataMap
        // )
        // Pass myHierarchicalData to the `treeData` property of FlutterTreePro.
        ```

### Widget Properties (`FlutterTreePro`)

Here are the properties you can use to customize the `FlutterTreePro` widget:

| Property             | Type                                      | Description                                                                                                                                          | Required | Default Value |
| -------------------- | ----------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------- |
| `treeData`           | `List<Map<String, dynamic>>`              | The raw data for the tree, used when `config.dataType` is `DataType.DataMap`. Represents a list of root nodes, already hierarchically structured.      | No       | `[]`          |
| `listData`           | `List<Map<String, dynamic>>`              | The raw data for the tree, used when `config.dataType` is `DataType.DataList`. Represents a flat list of nodes to be converted into a tree.            | No       | `[]`          |
| `onChecked`          | `Function(List<TreeNode> checkedNodes)`   | Callback invoked when node check states change. Returns a list of all currently checked `TreeNode` objects.                                            | Yes      | -             |
| `config`             | `Config`                                  | Configuration for data mapping. See details above.                                                                                                   | Yes      | `Config()`    |
| `initialListData`    | `List<Map<String, dynamic>>`              | A list of raw data maps representing nodes that should be initially checked. Nodes are matched using their ID (as per `config.idKey`).                   | No       | `[]`          |
| `initialSelectValue` | `String?`                                 | The ID of a node to be initially selected. Primarily for use when `isSingleSelect` is true.                                                        | No       | `null`        |
| `isExpanded`         | `bool`                                    | If `true`, all tree nodes will be expanded by default when first loaded.                                                                               | No       | `false`       |
| `isRTL`              | `bool`                                    | If `true`, enables Right-to-Left layout for the tree.                                                                                                | No       | `false`       |
| `isSingleSelect`     | `bool`                                    | If `true`, only one node can be selected at a time (radio button style). If `false` (default), multiple nodes can be checked (checkbox style).      | No       | `false`       |

**Understanding `TreeNode` in `onChecked`:**

The `onChecked` callback provides `List<TreeNode>`. Each `TreeNode` object is the widget's internal, typed representation of your node data, with properties like:

*   `id`: The unique ID of the node.
*   `parentId`: The ID of the node's parent.
*   `label`: The display text of the node.
*   `isOpen`: A boolean indicating if the node is currently expanded in the UI.
*   `checkState`: A `NodeCheckState` enum (`NodeCheckState.checked`, `NodeCheckState.unchecked`, `NodeCheckState.partial`) indicating its current selection state.
*   `children`: A list of its child `TreeNode` objects (if any).
*   `extraData`: A `Map<String, dynamic>?` containing any additional custom data from your original map that was not one of the standard, parsed keys.

## Example Project

For a runnable demonstration of this widget and its features, please see the `example/` directory in this repository.

## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, please feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
