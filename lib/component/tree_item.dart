/*
 * @Date: 2021/6/9 15:04
 * @Author: kevin
 * @LastEditors: Big.shot
 * @LastEditTime: 2021-04-09 11:50:09
 * @Description: dart
 */

import 'package:flutter/material.dart';
import 'package:flutter_tree/model/tree_data_model.dart';

class TreeItem extends StatelessWidget {
  final TreeDataModel item;

  const TreeItem({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Colors.grey,
          ),
        ),
      ),
      padding: EdgeInsets.only(left: item.id.toString().length * 15),
      child: Row(
        children: [
          (item.children ?? []).isNotEmpty
              ? Icon(
                  Icons.remove_circle,
                  color: Colors.grey,
                )
              : SizedBox(),
          SizedBox(
            width: 5,
          ),
          Icon(
            Icons.check_box,
            color: Colors.blue,
          ),
          SizedBox(
            width: 5,
          ),
          Text('${item.label}'),
        ],
      ),
    );
  }
}
