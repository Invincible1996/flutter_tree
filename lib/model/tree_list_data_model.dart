/// @create at 2021/7/15 14:59
/// @create by kevin
/// @desc data model
///
///
class TreeListDataModel {
  int? subject;
  List<int>? exams;
  int? parentId;
  String? knowledgeNo;
  String? knowledgeName;
  String? examPaperData;
  int? id;
  int? level;
  List<TreeListDataModel> children = [];

  TreeListDataModel({this.subject, this.exams, this.parentId, this.knowledgeNo, this.knowledgeName, this.examPaperData, this.id, this.level, this.children = const []});

  TreeListDataModel.fromJson(Map<String, dynamic> json) {
    subject = json['subject'];
    exams = json['exams'].cast<int>();
    parentId = json['parentId'];
    knowledgeNo = json['knowledgeNo'];
    knowledgeName = json['knowledgeName'];
    examPaperData = json['examPaperData'];
    id = json['id'];
    level = json['level'];
    // if (json['children'] != null) {
    //   children = <TreeListDataModel>[];
    (json['children'] ?? []).forEach((v) {
      children.add(new TreeListDataModel.fromJson(v));
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subject'] = this.subject;
    data['exams'] = this.exams;
    data['parentId'] = this.parentId;
    data['knowledgeNo'] = this.knowledgeNo;
    data['knowledgeName'] = this.knowledgeName;
    data['examPaperData'] = this.examPaperData;
    data['id'] = this.id;
    data['level'] = this.level;
    // if (this.children != null) {
    data['children'] = this.children.map((v) => v.toJson()).toList();
    // }
    return data;
  }
}
