# packages

Flutter tree select widget.

# Screenshot

![flutter_tree](https://user-images.githubusercontent.com/22675676/136653434-133b7e4a-fa57-463c-a11a-64a8711c9de9.gif)

## Usage
To use this plugin, add path_provider as a dependency in your pubspec.yaml file.
```aidl
dependencies:
  flutter_tree_pro: ^0.0.3
```
Use as a widget
```aidl
FlutterTree(
              listData: treeListData,
              initialListData: initialTreeData,
              config: Config(
                parentId: 'parentId',
                dataType: DataType.DataList,
                label: 'value',
              ),
              onChecked: (List<Map<String, dynamic>> checkedList) {
              },
         )
```

## Property
| property | description |
| --- | --- |
| listData | The data source |
| initialListData | The initial data source |
| parentId | The key name of parent id |
| dataType | The type of data source |
| label | The key name of the value |
| onChecked | The item checked callback function |