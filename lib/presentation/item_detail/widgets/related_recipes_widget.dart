import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class RelatedRecipesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> relatedRecipes;
  final VoidCallback onViewAllRecipes;

  const RelatedRecipesWidget({
    Key? key,
    required this.relatedRecipes,
    required this.onViewAllRecipes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (relatedRecipes.isEmpty) {
      return SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'restaurant_menu',
                  size: 24,
                  color: AppTheme.lightTheme.primaryColor,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Related Recipes',
                    style: AppTheme.lightTheme.textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: onViewAllRecipes,
                  child: Text(
                    'View All',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              height: 25.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:
                    relatedRecipes.length > 3 ? 3 : relatedRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = relatedRecipes[index];
                  return _buildRecipeCard(context, recipe);
                },
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'lightbulb',
                    size: 20,
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'These recipes use this ingredient and can help you use it before it expires.',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.primaryColor,
                      ),
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

  Widget _buildRecipeCard(BuildContext context, Map<String, dynamic> recipe) {
    return Container(
      width: 40.w,
      margin: EdgeInsets.only(right: 3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: CustomImageWidget(
              imageUrl: recipe['image'] as String,
              width: 40.w,
              height: 12.h,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['name'] as String,
                    style: AppTheme.lightTheme.textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        size: 14,
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${recipe['cookTime']} min',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'star',
                        size: 14,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${recipe['rating']}',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to recipe detail
                        Navigator.pushNamed(context, '/recipe-recommendations');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lightTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        'View Recipe',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
