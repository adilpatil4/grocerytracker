import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExpiringItemsCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const ExpiringItemsCard({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int daysRemaining = (item['daysRemaining'] as int?) ?? 0;
    final String itemName = (item['name'] as String?) ?? 'Unknown Item';
    final String imageUrl = (item['image'] as String?) ?? '';
    final String location = (item['location'] as String?) ?? 'Unknown';

    Color urgencyColor = _getUrgencyColor(daysRemaining);
    String urgencyText = _getUrgencyText(daysRemaining);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70.w,
        margin: EdgeInsets.only(right: 4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: imageUrl.isNotEmpty
                  ? CustomImageWidget(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: 12.h,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      height: 12.h,
                      color: AppTheme.lightTheme.colorScheme.surface
                          .withValues(alpha: 0.3),
                      child: CustomIconWidget(
                        iconName: 'image',
                        size: 8.w,
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
            ),

            // Content section
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item name
                  Text(
                    itemName,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 1.h),

                  // Location
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'location_on',
                        size: 4.w,
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          location,
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 1.5.h),

                  // Urgency indicator
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: urgencyColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: urgencyColor, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: daysRemaining < 0 ? 'warning' : 'schedule',
                          size: 4.w,
                          color: urgencyColor,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          urgencyText,
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: urgencyColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getUrgencyColor(int daysRemaining) {
    if (daysRemaining < 0) {
      return AppTheme.lightTheme.colorScheme.error;
    } else if (daysRemaining <= 3) {
      return Colors.orange;
    } else {
      return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _getUrgencyText(int daysRemaining) {
    if (daysRemaining < 0) {
      return 'Expired';
    } else if (daysRemaining == 0) {
      return 'Expires today';
    } else if (daysRemaining == 1) {
      return '1 day left';
    } else {
      return '$daysRemaining days left';
    }
  }
}
