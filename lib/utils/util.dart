/*
 * @Date: 2021/6/9 18:41
 * @Author: kevin
 * @LastEditors: Big.shot
 * @LastEditTime: 2021-04-09 11:50:09
 * @Description: dart
 */
class MStack {
  int top = 0;
  List items = [];

  push(item) {
    top++;
    this.items.add(item);
  }

  pop() {
    --top;
    return this.items.removeLast();
  }

  peek() {
    return this.items[this.top - 1];
  }
}
