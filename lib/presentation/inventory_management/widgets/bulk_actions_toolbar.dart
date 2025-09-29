import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BulkActionsToolbar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onEdit;
  final VoidCallback onMove;
  final VoidCallback onAddToList;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  const BulkActionsToolbar({
    Key? key,
    required this.selectedCount,
    required this.onEdit,
    required this.onMove,
    required this.onAddToList,
    required this.onDelete,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            GestureDetector(
              onTap: onCancel,
              child: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 24,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                '$selectedCount item${selectedCount != 1 ? 's' : ''} selected',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Row(
              children: [
                _buildActionButton(
                  icon: 'edit',
                  onTap: onEdit,
                ),
                SizedBox(width: 4.w),
                _buildActionButton(
                  icon: 'move_up',
                  onTap: onMove,
                ),
                SizedBox(width: 4.w),
                _buildActionButton(
                  icon: 'shopping_cart',
                  onTap: onAddToList,
                ),
                SizedBox(width: 4.w),
                _buildActionButton(
                  icon: 'delete',
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color:
              AppTheme.lightTheme.colorScheme.onPrimary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          size: 20,
        ),
      ),
    );
  }
}
