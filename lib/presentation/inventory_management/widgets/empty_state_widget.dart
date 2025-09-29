import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final String location;
  final VoidCallback onAddItems;

  const EmptyStateWidget({
    Key? key,
    required this.location,
    required this.onAddItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: _getLocationIcon(location),
                color: AppTheme.lightTheme.primaryColor,
                size: 60,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Your $location is empty',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              _getEmptyMessage(location),
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: onAddItems,
              icon: CustomIconWidget(
                iconName: 'add',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 20,
              ),
              label: Text('Add Items'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocationIcon(String location) {
    switch (location.toLowerCase()) {
      case 'fridge':
        return 'kitchen';
      case 'freezer':
        return 'ac_unit';
      case 'pantry':
        return 'inventory_2';
      default:
        return 'inventory';
    }
  }

  String _getEmptyMessage(String location) {
    switch (location.toLowerCase()) {
      case 'fridge':
        return 'Start by scanning receipts or manually adding fresh items to track your refrigerated goods.';
      case 'freezer':
        return 'Add frozen items to keep track of what you have stored for longer periods.';
      case 'pantry':
        return 'Track your dry goods, canned items, and non-perishables to avoid overbuying.';
      default:
        return 'Start adding items to track your inventory and reduce food waste.';
    }
  }
}
