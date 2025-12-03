import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentActivityItem extends StatefulWidget {
  final Map<String, dynamic> activity;
  final VoidCallback? onTap;

  const RecentActivityItem({
    Key? key,
    required this.activity,
    this.onTap,
  }) : super(key: key);

  @override
  State<RecentActivityItem> createState() => _RecentActivityItemState();
}

class _RecentActivityItemState extends State<RecentActivityItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Start animation when widget is built
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'scan':
        return Icons.document_scanner_rounded;
      case 'add':
        return Icons.add_circle_outline;
      case 'expire':
        return Icons.warning_amber_rounded;
      case 'update':
        return Icons.edit_outlined;
      case 'remove':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'scan':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'add':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'expire':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'update':
        return Color(0xFF8B5CF6); // Purple
      case 'remove':
        return AppTheme.lightTheme.colorScheme.secondary;
      default:
        return AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  String _formatTimestamp(DateTime timestamp) {
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

  @override
  Widget build(BuildContext context) {
    final String type = (widget.activity['type'] as String?) ?? '';
    final String title = (widget.activity['title'] as String?) ?? 'Activity';
    final String description =
        (widget.activity['description'] as String?) ?? '';
    final DateTime? timestamp = widget.activity['timestamp'] as DateTime?;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _slideAnimation.value)),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTapDown: (_) => _animationController.reverse(),
                onTapUp: (_) {
                  _animationController.forward();
                  widget.onTap?.call();
                },
                onTapCancel: () => _animationController.forward(),
                child: Container(
                  margin: EdgeInsets.only(bottom: 3.w),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getActivityColor(type).withValues(alpha: 0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Activity icon with modern styling
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getActivityColor(type),
                              _getActivityColor(type).withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _getActivityColor(type)
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getActivityIcon(type),
                          color: Colors.white,
                          size: 6.w,
                        ),
                      ),

                      SizedBox(width: 4.w),

                      // Content section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title with premium typography
                            Text(
                              title,
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(height: 0.8.h),

                            // Description
                            Text(
                              description,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                                fontWeight: FontWeight.w400,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(height: 1.h),

                            // Timestamp with styling
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'access_time',
                                  size: 3.5.w,
                                  color: _getActivityColor(type)
                                      .withValues(alpha: 0.7),
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  timestamp != null
                                      ? _formatTimestamp(timestamp)
                                      : 'Unknown time',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: _getActivityColor(type)
                                        .withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Arrow indicator
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: _getActivityColor(type).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: 'arrow_forward_ios',
                          size: 4.w,
                          color: _getActivityColor(type),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
