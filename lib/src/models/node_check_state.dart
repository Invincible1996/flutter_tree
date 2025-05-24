/// Enum representing the check state of a tree node.
enum NodeCheckState {
  /// The node is not checked.
  unchecked,

  /// The node is fully checked.
  checked,

  /// The node is partially checked (e.g., some children are checked).
  partial,
}
