import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecipeCardWidget extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorited;

  const RecipeCardWidget({
    Key? key,
    required this.recipe,
    this.onTap,
    this.onFavorite,
    this.isFavorited = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String status = recipe['status'] as String? ?? 'missing';
    final int matchPercentage = recipe['matchPercentage'] as int? ?? 0;
    final int cookingTime = recipe['cookingTime'] as int? ?? 0;
    final String name = recipe['name'] as String? ?? 'Unknown Recipe';
    final String imageUrl = recipe['imageUrl'] as String? ?? '';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Image with Status Badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                    child: CustomImageWidget(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: 20.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Status Badge
                  Positioned(
                    top: 2.h,
                    left: 3.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(status),
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Favorite Button
                  Positioned(
                    top: 2.h,
                    right: 3.w,
                    child: GestureDetector(
                      onTap: onFavorite,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: CustomIconWidget(
                          iconName:
                              isFavorited ? 'favorite' : 'favorite_border',
                          color: isFavorited
                              ? Colors.red
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Recipe Details
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recipe Name
                    Text(
                      name,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    // Cooking Time and Match Percentage
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'access_time',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${cookingTime}min',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: _getMatchColor(matchPercentage)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${matchPercentage}% match',
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: _getMatchColor(matchPercentage),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'can_make':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'missing_few':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'can_make':
        return 'Can Make Now';
      case 'missing_few':
        return 'Missing 1-2 items';
      default:
        return 'Missing items';
    }
  }

  Color _getMatchColor(int percentage) {
    if (percentage >= 80) return AppTheme.lightTheme.colorScheme.tertiary;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}
