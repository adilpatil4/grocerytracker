import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentActivityItem extends StatelessWidget {
  final Map<String, dynamic> activity;
  final VoidCallback onTap;

  const RecentActivityItem({
    Key? key,
    required this.activity,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String type = (activity['type'] as String?) ?? 'unknown';
    final String title = (activity['title'] as String?) ?? 'Unknown Activity';
    final String description = (activity['description'] as String?) ?? '';
    final DateTime timestamp =
        activity['timestamp'] as DateTime? ?? DateTime.now();
    final String timeAgo = _getTimeAgo(timestamp);

    IconData activityIcon = _getActivityIcon(type);
    Color activityColor = _getActivityColor(type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // Activity icon
            Container(
              padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(
                color: activityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                activityIcon,
                size: 6.w,
                color: activityColor,
              ),
            ),

            SizedBox(width: 4.w),

            // Activity details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description.isNotEmpty) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      description,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 0.5.h),
                  Text(
                    timeAgo,
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            // Arrow icon
            CustomIconWidget(
              iconName: 'chevron_right',
              size: 5.w,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'scan':
        return Icons.document_scanner;
      case 'add':
        return Icons.add_circle;
      case 'update':
        return Icons.edit;
      case 'remove':
        return Icons.remove_circle;
      case 'expire':
        return Icons.warning;
      default:
        return Icons.history;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'scan':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'add':
        return Colors.green;
      case 'update':
        return Colors.blue;
      case 'remove':
        return Colors.red;
      case 'expire':
        return Colors.orange;
      default:
        return AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}
