// This file defines the main FlutterTreePro widget and related configuration classes.
// Ideally, DataType and Config would be in a separate file (e.g., lib/src/core/tree_definitions.dart)
// to improve modularity and avoid potential import cycles, especially if TreeController
// needed to import them directly and this file (widget) imports TreeController.
// For this refactoring, they remain here as per the existing structure before this comment pass.

import 'dart:async';
import 'package:flutter/material.dart';

import '../models/tree_node.dart';
import '../models/node_check_state.dart';
import '../controllers/tree_controller.dart';

// Note: The exports for TreeNode and NodeCheckState were previously here.
// They are more appropriately placed in the main library file (lib/flutter_tree_pro.dart).

/// Defines the type of data source used for the tree.
enum DataType {
  /// The input data is a flat list of items, where each item contains
  /// information about its parent-child relationship (e.g., using a 'parentId' field).
  /// This list will be converted into a hierarchical tree structure.
  DataList,

  /// The input data is already a hierarchically structured list of maps,
  /// where each map can contain a list of its children (e.g., using a 'children' key).
  DataMap,
}

/// Configuration settings for the [FlutterTreePro] widget.
///
/// This class allows customization of how raw data (if provided as `List<Map<String, dynamic>>`)
/// is parsed into [TreeNode] objects, particularly when using map-based data sources.
class Config {
  /// The type of the source data. See [DataType].
  final DataType dataType;

  /// The key used in raw map data to identify the parent's ID.
  /// Relevant when [dataType] is [DataType.DataList].
  final String parentIdKey;

  /// The key used in raw map data for an optional 'value' field.
  /// The usage of this value within the tree is application-specific and might
  /// be stored in [TreeNode.extraData].
  final String valueKey;

  /// The key used in raw map data to identify the node's label.
  final String labelKey;

  /// The key used in raw map data to identify the node's unique ID.
  final String idKey;

  /// The key used in raw map data (when [dataType] is [DataType.DataMap])
  /// to identify the list of children nodes.
  final String childrenKey;

  /// Creates a new [Config] instance.
  ///
  /// Default values are provided for common key names.
  const Config({
    this.dataType = DataType.DataMap,
    this.parentIdKey = 'parentId',
    this.valueKey = 'value',
    this.labelKey = 'label',
    this.idKey = 'id',
    this.childrenKey = 'children',
  });
}

/// A highly configurable tree view widget for Flutter.
///
/// `FlutterTreePro` displays hierarchical data, allowing for node expansion,
/// single or multi-selection, and customization of data parsing and appearance.
/// It uses a [TreeController] internally to manage the tree state.
class FlutterTreePro extends StatefulWidget {
  /// The primary data source if it's already in a hierarchical (map-based) tree structure.
  /// Used when [Config.dataType] is [DataType.DataMap]. Each map should conform to the
  /// keys specified in [config] (e.g., [Config.labelKey], [Config.childrenKey]).
  final List<Map<String, dynamic>> treeData;

  /// The primary data source if it's a flat list of items.
  /// Used when [Config.dataType] is [DataType.DataList]. Each map should contain
  /// keys for ID, parent ID, and label as specified in [config].
  final List<Map<String, dynamic>> listData;

  /// A list of raw data maps representing nodes that should be initially checked.
  /// Each map in this list should contain at least an 'id' (matching [Config.idKey])
  /// that corresponds to a node in the main tree data.
  /// This is primarily used for multi-selection mode.
  final List<Map<String, dynamic>> initialListData;

  /// Callback function invoked when the check state of nodes changes.
  /// For multi-select, this provides a list of all currently checked [TreeNode]s.
  /// For single-select, this provides a list containing the single selected [TreeNode].
  final Function(List<TreeNode> checkedNodes) onChecked;

  /// Configuration for data parsing and key mapping. See [Config].
  final Config config;

  /// If `true`, all nodes will be initially expanded. Defaults to `false`.
  final bool isExpanded;

  /// If `true`, the tree will be rendered in a right-to-left direction.
  /// This affects the placement of expansion icons and text alignment. Defaults to `false`.
  final bool isRTL;

  /// If `true`, only one node can be selected at a time (radio button style).
  /// If `false`, multiple nodes can be selected (checkbox style). Defaults to `false`.
  final bool isSingleSelect;

  /// The ID of the node that should be initially selected in single-select mode.
  /// This should match the `id` property of one of the [TreeNode]s.
  final String? initialSelectValue;

  /// Creates a [FlutterTreePro] widget.
  ///
  /// Requires [onChecked] callback. Other parameters are optional with defaults.
  FlutterTreePro({
    Key? key,
    this.treeData = const [],
    this.listData = const [],
    this.initialListData = const [],
    required this.onChecked,
    this.config = const Config(),
    this.isExpanded = false,
    this.isRTL = false,
    this.isSingleSelect = false,
    this.initialSelectValue,
  }) : super(key: key);

  @override
  _FlutterTreeProState createState() => _FlutterTreeProState();
}

/// The state class for the [FlutterTreePro] widget.
///
/// It manages the [TreeController] and handles UI updates based on state changes
/// from the controller. It also manages debouncing for the `onChecked` callback.
class _FlutterTreeProState extends State<FlutterTreePro> {
  /// The controller responsible for managing the tree's state and logic.
  late TreeController _treeController;

  /// Timer used to debounce the `onChecked` callback, preventing rapid firing
  /// during quick user interactions.
  Timer? _debounceTimer;

  /// Flag to indicate if the `onChecked` callback needs to be invoked after debouncing.
  bool _needsCallbackUpdate = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  /// Initializes the [TreeController] with data and configuration from the widget.
  /// Sets up a listener for state changes from the controller.
  void _initializeController() {
    _treeController = TreeController(
      initialTreeData: widget.treeData,
      initialListData: widget.listData, // This was widget.listData, should be correct for flat list
      initialCheckedRawItems: widget.initialListData,
      config: widget.config,
      initiallyExpanded: widget.isExpanded,
      isSingleSelect: widget.isSingleSelect,
      initialSelectValue: widget.initialSelectValue,
      onCheckedNodesUpdate: (List<TreeNode> checkedNodes) {
        // This callback is invoked by the TreeController when its internal logic
        // determines that the list of checked nodes has changed and should be reported.
        _needsCallbackUpdate = true;
        _performDebouncedUpdate(checkedNodes);
      },
    );
    _treeController.addListener(_onTreeStateChanged);
  }

  /// Listener callback for state changes from the [TreeController].
  /// Triggers a UI rebuild by calling `setState`.
  void _onTreeStateChanged() {
    if (mounted) { // Ensure the widget is still part of the tree.
      setState(() {
        // The UI will rebuild based on the new state from _treeController.
      });
    }
  }
  
  /// Performs the actual `widget.onChecked` callback after a debounce delay.
  void _performDebouncedUpdate(List<TreeNode> checkedNodes) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (_needsCallbackUpdate && mounted) { // Check mounted again before calling callback
        widget.onChecked(checkedNodes);
        _needsCallbackUpdate = false;
      }
    });
  }

  @override
  void didUpdateWidget(covariant FlutterTreePro oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if any critical data or configuration changed that requires re-initializing the controller.
    // This ensures the tree reflects new data if the parent widget rebuilds with different props.
    // A more granular update strategy within the controller might be possible for some props,
    // but recreating the controller is a robust way to handle potentially significant changes.
    if (widget.listData != oldWidget.listData ||
        widget.treeData != oldWidget.treeData ||
        widget.initialListData != oldWidget.initialListData ||
        widget.config != oldWidget.config || // Note: Config comparison relies on its equality implementation.
        widget.isExpanded != oldWidget.isExpanded ||
        widget.isSingleSelect != oldWidget.isSingleSelect ||
        widget.initialSelectValue != oldWidget.initialSelectValue) {
      
      // Dispose the old controller and its listener before creating a new one.
      _treeController.removeListener(_onTreeStateChanged);
      _treeController.dispose();
      
      _initializeController(); // Re-create and initialize with new widget data.
    }
  }

  @override
  void dispose() {
    // Clean up resources when the widget is removed from the tree.
    _treeController.removeListener(_onTreeStateChanged);
    _treeController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Handles the tap action for opening or closing a tree node.
  /// Delegates the action to the [TreeController].
  void _onOpenNode(TreeNode node) {
    _treeController.toggleNodeExpansion(node);
  }

  /// Handles the tap action on a node's checkbox.
  /// Delegates the selection logic to the [TreeController].
  void _onSelectCheckBox(TreeNode node) {
    if (_treeController.isSingleSelect) {
      _treeController.selectNodeSingle(node);
    } else {
      _treeController.toggleNodeCheckState(node);
    }
  }

  /// Builds the appropriate checkbox icon based on the node's selection state
  /// and whether the tree is in single-select or multi-select mode.
  Icon _buildCheckBoxIcon(TreeNode node) {
    if (_treeController.isSingleSelect) {
      // Single-select mode: radio button like behavior
      bool isSelected = _treeController.currentSelectId == node.id;
      return Icon(
        isSelected ? Icons.check_box : Icons.check_box_outline_blank,
        color: isSelected ? Color(0X990000FF) : Color(0XFFCCCCCC), // TODO: Use theme colors
        key: ValueKey("icon_single_${node.id}_$isSelected"), // Key for efficient updates
      );
    } else {
      // Multi-select mode: checkbox behavior
      IconData iconData;
      switch (node.checkState) {
        case NodeCheckState.unchecked:
          iconData = Icons.check_box_outline_blank;
          break;
        case NodeCheckState.partial:
          iconData = Icons.indeterminate_check_box;
          break;
        case NodeCheckState.checked:
          iconData = Icons.check_box;
          break;
      }
      return Icon(
        iconData,
        color: node.checkState == NodeCheckState.unchecked 
               ? Color(0XFFCCCCCC) // TODO: Use theme colors
               : Color(0X990000FF), // TODO: Use theme colors
        key: ValueKey("icon_multi_${node.id}_${node.checkState}"), // Key for efficient updates
      );
    }
  }

  /// Builds the widget for a single tree node (parent level in its own subtree).
  /// This includes the row for the node itself and, if expanded, its children.
  Widget _buildTreeParent(TreeNode node) {
    return Column(
      children: [
        InkWell(
          onTap: () => _onOpenNode(node), // Tap to expand/collapse
          child: Container(
            width: MediaQuery.of(context).size.width, // Full width
            padding: const EdgeInsets.only(left: 20, top: 15, right: 20),
            child: Column(
              children: [
                // Row for the node's content (icon, checkbox, label)
                Row(
                  textDirection: widget.isRTL ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    // Expansion icon (if node has children)
                    node.children.isNotEmpty
                        ? Icon(
                            node.isOpen
                                ? Icons.keyboard_arrow_down_rounded
                                : (widget.isRTL
                                    ? Icons.keyboard_arrow_left_rounded
                                    : Icons.keyboard_arrow_right_rounded),
                            size: 20,
                          )
                        : SizedBox(width: widget.isRTL ? 30 : 20), // Placeholder for alignment
                    const SizedBox(width: 5),
                    // Checkbox
                    GestureDetector(
                      onTap: () => _onSelectCheckBox(node), // Tap to select/deselect
                      child: _buildCheckBoxIcon(node),
                    ),
                    const SizedBox(width: 5),
                    // Node label
                    Expanded(
                      child: Text(
                        node.label,
                        textAlign: widget.isRTL ? TextAlign.end : TextAlign.start,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                // Children nodes (if expanded and present)
                if (node.isOpen && node.children.isNotEmpty)
                  Padding(
                    // Indentation for children
                    padding: widget.isRTL 
                             ? const EdgeInsets.only(right: 20) 
                             : const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
                      children: _buildTreeNodeChildren(node),
                    ),
                  )
                else
                  SizedBox.shrink(), // Render nothing if not expanded or no children
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Recursively builds the list of child widgets for a given [TreeNode].
  List<Widget> _buildTreeNodeChildren(TreeNode data) {
    // Each child is rendered as a "parent" of its own potential subtree.
    return data.children.map((childNode) => _buildTreeParent(childNode)).toList();
  }

  @override
  Widget build(BuildContext context) {
    // The UI is built based on the current list of nodes from the TreeController.
    // A ValueListenableBuilder or Consumer could also be used here if TreeController
    // exposed a ValueListenable for `nodes`, but addListener/setState is also a valid pattern.
    return Container(
      color: Colors.white, // TODO: Make background color configurable via widget params
      child: SingleChildScrollView(
        child: Column(
          // Map each root node in the controller's list to a _buildTreeParent widget.
          children: _treeController.nodes.map((node) => _buildTreeParent(node)).toList(),
        ),
      ),
    );
  }
}
