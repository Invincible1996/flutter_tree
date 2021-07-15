/// @create at 2021/7/15 15:01
/// @create by kevin
/// @desc stack
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
