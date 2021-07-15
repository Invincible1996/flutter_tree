/// @create at 2021/7/15 14:59
/// @create by kevin
/// @desc TreeDataModel
///
///
class TreeDataModel {
  int? id;
  int? value;
  String? label;
  int? pid;
  bool? open;
  int? checked;
  List<TreeDataModel>? children;

  TreeDataModel({
    this.id,
    this.value,
    this.label,
    this.pid,
    this.children,
    this.open,
    this.checked,
  });

  TreeDataModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    value = json['value'];
    label = json['label'];
    pid = json['pid'];
    checked = json['checked'] ?? 0;
    open = json['open'] ?? false;
    if (json['children'] != null) {
      children = <TreeDataModel>[];
      json['children'].forEach((v) {
        children!.add(new TreeDataModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['value'] = this.value;
    data['label'] = this.label;
    data['pid'] = this.pid;
    data['checked'] = this.checked;
    data['open'] = this.open ?? false;
    if (this.children != null) {
      data['children'] = this.children!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
