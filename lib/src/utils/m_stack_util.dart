/// A simple generic stack implementation.
///
/// This stack is used for iterative tree traversal to avoid deep recursion issues.
/// The original comments like "@create at", "@create by", "@desc" are preserved
/// for historical context but are not standard Dartdoc.
///
/// @create at 2021/7/15 15:01
/// @create by kevin
/// @desc stack
class MStack<T> {
  /// Tracks the number of items in the stack.
  /// Also implicitly serves as an index for the top element if using a fixed-size list,
  /// but here it's more of a counter since `items` is a growable list.
  int _top = 0; // Renamed to _top to indicate it's an internal counter.

  /// The list storing the stack items.
  final List<T> _items = []; // Made generic and final

  /// Pushes an [item] onto the top of the stack.
  void push(T item) {
    _items.add(item);
    _top++; // Increment count after adding
  }

  /// Removes and returns the item at the top of the stack.
  ///
  /// Throws a [StateError] if the stack is empty when [pop] is called.
  T pop() {
    if (isEmpty) {
      throw StateError('Cannot pop from an empty stack.');
    }
    _top--; // Decrement count before removing
    return _items.removeLast();
  }

  /// Returns the item at the top of the stack without removing it.
  ///
  /// Throws a [StateError] if the stack is empty when [peek] is called.
  T peek() {
    if (isEmpty) {
      throw StateError('Cannot peek an empty stack.');
    }
    return _items[_top - 1]; // Access the last valid item
  }

  /// Returns `true` if the stack is empty.
  bool get isEmpty => _top == 0;

  /// Returns `true` if the stack is not empty.
  bool get isNotEmpty => _top > 0;

  /// Returns the number of items in the stack.
  int get length => _top;

  /// Clears all items from the stack.
  void clear() {
    _items.clear();
    _top = 0;
  }
}
