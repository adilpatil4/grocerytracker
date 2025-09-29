import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/add_item_dialog.dart';
import './widgets/category_section.dart';
import './widgets/shopping_list_header.dart';
import './widgets/smart_suggestions.dart';

class ShoppingList extends StatefulWidget {
  const ShoppingList({Key? key}) : super(key: key);

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  String _listName = 'Weekly Groceries';
  bool _isStoreMode = false;
  bool _isRefreshing = false;

  // Mock shopping list data
  List<Map<String, dynamic>> _shoppingItems = [
    {
      'id': 1,
      'name': 'Organic Bananas',
      'quantity': '2 lbs',
      'estimatedPrice': '\$3.99',
      'category': 'Produce',
      'isCompleted': false,
      'dateAdded': DateTime.now().subtract(Duration(hours: 2)),
    },
    {
      'id': 2,
      'name': 'Whole Milk',
      'quantity': '1 gallon',
      'estimatedPrice': '\$4.29',
      'category': 'Dairy',
      'isCompleted': false,
      'dateAdded': DateTime.now().subtract(Duration(hours: 1)),
    },
    {
      'id': 3,
      'name': 'Ground Beef',
      'quantity': '1 lb',
      'estimatedPrice': '\$6.99',
      'category': 'Meat',
      'isCompleted': true,
      'dateAdded': DateTime.now().subtract(Duration(hours: 3)),
    },
    {
      'id': 4,
      'name': 'Sourdough Bread',
      'quantity': '1 loaf',
      'estimatedPrice': '\$3.49',
      'category': 'Bakery',
      'isCompleted': false,
      'dateAdded': DateTime.now().subtract(Duration(minutes: 30)),
    },
    {
      'id': 5,
      'name': 'Canned Tomatoes',
      'quantity': '2 cans',
      'estimatedPrice': '\$2.98',
      'category': 'Canned Goods',
      'isCompleted': false,
      'dateAdded': DateTime.now().subtract(Duration(minutes: 45)),
    },
    {
      'id': 6,
      'name': 'Orange Juice',
      'quantity': '64 oz',
      'estimatedPrice': '\$4.79',
      'category': 'Beverages',
      'isCompleted': true,
      'dateAdded': DateTime.now().subtract(Duration(hours: 4)),
    },
  ];

  // Mock smart suggestions
  final List<Map<String, dynamic>> _smartSuggestions = [
    {
      'id': 101,
      'name': 'Greek Yogurt',
      'category': 'Dairy',
      'reason': 'Low inventory',
      'estimatedPrice': '\$5.99',
    },
    {
      'id': 102,
      'name': 'Chicken Breast',
      'category': 'Meat',
      'reason': 'Frequently purchased',
      'estimatedPrice': '\$8.99',
    },
    {
      'id': 103,
      'name': 'Spinach',
      'category': 'Produce',
      'reason': 'Recipe ingredient',
      'estimatedPrice': '\$2.49',
    },
    {
      'id': 104,
      'name': 'Pasta',
      'category': 'Canned Goods',
      'reason': 'Running low',
      'estimatedPrice': '\$1.99',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          ShoppingListHeader(
            listName: _listName,
            onShare: _shareList,
            onClearCompleted: _clearCompletedItems,
            onListNameChanged: (newName) {
              setState(() => _listName = newName);
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshList,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildStoreMode(),
                        SmartSuggestions(
                          suggestions: _smartSuggestions,
                          onSuggestionTap: _addSuggestionToList,
                        ),
                        SizedBox(height: 1.h),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      ..._buildCategorySections(),
                      _buildCompletedSection(),
                      SizedBox(height: 10.h), // Space for FAB
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        icon: CustomIconWidget(
          iconName: 'add',
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          size: 6.w,
        ),
        label: Text(
          'Add Item',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildStoreMode() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'store',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'Store Mode',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: _isStoreMode,
            onChanged: (value) {
              setState(() => _isStoreMode = value);
              Fluttertoast.showToast(
                msg: _isStoreMode
                    ? 'Store mode enabled - Optimized for shopping'
                    : 'Store mode disabled',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategorySections() {
    final activeItems = _shoppingItems
        .where((item) => !(item['isCompleted'] as bool? ?? false))
        .toList();
    final groupedItems = <String, List<Map<String, dynamic>>>{};

    // Group items by category
    for (final item in activeItems) {
      final category = item['category'] as String? ?? 'Other';
      groupedItems.putIfAbsent(category, () => []).add(item);
    }

    // Sort categories for store layout optimization
    final sortedCategories = groupedItems.keys.toList()
      ..sort((a, b) {
        const storeOrder = [
          'Produce',
          'Bakery',
          'Dairy',
          'Meat',
          'Frozen',
          'Canned Goods',
          'Beverages',
          'Household',
          'Personal Care',
          'Other'
        ];
        return storeOrder.indexOf(a).compareTo(storeOrder.indexOf(b));
      });

    return sortedCategories.map((category) {
      return CategorySection(
        categoryName: category,
        items: groupedItems[category] ?? [],
        onItemToggle: _toggleItem,
        onItemEdit: _editItem,
        onItemDelete: _deleteItem,
        onItemRestore: _restoreItem,
      );
    }).toList();
  }

  Widget _buildCompletedSection() {
    final completedItems = _shoppingItems
        .where((item) => item['isCompleted'] as bool? ?? false)
        .toList();

    if (completedItems.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Completed (${completedItems.length})',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        CategorySection(
          categoryName: '',
          items: completedItems,
          onItemToggle: _toggleItem,
          onItemEdit: _editItem,
          onItemDelete: _deleteItem,
          onItemRestore: _restoreItem,
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavButton('Dashboard', 'dashboard', '/main-dashboard'),
            _buildNavButton('Scan', 'qr_code_scanner', '/receipt-scanning'),
            _buildNavButton('Inventory', 'inventory', '/inventory-management'),
            _buildNavButton(
                'Recipes', 'restaurant_menu', '/recipe-recommendations'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(String label, String iconName, String route) {
    final isActive = route == '/shopping-list';

    return GestureDetector(
      onTap: () {
        if (!isActive) {
          Navigator.pushNamed(context, route);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: isActive
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 6.w,
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: isActive
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void _shareList() {
    // Simulate sharing functionality
    Fluttertoast.showToast(
      msg: 'Shopping list shared with family members',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _clearCompletedItems() {
    setState(() {
      _shoppingItems
          .removeWhere((item) => item['isCompleted'] as bool? ?? false);
    });

    Fluttertoast.showToast(
      msg: 'Completed items cleared',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Future<void> _refreshList() async {
    setState(() => _isRefreshing = true);

    // Simulate price updates and availability check
    await Future.delayed(Duration(seconds: 2));

    // Update estimated prices (simulate price changes)
    for (final item in _shoppingItems) {
      if (item['estimatedPrice'] != null) {
        final currentPrice = double.tryParse(
                (item['estimatedPrice'] as String).replaceAll('\$', '')) ??
            0.0;
        final newPrice = currentPrice +
            (currentPrice * 0.05 * (DateTime.now().millisecond % 3 - 1));
        item['estimatedPrice'] = '\$${newPrice.toStringAsFixed(2)}';
      }
    }

    setState(() => _isRefreshing = false);

    Fluttertoast.showToast(
      msg: 'Prices updated',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _addSuggestionToList(Map<String, dynamic> suggestion) {
    final newItem = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': suggestion['name'],
      'quantity': '1',
      'estimatedPrice': suggestion['estimatedPrice'],
      'category': suggestion['category'],
      'isCompleted': false,
      'dateAdded': DateTime.now(),
    };

    setState(() {
      _shoppingItems.add(newItem);
    });

    Fluttertoast.showToast(
      msg: '${suggestion['name']} added to list',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(
        onItemAdded: (item) {
          setState(() {
            _shoppingItems.add(item);
          });

          Fluttertoast.showToast(
            msg: '${item['name']} added to list',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        },
      ),
    );
  }

  void _toggleItem(int itemId) {
    setState(() {
      final itemIndex =
          _shoppingItems.indexWhere((item) => item['id'] == itemId);
      if (itemIndex != -1) {
        _shoppingItems[itemIndex]['isCompleted'] =
            !(_shoppingItems[itemIndex]['isCompleted'] as bool? ?? false);
      }
    });
  }

  void _editItem(int itemId) {
    final item = _shoppingItems.firstWhere((item) => item['id'] == itemId);

    showDialog(
      context: context,
      builder: (context) => AddItemDialog(
        onItemAdded: (updatedItem) {
          setState(() {
            final itemIndex =
                _shoppingItems.indexWhere((item) => item['id'] == itemId);
            if (itemIndex != -1) {
              _shoppingItems[itemIndex] = {...updatedItem, 'id': itemId};
            }
          });

          Fluttertoast.showToast(
            msg: '${updatedItem['name']} updated',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        },
      ),
    );
  }

  void _deleteItem(int itemId) {
    final item = _shoppingItems.firstWhere((item) => item['id'] == itemId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _shoppingItems.removeWhere((item) => item['id'] == itemId);
              });
              Navigator.pop(context);

              Fluttertoast.showToast(
                msg: '${item['name']} deleted',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _restoreItem(int itemId) {
    setState(() {
      final itemIndex =
          _shoppingItems.indexWhere((item) => item['id'] == itemId);
      if (itemIndex != -1) {
        _shoppingItems[itemIndex]['isCompleted'] = false;
      }
    });

    Fluttertoast.showToast(
      msg: 'Item restored to shopping list',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}
