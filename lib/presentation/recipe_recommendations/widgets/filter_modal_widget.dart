import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FilterModalWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterModalWidget({
    Key? key,
    required this.currentFilters,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<FilterModalWidget> createState() => _FilterModalWidgetState();
}

class _FilterModalWidgetState extends State<FilterModalWidget> {
  late Map<String, dynamic> _filters;
  double _maxCookingTime = 60;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
    _maxCookingTime = (_filters['maxCookingTime'] as double?) ?? 60.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Recipes',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text('Reset'),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dietary Restrictions
                  _buildSectionTitle('Dietary Restrictions'),
                  SizedBox(height: 1.h),
                  _buildDietaryOptions(),
                  SizedBox(height: 3.h),

                  // Cooking Time
                  _buildSectionTitle('Maximum Cooking Time'),
                  SizedBox(height: 1.h),
                  _buildCookingTimeSlider(),
                  SizedBox(height: 3.h),

                  // Difficulty Level
                  _buildSectionTitle('Difficulty Level'),
                  SizedBox(height: 1.h),
                  _buildDifficultyOptions(),
                ],
              ),
            ),
          ),
          // Apply Button
          Padding(
            padding: EdgeInsets.all(4.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApplyFilters(_filters);
                  Navigator.pop(context);
                },
                child: Text('Apply Filters'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDietaryOptions() {
    final List<String> dietaryOptions = [
      'Vegetarian',
      'Vegan',
      'Gluten-Free',
      'Dairy-Free',
      'Keto',
      'Low-Carb',
    ];

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: dietaryOptions.map((option) {
        final isSelected =
            (_filters['dietary'] as List<String>?)?.contains(option) ?? false;
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              final dietary =
                  (_filters['dietary'] as List<String>?) ?? <String>[];
              if (selected) {
                dietary.add(option);
              } else {
                dietary.remove(option);
              }
              _filters['dietary'] = dietary;
            });
          },
          selectedColor:
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
          checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
        );
      }).toList(),
    );
  }

  Widget _buildCookingTimeSlider() {
    return Column(
      children: [
        Slider(
          value: _maxCookingTime,
          min: 15,
          max: 120,
          divisions: 21,
          label: '${_maxCookingTime.round()} min',
          onChanged: (value) {
            setState(() {
              _maxCookingTime = value;
              _filters['maxCookingTime'] = value;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('15 min', style: AppTheme.lightTheme.textTheme.bodySmall),
            Text('2+ hours', style: AppTheme.lightTheme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultyOptions() {
    final List<String> difficultyLevels = ['Easy', 'Medium', 'Hard'];
    final selectedDifficulty = _filters['difficulty'] as String?;

    return Row(
      children: difficultyLevels.map((level) {
        final isSelected = selectedDifficulty == level;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _filters['difficulty'] = isSelected ? null : level;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
              child: Text(
                level,
                textAlign: TextAlign.center,
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _resetFilters() {
    setState(() {
      _filters = {
        'dietary': <String>[],
        'maxCookingTime': 60.0,
        'difficulty': null,
      };
      _maxCookingTime = 60.0;
    });
  }
}
