import '../models/node_check_state.dart'; // Path will be correct once this file is in lib/src/utils
import '../models/tree_node.dart'; // Path will be correct once this file is in lib/src/utils

// Assuming Config is no longer needed here as TreeNode has fixed properties.
// If Config is still used for initial values from raw data, it might need to be passed.
// For now, we'll assume direct mapping from expected keys in rawData.

/// Provides utility functions for parsing raw data into tree structures.
///
/// This class primarily focuses on converting flat lists or other raw data formats
/// into a structured list of [TreeNode] objects that can be used by the tree widget.
class TreeDataParser {
  // Private constructor to prevent instantiation of this utility class.
  // All methods are static.
  TreeDataParser._();

  /// Converts a flat list of raw map data into a tree structure of [TreeNode] objects.
  ///
  /// Each map in [rawDataList] is expected to have at least 'id', 'parentId', and 'label' keys.
  /// Other optional keys like 'isOpen', 'checkState', and 'extraData' can be used.
  static List<TreeNode> convertRawDataListToTreeNodes(
      List<Map<String, dynamic>> rawDataList,
      {bool initiallyExpanded = false}) { // Added for flexibility
    if (rawDataList.isEmpty) {
      return [];
    }

    Map<String, TreeNode> nodeMap = {};
    List<TreeNode> roots = [];

    // First pass: create TreeNode objects for each item and store them in a map.
    // Children lists are not populated yet.
    for (var rawNodeData in rawDataList) {
      final String id = rawNodeData['id']?.toString() ?? '';
      final String parentId = rawNodeData['parentId']?.toString() ?? '0'; // '0' for root
      final String label = rawNodeData['label']?.toString() ?? 'Untitled';
      final bool isOpen = rawNodeData['isOpen'] as bool? ?? initiallyExpanded;
      // extraData can be more flexible, here we just pass it as is.
      final Map<String, dynamic>? extraData =
          rawNodeData['extraData'] as Map<String, dynamic>?;
      
      // Initial checkState can also be derived from rawNodeData if needed
      // For now, it defaults to NodeCheckState.unchecked in TreeNode constructor.

      if (id.isEmpty) {
        // Skip nodes with empty IDs or log a warning
        print("Warning: Skipping raw node data with empty ID: $rawNodeData");
        continue;
      }
      
      nodeMap[id] = TreeNode(
        id: id,
        parentId: parentId,
        label: label,
        isOpen: isOpen,
        // checkState will default to unchecked
        extraData: extraData,
        children: [], // Initialize with empty list, to be populated in the next step
      );
    }

    // Second pass: populate the children lists and identify root nodes.
    nodeMap.forEach((id, node) {
      if (node.parentId == '0' || !nodeMap.containsKey(node.parentId)) {
        roots.add(node);
      } else {
        final parentNode = nodeMap[node.parentId];
        if (parentNode != null) {
          // To ensure children are added to the list within the TreeNode instance in nodeMap
          // we need to be careful if TreeNode is immutable regarding its children list.
          // The current TreeNode.children is final, but initialized with a mutable list.
          // So, this direct add should work.
          parentNode.children.add(node);
        }
      }
    });

    // Sort children for consistent order if necessary (optional)
    // roots.forEach((node) => _sortChildrenRecursive(node));

    return roots;
  }

  // Helper for sorting, if needed
  // static void _sortChildrenRecursive(TreeNode node) {
  //   if (node.children.isNotEmpty) {
  //     node.children.sort((a, b) => a.label.compareTo(b.label)); // Example sort by label
  //     node.children.forEach(_sortChildrenRecursive);
  //   }
  // }


  /// This function is deprecated as its original purpose of converting a list to a
  /// specific map structure for tree representation is better handled by
  /// [convertRawDataListToTreeNodes] which returns a structured list of [TreeNode]s.
  /// The original implementation also mutated the input list's elements, which is not ideal.
  @Deprecated('Use convertRawDataListToTreeNodes instead. This function may be removed in a future version.')
  static Map<String, dynamic> transformListToMap(List dataList, dynamic /*Config*/ config_unused) {
    // The original function's logic was complex and specific to a map-based tree.
    // Replicating it exactly for TreeNode might not be useful.
    // If a flat map of ID to TreeNode is needed, it can be built from the result of
    // convertRawDataListToTreeNodes.
    print("Warning: transformListToMap is deprecated and its behavior with TreeNode is not fully supported.");
    return {}; // Return empty map or throw UnimplementedError
  }

  /// The `expandMap` function's original implementation (returning `{"aaa": ""}`) was a placeholder or bug.
  /// Its presumed purpose was to recursively traverse a tree of `Map<String, dynamic>`
  /// and set initial states like 'open' and 'checked'.
  ///
  /// With the `TreeNode` class, initial states (`isOpen`, `checkState`) can be set
  /// during node creation (as seen in `convertRawDataListToTreeNodes` which uses `initiallyExpanded`)
  /// or by using the `copyWith` method on `TreeNode` instances.
  ///
  /// A dedicated recursive function to update states on a `List<TreeNode>` could look like this:
  ///
  /// ```dart
  /// static List<TreeNode> setInitialNodeStates(List<TreeNode> nodes, bool expandAll, NodeCheckState initialCheckState) {
  ///   List<TreeNode> updatedNodes = [];
  ///   for (var node in nodes) {
  ///     updatedNodes.add(
  ///       node.copyWith(
  ///         isOpen: expandAll,
  ///         checkState: initialCheckState, // Or more complex logic
  ///         children: setInitialNodeStates(node.children, expandAll, initialCheckState),
  ///       )
  ///     );
  ///   }
  ///   return updatedNodes;
  /// }
  /// ```
  /// This kind of utility might be better placed in a 'TreeLogic' or 'TreeController' class
  /// that manages the tree state, rather than in `DataUtil` which is for raw data conversion.
  ///
  /// For now, `expandMap` is removed due to its previous non-functional state and because
  /// its responsibilities are better handled elsewhere with the new `TreeNode` model.
  //
  // (Original expandMap and commented factoryTreeData are removed)
}
