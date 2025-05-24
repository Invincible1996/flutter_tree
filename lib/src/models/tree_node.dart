import 'node_check_state.dart';

/// Represents a node in the tree structure.
///
/// Each node is immutable. To modify a node, create a new instance using [copyWith].
class TreeNode {
  /// Unique identifier for the node.
  final String id;

  /// Identifier of the parent node. For root nodes, this might be a specific value like "0" or empty.
  final String parentId;

  /// The text label displayed for the node.
  final String label;

  /// Indicates whether the node is currently expanded (i.e., its children are visible).
  /// Defaults to `false`.
  final bool isOpen;

  /// The current check state of the node (e.g., unchecked, checked, partial).
  /// Defaults to [NodeCheckState.unchecked].
  final NodeCheckState checkState;

  /// A list of child [TreeNode] objects. Defaults to an empty list.
  final List<TreeNode> children;

  /// Optional map to store any additional custom data associated with the node.
  final Map<String, dynamic>? extraData;

  /// Creates a new [TreeNode].
  ///
  /// Parameters:
  ///   [id]: Unique identifier for the node.
  ///   [parentId]: Identifier of the parent node.
  ///   [label]: The text label for the node.
  ///   [isOpen]: Initial expansion state. Defaults to `false`.
  ///   [checkState]: Initial check state. Defaults to [NodeCheckState.unchecked].
  ///   [children]: List of child nodes. Defaults to an empty list.
  ///   [extraData]: Optional custom data.
  TreeNode({
    required this.id,
    required this.parentId,
    required this.label,
    this.isOpen = false,
    this.checkState = NodeCheckState.unchecked,
    List<TreeNode>? children, // Children are optional and default to empty list
    this.extraData,
  }) : children = children ?? []; // Ensures children is never null

  /// Creates a copy of this [TreeNode] but with the given fields replaced with new values.
  ///
  /// Parameters:
  ///   [id]: New value for [id].
  ///   [parentId]: New value for [parentId].
  ///   [label]: New value for [label].
  ///   [isOpen]: New value for [isOpen].
  ///   [checkState]: New value for [checkState].
  ///   [children]: New list of [children].
  ///   [extraData]: New value for [extraData].
  ///   [clearExtraData]: If `true`, [extraData] will be set to `null`. This allows explicitly clearing it.
  TreeNode copyWith({
    String? id,
    String? parentId,
    String? label,
    bool? isOpen,
    NodeCheckState? checkState,
    List<TreeNode>? children,
    Map<String, dynamic>? extraData,
    bool? clearExtraData, // Specific flag to allow clearing extraData
  }) {
    return TreeNode(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      label: label ?? this.label,
      isOpen: isOpen ?? this.isOpen,
      checkState: checkState ?? this.checkState,
      children: children ?? this.children, // Uses new children if provided, otherwise keeps the old list
      extraData: clearExtraData == true ? null : (extraData ?? this.extraData), // Handles explicit null or new value
    );
  }
}
