# packages

Flutter tree select widget.

# Screenshot

![flutter_tree](https://user-images.githubusercontent.com/22675676/136653434-133b7e4a-fa57-463c-a11a-64a8711c9de9.gif)

## Usage

To use this plugin, add flutter_tree_pro as a dependency in your pubspec.yaml file.

```
dependencies:
  flutter_tree_pro: ^0.0.3
```

Use as a widget

```
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter tree pro')),
      body: Container(
        child: FlutterTree(
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
| initialListData | The initial data source            |
| parentId        | The key name of parent id          |
| dataType        | The type of data source            |
| label           | The key name of the value          |
| onChecked       | The item checked callback function |
| isExpanded      | Expanded all items by default      |
| isRTL           | Right to left enable               |
