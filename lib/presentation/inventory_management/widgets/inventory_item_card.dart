import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class InventoryItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  final VoidCallback onMove;
  final VoidCallback onAddToList;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final bool isSelected;

  const InventoryItemCard({
    Key? key,
    required this.item,
    required this.onEdit,
    required this.onMove,
    required this.onAddToList,
    required this.onDelete,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  Color _getExpirationColor(DateTime expirationDate) {
    final now = DateTime.now();
    final daysUntilExpiration = expirationDate.difference(now).inDays;

    if (daysUntilExpiration <= 0) {
      return AppTheme.lightTheme.colorScheme.error;
    } else if (daysUntilExpiration <= 3) {
      return AppTheme.lightTheme.colorScheme.tertiary;
    } else if (daysUntilExpiration <= 7) {
      return AppTheme.lightTheme.colorScheme.tertiaryContainer;
    } else {
      return AppTheme.lightTheme.primaryColor;
    }
  }

  String _getExpirationText(DateTime expirationDate) {
    final now = DateTime.now();
    final daysUntilExpiration = expirationDate.difference(now).inDays;

    if (daysUntilExpiration < 0) {
      return 'Expired ${(-daysUntilExpiration)} days ago';
    } else if (daysUntilExpiration == 0) {
      return 'Expires today';
    } else if (daysUntilExpiration == 1) {
      return 'Expires tomorrow';
    } else {
      return 'Expires in $daysUntilExpiration days';
    }
  }

  @override
  Widget build(BuildContext context) {
    final expirationDate = DateTime.parse(item['expirationDate'] as String);
    final expirationColor = _getExpirationColor(expirationDate);
    final expirationText = _getExpirationText(expirationDate);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(item['id']),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: AppTheme.lightTheme.primaryColor,
              foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
              icon: Icons.edit,
              label: 'Edit',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onMove(),
              backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              foregroundColor: AppTheme.lightTheme.colorScheme.onSecondary,
              icon: Icons.move_up,
              label: 'Move',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onAddToList(),
              backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
              foregroundColor: AppTheme.lightTheme.colorScheme.onTertiary,
              icon: Icons.shopping_cart,
              label: 'Add to List',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
              foregroundColor: AppTheme.lightTheme.colorScheme.onError,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
                  : AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.dividerColor,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomImageWidget(
                    imageUrl: item['image'] as String,
                    width: 15.w,
                    height: 15.w,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'inventory',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Qty: ${item['quantity']}',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          CustomIconWidget(
                            iconName: 'category',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: Text(
                              item['category'] as String,
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          Container(
                            width: 3.w,
                            height: 3.w,
                            decoration: BoxDecoration(
                              color: expirationColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              expirationText,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: expirationColor,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
