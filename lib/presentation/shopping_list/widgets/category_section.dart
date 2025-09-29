import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import './shopping_list_item.dart';

class CategorySection extends StatelessWidget {
  final String categoryName;
  final List<Map<String, dynamic>> items;
  final Function(int) onItemToggle;
  final Function(int) onItemEdit;
  final Function(int) onItemDelete;
  final Function(int) onItemRestore;

  const CategorySection({
    Key? key,
    required this.categoryName,
    required this.items,
    required this.onItemToggle,
    required this.onItemEdit,
    required this.onItemDelete,
    required this.onItemRestore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Text(
            categoryName,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (context, index) => SizedBox(height: 0.5.h),
          itemBuilder: (context, index) {
            final item = items[index];
            return ShoppingListItem(
              item: item,
              onToggle: () => onItemToggle(item['id'] as int),
              onEdit: () => onItemEdit(item['id'] as int),
              onDelete: () => onItemDelete(item['id'] as int),
              onRestore: () => onItemRestore(item['id'] as int),
            );
          },
        ),
        SizedBox(height: 2.h),
      ],
    );
  }
}
