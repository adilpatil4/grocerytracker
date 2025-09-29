import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './inventory_item_card.dart';

class CategorySection extends StatefulWidget {
  final String category;
  final List<Map<String, dynamic>> items;
  final Function(Map<String, dynamic>) onItemEdit;
  final Function(Map<String, dynamic>) onItemMove;
  final Function(Map<String, dynamic>) onItemAddToList;
  final Function(Map<String, dynamic>) onItemDelete;
  final Function(Map<String, dynamic>) onItemTap;
  final Set<String> selectedItems;

  const CategorySection({
    Key? key,
    required this.category,
    required this.items,
    required this.onItemEdit,
    required this.onItemMove,
    required this.onItemAddToList,
    required this.onItemDelete,
    required this.onItemTap,
    required this.selectedItems,
  }) : super(key: key);

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: _getCategoryIcon(widget.category),
                    color: AppTheme.lightTheme.primaryColor,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      widget.category,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.items.length}',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? null : 0,
            child: _isExpanded
                ? Column(
                    children: widget.items.map((item) {
                      return InventoryItemCard(
                        item: item,
                        onEdit: () => widget.onItemEdit(item),
                        onMove: () => widget.onItemMove(item),
                        onAddToList: () => widget.onItemAddToList(item),
                        onDelete: () => widget.onItemDelete(item),
                        onTap: () => widget.onItemTap(item),
                        isSelected: widget.selectedItems
                            .contains(item['id'].toString()),
                      );
                    }).toList(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'produce':
        return 'eco';
      case 'dairy':
        return 'local_drink';
      case 'meat':
        return 'restaurant';
      case 'beverages':
        return 'local_cafe';
      case 'canned goods':
        return 'inventory_2';
      case 'frozen':
        return 'ac_unit';
      case 'bakery':
        return 'cake';
      case 'snacks':
        return 'cookie';
      default:
        return 'category';
    }
  }
}
