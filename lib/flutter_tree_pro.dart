/// Flutter Tree Pro - A versatile and customizable tree view widget for Flutter.
///
/// This library provides the `FlutterTreePro` widget for displaying hierarchical data.
/// It also exports core data models and configuration classes necessary for its use.

library flutter_tree_pro;

// Main widget
export 'src/widgets/flutter_tree_widget.dart' show FlutterTreePro, Config, DataType;

// Core models
export 'src/models/tree_node.dart' show TreeNode;
export 'src/models/node_check_state.dart' show NodeCheckState;

// Utilities are generally not part of the public API unless specifically designed to be.
// For now, tree_data_parser.dart and m_stack_util.dart are considered internal.
// If Config and DataType were moved to a core definitions file, that would be exported here too.
// e.g., export 'src/core/tree_definitions.dart' show Config, DataType;
