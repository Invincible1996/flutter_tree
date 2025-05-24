import 'dart:async';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import '../models/tree_node.dart';
import '../models/node_check_state.dart';
import '../utils/tree_data_parser.dart'; // Adjusted path and name
import '../utils/m_stack_util.dart'; // Added for MStack
import '../widgets/flutter_tree_widget.dart'; // Assuming Config and DataType are here post-move.

// To avoid circular dependency, Config and DataType should ideally be in their own file (e.g. lib/src/core_definitions.dart)
// For now, we'll assume they are accessible. If not, this import needs to be addressed.
// Consider moving Config and DataType to their own files in lib/src/models or lib/src/core.

/// Manages the state and business logic for the tree view.
///
/// This controller handles data initialization, node manipulation (expansion, selection),
/// and state propagation (updating parent/child check states). It uses [ChangeNotifier]
/// to inform listening widgets (like `_FlutterTreeProState`) about state changes.
class TreeController extends ChangeNotifier {
  /// The root list of [TreeNode] objects currently displayed in the tree.
  List<TreeNode> _nodes = [];

  /// A map for quick lookup of any [TreeNode] by its ID.
  /// This map is kept synchronized with the nodes in the `_nodes` list and their descendants.
  Map<String, TreeNode> _nodeMap = {};

  /// The ID of the currently selected node in single-select mode. `null` if no node is selected.
  String? _currentSelectId;

  // Configuration and initial data passed from the FlutterTreePro widget.
  // These are stored to allow for re-initialization or specific behaviors.
  final List<Map<String, dynamic>> _initialRawTreeData;
  final List<Map<String, dynamic>> _initialRawListData;
  final List<Map<String, dynamic>> _initialCheckedRawItems;
  final Config _config;
  final bool _initiallyExpanded;
  final bool _isSingleSelect;
  final String? _initialSelectValueWidget;

  /// Callback function invoked when the list of checked nodes changes and should be reported.
  /// This is typically passed from `_FlutterTreeProState` to handle debouncing and
  /// ultimately call the `widget.onChecked` callback.
  final Function(List<TreeNode> checkedNodes) _onCheckedNodesUpdate;

  /// Creates a [TreeController].
  ///
  /// Parameters:
  ///   [initialTreeData]: Raw data if type is [DataType.DataMap].
  ///   [initialListData]: Raw data if type is [DataType.DataList].
  ///   [initialCheckedRawItems]: List of raw items to be initially checked.
  ///   [config]: Configuration for data parsing and behavior.
  ///   [initiallyExpanded]: Whether nodes should be expanded by default.
  ///   [isSingleSelect]: Whether the tree is in single-selection mode.
  ///   [initialSelectValue]: The ID of the node to be initially selected in single-select mode.
  ///   [onCheckedNodesUpdate]: Callback to inform the UI layer about changes in checked nodes.
  TreeController({
    required List<Map<String, dynamic>> initialTreeData,
    required List<Map<String, dynamic>> initialListData,
    required List<Map<String, dynamic>> initialCheckedRawItems,
    required Config config,
    required bool initiallyExpanded,
    required bool isSingleSelect,
    required String? initialSelectValue,
    required Function(List<TreeNode> checkedNodes) onCheckedNodesUpdate,
  })  : _initialRawTreeData = initialTreeData,
        _initialRawListData = initialListData,
        _initialCheckedRawItems = initialCheckedRawItems,
        _config = config,
        _initiallyExpanded = initiallyExpanded,
        _isSingleSelect = isSingleSelect,
        _initialSelectValueWidget = initialSelectValue,
        _onCheckedNodesUpdate = onCheckedNodesUpdate {
    _currentSelectId = _initialSelectValueWidget;
    _initializeTreeData();
  }

  // Public getters for accessing tree state.

  /// Returns the current list of root [TreeNode]s.
  List<TreeNode> get nodes => _nodes;

  /// Returns the ID of the currently selected node in single-select mode, or `null`.
  String? get currentSelectId => _currentSelectId;

  /// Returns the [TreeNode] with the given [id], or `null` if not found.
  TreeNode? getNodeById(String id) => _nodeMap[id];

  /// Returns `true` if the tree is in single-selection mode.
  bool get isSingleSelect => _isSingleSelect;

  /// Initializes the tree data by parsing raw data, building the node map,
  /// applying initial checked/selected states, and notifying listeners.
  void _initializeTreeData() {
    List<TreeNode> initialNodes;
    if (_config.dataType == DataType.DataList) {
      // Convert flat list to tree nodes.
      initialNodes = TreeDataParser.convertRawDataListToTreeNodes(
        _initialRawListData,
        initiallyExpanded: _initiallyExpanded,
      );
    } else { // DataType.DataMap
      // Convert hierarchically structured map data to tree nodes.
      initialNodes = _convertMapDataToTreeNodesRecursive(
        _initialRawTreeData,
        "0", // Root nodes have parentId "0"
        isExpanded: _initiallyExpanded,
        config: _config,
      );
    }

    _nodeMap = {}; // Reset the node map.
    _buildTreeNodeMapRecursive(initialNodes, _nodeMap); // Populate map with initial nodes.

    List<TreeNode> processedNodes = initialNodes;
    // Apply initial checked states for multi-select mode.
    if (_initialCheckedRawItems.isNotEmpty && !_isSingleSelect) {
      List<String> initialCheckedIds = _initialCheckedRawItems
          .map((item) => item[_config.idKey]?.toString()) // Get IDs from raw data.
          .where((id) => id != null)
          .cast<String>()
          .toList();
      processedNodes = _setInitialCheckedStates(processedNodes, initialCheckedIds);
    }
    
    // Ensure initially selected node (in single-select) is expanded.
    if (_isSingleSelect && _currentSelectId != null) {
        TreeNode? selectedNode = _nodeMap[_currentSelectId!];
        if (selectedNode != null && !selectedNode.isOpen) {
             // Update the node list to reflect the change in isOpen state.
             processedNodes = _updateNodeOpenStateRecursive(processedNodes, _currentSelectId!, true);
        }
    }

    _nodes = processedNodes; // Set the main list of nodes.
    _nodeMap.clear(); // Clear and rebuild the map to ensure it reflects all changes from initialization.
    _buildTreeNodeMapRecursive(_nodes, _nodeMap);
    
    notifyListeners(); // Notify UI to rebuild.
  }
  
  /// Recursively updates the `isOpen` state of a target node and its representation in the `_nodeMap`.
  /// Returns the updated list of nodes at the current recursion level.
  List<TreeNode> _updateNodeOpenStateRecursive(List<TreeNode> nodeList, String targetId, bool isOpen) {
    return nodeList.map((node) {
      TreeNode updatedNode = node;
      if (node.id == targetId) {
        // Target node found, create a new instance with updated isOpen state.
        updatedNode = node.copyWith(isOpen: isOpen);
      } else if (node.children.isNotEmpty && _isDescendant(node, targetId)) {
        // Target node is a descendant, recurse on children.
        updatedNode = node.copyWith(children: _updateNodeOpenStateRecursive(node.children, targetId, isOpen));
      }
      // Update the map with the new node instance (even if unchanged, to ensure map consistency if children changed).
      _nodeMap[updatedNode.id] = updatedNode;
      return updatedNode;
    }).toList();
  }

  /// Sets the initial checked states for nodes based on a list of [checkedIds].
  /// This involves updating nodes and their descendants, then recalculating parent states.
  List<TreeNode> _setInitialCheckedStates(List<TreeNode> nodes, List<String> checkedIds) {
    List<TreeNode> result = [];
    for (var node in nodes) {
      NodeCheckState newCheckState = node.checkState;
      List<TreeNode> children = node.children;

      if (checkedIds.contains(node.id)) {
        newCheckState = NodeCheckState.checked;
        // If a node is explicitly in initialCheckedIds, mark it and its descendants as checked.
        children = _setDescendantsCheckStateRecursive(node.children, newCheckState);
      } else if (children.isNotEmpty) {
         // If node itself is not in checkedIds, check its children.
         children = _setInitialCheckedStates(children, checkedIds);
      }
      
      var updatedNode = node.copyWith(checkState: newCheckState, children: children);
      _nodeMap[updatedNode.id] = updatedNode; // Update map with the potentially new node instance.
      result.add(updatedNode);
    }
    // After processing all nodes and their direct children, update all parent states from bottom up.
    return _updateAllParentStatesFromMap(result);
  }
  
  /// Recursively sets the [NodeCheckState] for a list of [nodes] and all their descendants.
  /// Updates `_nodeMap` with the new [TreeNode] instances.
  List<TreeNode> _setDescendantsCheckStateRecursive(List<TreeNode> nodes, NodeCheckState state) {
    return nodes.map((node) {
      var children = _setDescendantsCheckStateRecursive(node.children, state);
      var updatedNode = node.copyWith(checkState: state, children: children);
      _nodeMap[updatedNode.id] = updatedNode; // Store the new immutable node in the map.
      return updatedNode;
    }).toList();
  }

  /// Recursively converts a list of raw map data (assumed to be hierarchically structured)
  /// into a list of [TreeNode] objects.
  List<TreeNode> _convertMapDataToTreeNodesRecursive(
      List<Map<String, dynamic>> mapDataList, String parentId, {required bool isExpanded, required Config config}) {
    List<TreeNode> treeNodes = [];
    for (var mapData in mapDataList) {
      // Extract data using keys from Config, providing fallbacks for safety.
      String id = mapData[config.idKey]?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString();
      String label = mapData[config.labelKey]?.toString() ?? 'Untitled';
      List<Map<String, dynamic>> childrenMap = List<Map<String, dynamic>>.from(mapData[config.childrenKey] ?? []);
      
      // Recursively convert children.
      List<TreeNode> children = _convertMapDataToTreeNodesRecursive(childrenMap, id, isExpanded: isExpanded, config: config);
      
      TreeNode node = TreeNode(
        id: id,
        parentId: parentId,
        label: label,
        isOpen: isExpanded, // Initial expansion state.
        children: children,
        extraData: mapData['extraData'] as Map<String, dynamic>?, // Preserve any extra data.
      );
      treeNodes.add(node);
    }
    return treeNodes;
  }

  /// Recursively populates the `_nodeMap` with all nodes in the tree.
  void _buildTreeNodeMapRecursive(List<TreeNode> nodes, Map<String, TreeNode> map) {
    for (var node in nodes) {
      map[node.id] = node;
      if (node.children.isNotEmpty) {
        _buildTreeNodeMapRecursive(node.children, map);
      }
    }
  }
  
  /// Checks if a node with `nodeId` is a descendant of the given `parent` node.
  bool _isDescendant(TreeNode parent, String nodeId) {
    TreeNode? currentNode = _nodeMap[nodeId]; // Start with the node to check.
    while(currentNode != null) {
        if(currentNode.parentId == parent.id) return true; // Found parent in the chain.
        // Stop if root is reached or parentId is missing (should not happen in a consistent tree).
        if(currentNode.parentId == '0' || currentNode.parentId.isEmpty) return false; 
        currentNode = _nodeMap[currentNode.parentId]; // Move to the parent.
         // This check was redundant as parentId check is more direct.
         // if (currentNode == parent) return true; 
    }
    return false; // Not a descendant.
  }

  // --- Public methods for UI interaction ---

  /// Toggles the expansion state ([isOpen]) of the given [node].
  /// If the node has no children, this method does nothing.
  /// Notifies listeners after updating the state.
  void toggleNodeExpansion(TreeNode node) {
    if (node.children.isEmpty) return; // Cannot expand/collapse nodes without children.
    
    var updatedNode = node.copyWith(isOpen: !node.isOpen);
    // Update the node in the primary list structure and the map.
    _nodes = _updateNodeInPrimaryList(updatedNode); 
    _nodeMap[updatedNode.id] = updatedNode; // Ensure map is also updated with the exact instance from _nodes.
                                          // _updateNodeInPrimaryList should ensure this if it updates map.
                                          // For safety, explicitly update here too.
    notifyListeners();
  }

  /// Selects the given [node] in single-selection mode.
  /// Updates `_currentSelectId` and notifies listeners.
  /// Also triggers the `_onCheckedNodesUpdate` callback with the selected node.
  void selectNodeSingle(TreeNode node) {
    if (!_isSingleSelect) return; // Should only be called in single-select mode.
    _currentSelectId = node.id;
    _onCheckedNodesUpdate([node]); // Report the single selected node.
    notifyListeners();
  }

  /// Toggles the check state of the given [node] in multi-selection mode.
  /// This involves updating the node itself, its descendants, and its ancestors' check states.
  /// Notifies listeners and triggers `_onCheckedNodesUpdate` after updates.
  void toggleNodeCheckState(TreeNode node) {
    if (_isSingleSelect) return; // Should only be called in multi-select mode.

    // Determine the new check state for the node and its descendants.
    NodeCheckState newCheckState = (node.checkState == NodeCheckState.unchecked || node.checkState == NodeCheckState.partial)
        ? NodeCheckState.checked
        : NodeCheckState.unchecked;

    // Update the node and its descendants with the new check state.
    // This returns a new TreeNode instance representing the root of the modified subtree.
    var baseUpdatedNode = _setDescendantsCheckStateRecursiveForToggle(node, newCheckState);
    
    // Replace the old subtree with the new one in the main `_nodes` list.
    _nodes = _updateNodeInPrimaryList(baseUpdatedNode); 
    
    // Recalculate and update the check states of all parent nodes.
    _nodes = _updateAllParentStatesFromMap(_nodes, changedNodeId: baseUpdatedNode.id);
    
    _onCheckedNodesUpdate(getCheckedNodesForCallback()); // Report all currently checked nodes.
    notifyListeners();
  }
  
  /// Recursively sets the check state for a node and all its descendants.
  /// Used during the toggle operation. Ensures `_nodeMap` is updated with new instances.
  TreeNode _setDescendantsCheckStateRecursiveForToggle(TreeNode node, NodeCheckState state) {
    List<TreeNode> updatedChildren = [];
    for (var child in node.children) {
      updatedChildren.add(_setDescendantsCheckStateRecursiveForToggle(child, state));
    }
    var newNode = node.copyWith(checkState: state, children: updatedChildren);
    _nodeMap[newNode.id] = newNode; // Critical: update map with the new immutable instance.
    return newNode;
  }

  /// Replaces a `targetNode` within the tree structure (`_nodes` or its nested children lists)
  /// with its new instance. This is essential for maintaining immutability.
  /// Returns the modified list at the current recursion level.
  List<TreeNode> _updateNodeInPrimaryList(TreeNode targetNode, {List<TreeNode>? currentLevelNodes}) {
    currentLevelNodes ??= _nodes; // Start with root nodes if no specific level provided.
    return currentLevelNodes.map((node) {
      if (node.id == targetNode.id) {
        _nodeMap[targetNode.id] = targetNode; // Ensure map has this exact instance.
        return targetNode; // Node found, replace it.
      }
      // If the target node is a descendant of the current node, recurse.
      if (node.children.isNotEmpty && _isDescendant(node, targetNode.id)) {
         var updatedNode = node.copyWith(children: _updateNodeInPrimaryList(targetNode, currentLevelNodes: node.children));
         _nodeMap[updatedNode.id] = updatedNode; // Parent's children list changed, so parent is new.
         return updatedNode;
      }
      return node; // Node is not the target and not an ancestor, return as is.
    }).toList();
  }
  
  /// Recalculates and updates the check state of all parent nodes in the tree.
  /// This is typically called after a child node's check state changes.
  /// The `changedNodeId` can be used for optimization (not fully implemented here).
  List<TreeNode> _updateAllParentStatesFromMap(List<TreeNode> nodeList, {String? changedNodeId}) {
    // This method reconstructs the tree by iterating through nodeList and updating
    // each node based on its children's potentially new states.
    // The _nodeMap is crucial here as it should contain the latest versions of all nodes
    // after any descendant modifications (e.g., from _setDescendantsCheckStateRecursiveForToggle).

    return nodeList.map((node) {
      // Recursively update children first, as parent state depends on children's states.
      List<TreeNode> updatedChildren = _updateAllParentStatesFromMap(node.children, changedNodeId: changedNodeId);
      
      // Calculate the new check state for the current node based on its (potentially updated) children.
      NodeCheckState newParentState = _calculateParentCheckState(node.id, updatedChildren);
      
      var updatedNode = node.copyWith(children: updatedChildren, checkState: newParentState);
      _nodeMap[updatedNode.id] = updatedNode; // Update the map with this new node instance.
      return updatedNode;
    }).toList();
  }

  /// Calculates the check state of a parent node based on the states of its children.
  /// [parentId] is the ID of the parent node whose state is being calculated.
  /// [children] is the list of child nodes (expected to be their latest versions).
  NodeCheckState _calculateParentCheckState(String parentId, List<TreeNode> children) {
    // Retrieve the parent node from the map to ensure we have its most recent state if it was a leaf.
    // However, if it has children, its state is derived solely from them.
    if (children.isEmpty) {
      // If no children, its state is its own (should have been set directly).
      // This typically applies to leaf nodes.
      return _nodeMap[parentId]?.checkState ?? NodeCheckState.unchecked; 
    }

    bool allChildrenChecked = true;
    bool anyChildChecked = false; // Includes partially checked children contributing to parent's partial state.
    bool anyChildPartial = false;

    // Iterate over children to determine aggregated state.
    // It's crucial to use the states from _nodeMap as children list might have stale instances
    // if not carefully managed during recursive updates.
    for (var child in children) {
      // Ensure we use the definitive state from the node map.
      NodeCheckState childState = _nodeMap[child.id]?.checkState ?? child.checkState; 
      
      if (childState != NodeCheckState.checked) {
        allChildrenChecked = false;
      }
      if (childState != NodeCheckState.unchecked) {
        anyChildChecked = true;
      }
      if (childState == NodeCheckState.partial) {
        anyChildPartial = true;
      }
    }

    if (allChildrenChecked) return NodeCheckState.checked; // All children fully checked.
    if (anyChildPartial || anyChildChecked) return NodeCheckState.partial; // Some children checked or partial.
    return NodeCheckState.unchecked; // No children checked or partial.
  }
  
  // Note: The Tuple class was previously defined inside TreeController.
  // It's better practice to define helper classes like Tuple at the top level of the file
  // or in their own utility file if used more broadly.
  // For this refactoring, it's kept as is from the previous step.


  /// Retrieves a list of all nodes that are currently considered "checked".
  /// The exact definition of "checked" (e.g., only leaf nodes, or all nodes with
  /// `checkState == NodeCheckState.checked`) depends on the desired behavior for the callback.
  List<TreeNode> getCheckedNodesForCallback() {
    List<TreeNode> checkedNodes = [];
    // Use MStack for iterative traversal of the current `_nodes` state.
    MStack<TreeNode> stack = MStack<TreeNode>(); 
    _nodes.forEach(stack.push); 

    while (stack.isNotEmpty) { // Use isEmpty or isNotEmpty from MStack
        TreeNode currentNode = stack.pop();
        // Ensure we are referencing the most up-to-date node instance from the map.
        TreeNode latestNodeVersion = _nodeMap[currentNode.id] ?? currentNode;

        // Logic for determining if a node should be included in the callback.
        // Example: include all nodes that are fully checked.
        if (latestNodeVersion.checkState == NodeCheckState.checked) {
            checkedNodes.add(latestNodeVersion);
        }
        
        // Add children to the stack for further processing.
        // Iterate in reverse to process children in a more natural order (optional).
        for (var i = latestNodeVersion.children.length - 1; i >= 0; i--) {
          stack.push(latestNodeVersion.children[i]);
        }
    }
    // TODO: Implement filtering logic if required (e.g., only leaf nodes, 
    // or exclude children if their parent is already in the checkedNodes list).
    // The original `getCheckedItems` had such filtering.
    return checkedNodes;
  }

  /// Placeholder method for updating controller data if the parent widget changes.
  ///
  /// **Note:** The current implementation in `_FlutterTreeProState` opts for
  /// recreating the `TreeController` on significant data changes, which is often
  /// a cleaner approach for managing complex state. This method is kept as a
  /// reference for alternative update strategies but is not actively used by
  /// the `didUpdateWidget` logic in `_FlutterTreeProState` in its current form.
  void updateData({
    required List<Map<String, dynamic>> newTreeData,
    required List<Map<String, dynamic>> newListData,
    required List<Map<String, dynamic>> newInitialCheckedRawItems,
    required Config newConfig,
    required bool newInitiallyExpanded,
    required bool newIsSingleSelect,
    required String? newInitialSelectValue,
  }) {
    // Basic check for data change, can be more sophisticated
    bool needsReInit = false;
    if (_config.dataType != newConfig.dataType) needsReInit = true;
    // Using `identical` for list comparison is a shallow check. Deep comparison would be expensive.
    // Recreating controller on data change is often safer.
    if (!identical(_initialRawTreeData, newTreeData)) needsReInit = true;
    if (!identical(_initialRawListData, newListData)) needsReInit = true;
    
    // Further checks for other parameters...
    if (_initiallyExpanded != newInitiallyExpanded) needsReInit = true;
    if (_isSingleSelect != newIsSingleSelect) needsReInit = true;
    // Etc.

    if (needsReInit) {
      // This method implies the controller is long-lived and its internal data is mutable/re-assignable.
      // However, the fields like _initialRawTreeData are final.
      // This illustrates a conflict with making initial data fields final if direct update is desired.
      // The strategy of recreating the controller in _FlutterTreeProState.didUpdateWidget is
      // generally preferred when initial configuration/data is immutable within the controller.
      print("TreeController: updateData called. Significant changes might require controller recreation for safety if initial fields are final.");
      // If fields were not final, you would update them here:
      // _initialRawTreeData = newTreeData;
      // _initialRawListData = newListData;
      // ... (update other internal fields based on newConfig, newInitialSelectValue etc.)
      // _initializeTreeData(); // Then re-initialize the tree structure.
    } else {
      // Handle minor updates if any (e.g., only initialSelectValue changed without full data reload)
      if (_initialSelectValueWidget != newInitialSelectValue) {
        _currentSelectId = newInitialSelectValue;
        // Potentially open path to new selection if needed.
      }
    }
     notifyListeners(); // Notify even for minor changes if they affect UI.
  }
}

/// Helper class for storing a pair of values (a simple tuple).
/// Used in [_calculateParentCheckState] to associate child IDs with their states,
/// though the direct map lookup was used in the final version of that method.
/// Keeping for reference or potential future use.
class Tuple<T1, T2> {
  /// The first item in the tuple.
  final T1 item1;
  /// The second item in the tuple.
  final T2 item2;

  /// Creates a new tuple with the given items.
  Tuple(this.item1, this.item2);
}
