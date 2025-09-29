import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/add_item_bottom_sheet.dart';
import './widgets/bulk_actions_toolbar.dart';
import './widgets/category_section.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_modal.dart';
import './widgets/inventory_search_bar.dart';
import './widgets/storage_location_tabs.dart';

class InventoryManagement extends StatefulWidget {
  const InventoryManagement({Key? key}) : super(key: key);

  @override
  State<InventoryManagement> createState() => _InventoryManagementState();
}

class _InventoryManagementState extends State<InventoryManagement>
    with TickerProviderStateMixin {
  int _selectedLocationIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isMultiSelectMode = false;
  Set<String> _selectedItems = {};
  Map<String, dynamic> _filters = {
    'expirationStatus': <String>[],
    'categories': <String>[],
    'storageLocations': <String>[],
  };

  // Mock data for inventory items
  final List<Map<String, dynamic>> _inventoryItems = [
    {
      'id': 1,
      'name': 'Fresh Spinach',
      'quantity': '2 bunches',
      'category': 'Produce',
      'location': 'Fridge',
      'expirationDate': '2025-10-02T00:00:00.000Z',
      'image':
          'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400&h=400&fit=crop',
    },
    {
      'id': 2,
      'name': 'Organic Milk',
      'quantity': '1 gallon',
      'category': 'Dairy',
      'location': 'Fridge',
      'expirationDate': '2025-10-05T00:00:00.000Z',
      'image':
          'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop',
    },
    {
      'id': 3,
      'name': 'Ground Beef',
      'quantity': '1 lb',
      'category': 'Meat',
      'location': 'Fridge',
      'expirationDate': '2025-09-30T00:00:00.000Z',
      'image':
          'https://images.unsplash.com/photo-1588347818111-c4b6d5d4b5e5?w=400&h=400&fit=crop',
    },
    {
      'id': 4,
      'name': 'Frozen Berries',
      'quantity': '2 bags',
      'category': 'Frozen',
      'location': 'Freezer',
      'expirationDate': '2026-03-15T00:00:00.000Z',
      'image':
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=400&fit=crop',
    },
    {
      'id': 5,
      'name': 'Ice Cream',
      'quantity': '1 pint',
      'category': 'Frozen',
      'location': 'Freezer',
      'expirationDate': '2025-12-01T00:00:00.000Z',
      'image':
          'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=400&h=400&fit=crop',
    },
    {
      'id': 6,
      'name': 'Canned Tomatoes',
      'quantity': '3 cans',
      'category': 'Canned Goods',
      'location': 'Pantry',
      'expirationDate': '2026-08-20T00:00:00.000Z',
      'image':
          'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
    },
    {
      'id': 7,
      'name': 'Pasta',
      'quantity': '2 boxes',
      'category': 'Canned Goods',
      'location': 'Pantry',
      'expirationDate': '2026-05-10T00:00:00.000Z',
      'image':
          'https://images.unsplash.com/photo-1551462147-37cbd8ab5b34?w=400&h=400&fit=crop',
    },
    {
      'id': 8,
      'name': 'Orange Juice',
      'quantity': '1 bottle',
      'category': 'Beverages',
      'location': 'Fridge',
      'expirationDate': '2025-10-08T00:00:00.000Z',
      'image':
          'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=400&h=400&fit=crop',
    },
    {
      'id': 9,
      'name': 'Whole Wheat Bread',
      'quantity': '1 loaf',
      'category': 'Bakery',
      'location': 'Pantry',
      'expirationDate': '2025-10-01T00:00:00.000Z',
      'image':
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop',
    },
    {
      'id': 10,
      'name': 'Greek Yogurt',
      'quantity': '4 cups',
      'category': 'Dairy',
      'location': 'Fridge',
      'expirationDate': '2025-10-12T00:00:00.000Z',
      'image':
          'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400&h=400&fit=crop',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _locationNames => ['Fridge', 'Freezer', 'Pantry'];

  String get _currentLocation => _locationNames[_selectedLocationIndex];

  List<Map<String, dynamic>> get _filteredItems {
    var items = _inventoryItems.where((item) {
      // Filter by location
      if (item['location'] != _currentLocation) return false;

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final name = (item['name'] as String).toLowerCase();
        final category = (item['category'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        if (!name.contains(query) && !category.contains(query)) return false;
      }

      // Apply filters
      final expirationFilters = _filters['expirationStatus'] as List<String>;
      if (expirationFilters.isNotEmpty) {
        final expirationDate = DateTime.parse(item['expirationDate'] as String);
        final now = DateTime.now();
        final daysUntilExpiration = expirationDate.difference(now).inDays;

        bool matchesExpiration = false;
        for (String filter in expirationFilters) {
          switch (filter) {
            case 'Fresh':
              if (daysUntilExpiration > 7) matchesExpiration = true;
              break;
            case 'Expiring Soon':
              if (daysUntilExpiration >= 0 && daysUntilExpiration <= 7)
                matchesExpiration = true;
              break;
            case 'Expired':
              if (daysUntilExpiration < 0) matchesExpiration = true;
              break;
          }
        }
        if (!matchesExpiration) return false;
      }

      final categoryFilters = _filters['categories'] as List<String>;
      if (categoryFilters.isNotEmpty &&
          !categoryFilters.contains(item['category'])) {
        return false;
      }

      return true;
    }).toList();

    // Sort by expiration date (closest first)
    items.sort((a, b) {
      final dateA = DateTime.parse(a['expirationDate'] as String);
      final dateB = DateTime.parse(b['expirationDate'] as String);
      return dateA.compareTo(dateB);
    });

    return items;
  }

  Map<String, List<Map<String, dynamic>>> get _groupedItems {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final item in _filteredItems) {
      final category = item['category'] as String;
      grouped.putIfAbsent(category, () => []).add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Inventory Management'),
        leading: GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/main-dashboard'),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ),
        actions: [
          if (_isMultiSelectMode)
            TextButton(
              onPressed: _exitMultiSelectMode,
              child: Text('Cancel'),
            )
          else
            GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, '/recipe-recommendations'),
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'restaurant_menu',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          StorageLocationTabs(
            selectedIndex: _selectedLocationIndex,
            onTabChanged: (index) {
              setState(() {
                _selectedLocationIndex = index;
                _exitMultiSelectMode();
              });
            },
          ),
          InventorySearchBar(
            controller: _searchController,
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            onFilterTap: _showFilterModal,
          ),
          Expanded(
            child: _filteredItems.isEmpty
                ? EmptyStateWidget(
                    location: _currentLocation,
                    onAddItems: _showAddItemBottomSheet,
                  )
                : RefreshIndicator(
                    onRefresh: _refreshInventory,
                    child: ListView(
                      children: _groupedItems.entries.map((entry) {
                        return CategorySection(
                          category: entry.key,
                          items: entry.value,
                          onItemEdit: _editItem,
                          onItemMove: _moveItem,
                          onItemAddToList: _addItemToShoppingList,
                          onItemDelete: _deleteItem,
                          onItemTap: _handleItemTap,
                          selectedItems: _selectedItems,
                        );
                      }).toList(),
                    ),
                  ),
          ),
          if (_isMultiSelectMode && _selectedItems.isNotEmpty)
            BulkActionsToolbar(
              selectedCount: _selectedItems.length,
              onEdit: _bulkEdit,
              onMove: _bulkMove,
              onAddToList: _bulkAddToShoppingList,
              onDelete: _bulkDelete,
              onCancel: _exitMultiSelectMode,
            ),
        ],
      ),
      floatingActionButton: _isMultiSelectMode
          ? null
          : FloatingActionButton(
              onPressed: _showAddItemBottomSheet,
              child: CustomIconWidget(
                iconName: 'add',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 24,
              ),
            ),
      bottomNavigationBar: _isMultiSelectMode
          ? null
          : BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: 2, // Inventory tab
              items: [
                BottomNavigationBarItem(
                  icon: CustomIconWidget(
                      iconName: 'dashboard',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 24),
                  activeIcon: CustomIconWidget(
                      iconName: 'dashboard',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 24),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: CustomIconWidget(
                      iconName: 'receipt',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 24),
                  activeIcon: CustomIconWidget(
                      iconName: 'receipt',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 24),
                  label: 'Scan',
                ),
                BottomNavigationBarItem(
                  icon: CustomIconWidget(
                      iconName: 'inventory',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 24),
                  activeIcon: CustomIconWidget(
                      iconName: 'inventory',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 24),
                  label: 'Inventory',
                ),
                BottomNavigationBarItem(
                  icon: CustomIconWidget(
                      iconName: 'restaurant_menu',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 24),
                  activeIcon: CustomIconWidget(
                      iconName: 'restaurant_menu',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 24),
                  label: 'Recipes',
                ),
                BottomNavigationBarItem(
                  icon: CustomIconWidget(
                      iconName: 'shopping_cart',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 24),
                  activeIcon: CustomIconWidget(
                      iconName: 'shopping_cart',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 24),
                  label: 'Shopping',
                ),
              ],
              onTap: (index) {
                switch (index) {
                  case 0:
                    Navigator.pushNamed(context, '/main-dashboard');
                    break;
                  case 1:
                    Navigator.pushNamed(context, '/receipt-scanning');
                    break;
                  case 2:
                    // Already on inventory page
                    break;
                  case 3:
                    Navigator.pushNamed(context, '/recipe-recommendations');
                    break;
                  case 4:
                    Navigator.pushNamed(context, '/shopping-list');
                    break;
                }
              },
            ),
    );
  }

  Future<void> _refreshInventory() async {
    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would fetch fresh data from the server
    setState(() {
      // Refresh completed
    });

    Fluttertoast.showToast(
      msg: "Inventory refreshed",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(
        currentFilters: _filters,
        onApplyFilters: (filters) {
          setState(() {
            _filters = filters;
          });
        },
      ),
    );
  }

  void _showAddItemBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddItemBottomSheet(
        onAddItem: (item) {
          setState(() {
            _inventoryItems.add(item);
          });
          Fluttertoast.showToast(
            msg: "Item added successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        },
      ),
    );
  }

  void _handleItemTap(Map<String, dynamic> item) {
    if (_isMultiSelectMode) {
      _toggleItemSelection(item);
    } else {
      Navigator.pushNamed(context, '/item-detail');
    }
  }

  void _toggleItemSelection(Map<String, dynamic> item) {
    setState(() {
      final itemId = item['id'].toString();
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
        if (_selectedItems.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedItems.add(itemId);
      }
    });
  }

  void _enterMultiSelectMode(Map<String, dynamic> item) {
    setState(() {
      _isMultiSelectMode = true;
      _selectedItems.add(item['id'].toString());
    });
  }

  void _exitMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = false;
      _selectedItems.clear();
    });
  }

  void _editItem(Map<String, dynamic> item) {
    if (_isMultiSelectMode) {
      _toggleItemSelection(item);
    } else {
      Fluttertoast.showToast(
        msg: "Edit ${item['name']}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _moveItem(Map<String, dynamic> item) {
    if (_isMultiSelectMode) {
      _toggleItemSelection(item);
    } else {
      _showMoveItemDialog(item);
    }
  }

  void _showMoveItemDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Move ${item['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _locationNames
              .where((location) => location != item['location'])
              .map((location) {
            return ListTile(
              title: Text(location),
              onTap: () {
                setState(() {
                  final index =
                      _inventoryItems.indexWhere((i) => i['id'] == item['id']);
                  if (index != -1) {
                    _inventoryItems[index]['location'] = location;
                  }
                });
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: "${item['name']} moved to $location",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _addItemToShoppingList(Map<String, dynamic> item) {
    if (_isMultiSelectMode) {
      _toggleItemSelection(item);
    } else {
      Fluttertoast.showToast(
        msg: "${item['name']} added to shopping list",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _deleteItem(Map<String, dynamic> item) {
    if (_isMultiSelectMode) {
      _toggleItemSelection(item);
    } else {
      _showDeleteConfirmation([item]);
    }
  }

  void _showDeleteConfirmation(List<Map<String, dynamic>> items) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Item${items.length > 1 ? 's' : ''}'),
        content: Text(
          items.length == 1
              ? 'Are you sure you want to delete ${items.first['name']}?'
              : 'Are you sure you want to delete ${items.length} items?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                for (final item in items) {
                  _inventoryItems.removeWhere((i) => i['id'] == item['id']);
                }
              });
              Navigator.pop(context);
              _exitMultiSelectMode();
              Fluttertoast.showToast(
                msg:
                    "${items.length} item${items.length > 1 ? 's' : ''} deleted",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _bulkEdit() {
    Fluttertoast.showToast(
      msg: "Bulk edit ${_selectedItems.length} items",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _bulkMove() {
    final selectedItemsData = _inventoryItems
        .where((item) => _selectedItems.contains(item['id'].toString()))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Move ${_selectedItems.length} Items'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _locationNames.map((location) {
            return ListTile(
              title: Text(location),
              onTap: () {
                setState(() {
                  for (final item in selectedItemsData) {
                    final index = _inventoryItems
                        .indexWhere((i) => i['id'] == item['id']);
                    if (index != -1) {
                      _inventoryItems[index]['location'] = location;
                    }
                  }
                });
                Navigator.pop(context);
                _exitMultiSelectMode();
                Fluttertoast.showToast(
                  msg: "${_selectedItems.length} items moved to $location",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _bulkAddToShoppingList() {
    Fluttertoast.showToast(
      msg: "${_selectedItems.length} items added to shopping list",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
    _exitMultiSelectMode();
  }

  void _bulkDelete() {
    final selectedItemsData = _inventoryItems
        .where((item) => _selectedItems.contains(item['id'].toString()))
        .toList();
    _showDeleteConfirmation(selectedItemsData);
  }
}
