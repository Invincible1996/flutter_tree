# packages

Flutter tree select widget.

# Screenshot

![flutter_tree](https://github.com/Invincible1996/flutter_tree/assets/22675676/4e86a835-abf2-4846-a94d-c1597f2076ad)

## Usage

To use this plugin, add flutter_tree_pro as a dependency in your pubspec.yaml file.

```
dependencies:
  flutter_tree_pro: ^0.0.14
```

Use as a widget

```
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter tree pro')),
      body: Container(
        child: FlutterTreePro(
          listData: treeListData,
          initialListData: initialTreeData,
          config: Config(
            parentId: 'parentId',
            dataType: DataType.DataList,
            label: 'value',
          ),
          onChecked: (List<Map<String, dynamic>> checkedList) {},
        ),
      ),
    );
  }
```

## Property

| property        | description                        |
|-----------------|------------------------------------|
| listData        | The data source                    |
| treeData        | The tree source when using DataMap |
| initialTreeData | Fallback root data for DataMap when treeData is empty |
| initialListData | The initial data source            |
| parentId        | The key name of parent id          |
| dataType        | The type of data source            |
| label           | The key name of the value          |
| onChecked       | The item checked callback function |
| isExpanded      | Expanded all items by default      |
| isRTL           | Right to left enable               |

## Notes

- `DataType.DataList`: set `listData` and `initialListData`.
- `DataType.DataMap`: `treeData` has higher priority; when `treeData` is empty, `initialTreeData` is used as fallback root data.
- Multi-select `onChecked` returns checked leaf nodes after deduplication/filtering, not every checked parent node.
- `Config.value` is reserved for compatibility and is not part of current select-state calculation.
