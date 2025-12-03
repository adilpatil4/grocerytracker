import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExpiringItemsCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onTap;

  const ExpiringItemsCard({
    Key? key,
    required this.item,
    this.onTap,
  }) : super(key: key);

  @override
  State<ExpiringItemsCard> createState() => _ExpiringItemsCardState();
}

class _ExpiringItemsCardState extends State<ExpiringItemsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getStatusColor(int daysRemaining) {
    if (daysRemaining < 0) return AppTheme.lightTheme.colorScheme.error;
    if (daysRemaining == 0) return Color(0xFFFF6B35); // Urgent orange
    if (daysRemaining <= 1) return AppTheme.lightTheme.colorScheme.tertiary;
    if (daysRemaining <= 3) return Color(0xFFFBBF24); // Warning yellow
    return AppTheme.lightTheme.colorScheme.secondary;
  }

  String _getStatusText(int daysRemaining) {
    if (daysRemaining < 0) return 'Expired';
    if (daysRemaining == 0) return 'Expires today';
    if (daysRemaining == 1) return 'Expires tomorrow';
    return 'Expires in $daysRemaining days';
  }

  IconData _getStatusIcon(int daysRemaining) {
    if (daysRemaining < 0) return Icons.error_outline;
    if (daysRemaining == 0) return Icons.warning_amber_rounded;
    if (daysRemaining <= 1) return Icons.schedule;
    return Icons.access_time;
  }

  @override
  Widget build(BuildContext context) {
    final int daysRemaining = (widget.item['daysRemaining'] as int?) ?? 0;
    final String itemName = (widget.item['name'] as String?) ?? 'Unknown Item';
    final String location = (widget.item['location'] as String?) ?? 'Unknown';
    final String category = (widget.item['category'] as String?) ?? 'General';
    final String? imageUrl = widget.item['image'] as String?;

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 70.w,
              margin: EdgeInsets.only(right: 4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color:
                        _getStatusColor(daysRemaining).withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: _getStatusColor(daysRemaining).withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image section with gradient overlay
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Main image
                          Container(
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                              child: imageUrl != null
                                  ? CustomImageWidget(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      child: Center(
                                        child: CustomIconWidget(
                                          iconName: 'image',
                                          size: 12.w,
                                          color: AppTheme
                                              .lightTheme.colorScheme.primary
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ),
                            ),
                          ),

                          // Status badge
                          Positioned(
                            top: 3.w,
                            right: 3.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 1.5.w,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(daysRemaining),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getStatusColor(daysRemaining)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStatusIcon(daysRemaining),
                                    color: Colors.white,
                                    size: 4.w,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    daysRemaining < 0 ? '!' : '$daysRemaining',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Category badge
                          Positioned(
                            top: 3.w,
                            left: 3.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.5.w,
                                vertical: 1.w,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                category,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content section
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Item name
                          Text(
                            itemName,
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          SizedBox(height: 1.h),

                          // Location with icon
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
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 0.5.h),

                          // Status text
                          Text(
                            _getStatusText(daysRemaining),
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: _getStatusColor(daysRemaining),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}