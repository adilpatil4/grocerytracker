import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FilterModal extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterModal({
    Key? key,
    required this.currentFilters,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late Map<String, dynamic> _filters;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.lightTheme.dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filters = {
                        'expirationStatus': <String>[],
                        'categories': <String>[],
                        'storageLocations': <String>[],
                      };
                    });
                  },
                  child: Text('Clear All'),
                ),
                Expanded(
                  child: Text(
                    'Filter Items',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onApplyFilters(_filters);
                    Navigator.pop(context);
                  },
                  child: Text('Apply'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(
                    'Expiration Status',
                    ['Fresh', 'Expiring Soon', 'Expired'],
                    'expirationStatus',
                  ),
                  SizedBox(height: 3.h),
                  _buildFilterSection(
                    'Categories',
                    [
                      'Produce',
                      'Dairy',
                      'Meat',
                      'Beverages',
                      'Canned Goods',
                      'Frozen',
                      'Bakery',
                      'Snacks'
                    ],
                    'categories',
                  ),
                  SizedBox(height: 3.h),
                  _buildFilterSection(
                    'Storage Locations',
                    ['Fridge', 'Freezer', 'Pantry'],
                    'storageLocations',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
      String title, List<String> options, String filterKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: options.map((option) {
            final isSelected =
                (_filters[filterKey] as List<String>).contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final filterList = _filters[filterKey] as List<String>;
                  if (selected) {
                    filterList.add(option);
                  } else {
                    filterList.remove(option);
                  }
                });
              },
              selectedColor:
                  AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.lightTheme.primaryColor,
              labelStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurface,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.dividerColor,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
