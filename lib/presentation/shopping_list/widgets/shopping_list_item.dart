import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ShoppingListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRestore;

  const ShoppingListItem({
    Key? key,
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onRestore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = item['isCompleted'] as bool? ?? false;
    final String name = item['name'] as String? ?? '';
    final String quantity = item['quantity'] as String? ?? '';
    final String price = item['estimatedPrice'] as String? ?? '';

    return Dismissible(
      key: Key('item_${item['id']}'),
      direction: DismissDirection.horizontal,
      background: Container(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 4.w),
        child: CustomIconWidget(
          iconName: 'check_circle',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 6.w,
        ),
      ),
      secondaryBackground: Container(
        color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.2),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'edit',
              color: AppTheme.lightTheme.colorScheme.secondary,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: 'delete',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 5.w,
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggle();
          return false;
        } else {
          _showActionSheet(context);
          return false;
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline,
                    width: 2,
                  ),
                  color: isCompleted
                      ? AppTheme.lightTheme.colorScheme.primary
                      : Colors.transparent,
                ),
                child: isCompleted
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        size: 4.w,
                      )
                    : null,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: isCompleted
                          ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          : AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (quantity.isNotEmpty) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      quantity,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (price.isNotEmpty) ...[
              SizedBox(width: 2.w),
              Text(
                price,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isCompleted
                      ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                      : AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              title: Text(
                'Edit Item',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 6.w,
              ),
              title: Text(
                'Delete Item',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            if (item['isCompleted'] == true)
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'restore',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 6.w,
                ),
                title: Text(
                  'Restore Item',
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(context);
                  onRestore();
                },
              ),
          ],
        ),
      ),
    );
  }
}
