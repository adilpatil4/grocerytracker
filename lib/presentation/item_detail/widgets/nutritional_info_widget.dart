import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class NutritionalInfoWidget extends StatefulWidget {
  final Map<String, dynamic>? nutritionalInfo;

  const NutritionalInfoWidget({
    Key? key,
    this.nutritionalInfo,
  }) : super(key: key);

  @override
  State<NutritionalInfoWidget> createState() => _NutritionalInfoWidgetState();
}

class _NutritionalInfoWidgetState extends State<NutritionalInfoWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.nutritionalInfo == null || widget.nutritionalInfo!.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'restaurant',
                    size: 24,
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Nutritional Information',
                    style: AppTheme.lightTheme.textTheme.titleMedium,
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    CustomIconWidget(
                      iconName: 'info_outline',
                      size: 32,
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.4),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'No nutritional information available',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'restaurant',
                    size: 24,
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Nutritional Information',
                      style: AppTheme.lightTheme.textTheme.titleMedium,
                    ),
                  ),
                  CustomIconWidget(
                    iconName: _isExpanded ? 'expand_less' : 'expand_more',
                    size: 24,
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),

            // Always show key nutritional facts
            Row(
              children: [
                Expanded(
                  child: _buildNutritionItem(
                    'Calories',
                    '${widget.nutritionalInfo!['calories'] ?? 'N/A'}',
                    'local_fire_department',
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _buildNutritionItem(
                    'Protein',
                    '${widget.nutritionalInfo!['protein'] ?? 'N/A'}g',
                    'fitness_center',
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: _buildNutritionItem(
                    'Carbs',
                    '${widget.nutritionalInfo!['carbs'] ?? 'N/A'}g',
                    'grain',
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _buildNutritionItem(
                    'Fat',
                    '${widget.nutritionalInfo!['fat'] ?? 'N/A'}g',
                    'opacity',
                  ),
                ),
              ],
            ),

            if (_isExpanded) ...[
              SizedBox(height: 2.h),
              Divider(color: AppTheme.lightTheme.colorScheme.outline),
              SizedBox(height: 2.h),
              Text(
                'Detailed Information',
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
              SizedBox(height: 1.h),
              if (widget.nutritionalInfo!['fiber'] != null)
                _buildDetailedNutritionRow(
                    'Fiber', '${widget.nutritionalInfo!['fiber']}g'),
              if (widget.nutritionalInfo!['sugar'] != null)
                _buildDetailedNutritionRow(
                    'Sugar', '${widget.nutritionalInfo!['sugar']}g'),
              if (widget.nutritionalInfo!['sodium'] != null)
                _buildDetailedNutritionRow(
                    'Sodium', '${widget.nutritionalInfo!['sodium']}mg'),
              if (widget.nutritionalInfo!['cholesterol'] != null)
                _buildDetailedNutritionRow('Cholesterol',
                    '${widget.nutritionalInfo!['cholesterol']}mg'),
              if (widget.nutritionalInfo!['vitaminC'] != null)
                _buildDetailedNutritionRow(
                    'Vitamin C', '${widget.nutritionalInfo!['vitaminC']}mg'),
              if (widget.nutritionalInfo!['calcium'] != null)
                _buildDetailedNutritionRow(
                    'Calcium', '${widget.nutritionalInfo!['calcium']}mg'),
              if (widget.nutritionalInfo!['iron'] != null)
                _buildDetailedNutritionRow(
                    'Iron', '${widget.nutritionalInfo!['iron']}mg'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, String iconName) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: iconName,
            size: 20,
            color: AppTheme.lightTheme.primaryColor,
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedNutritionRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
