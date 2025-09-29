import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ItemInfoCardWidget extends StatefulWidget {
  final String itemName;
  final String category;
  final int quantity;
  final String storageLocation;
  final Function(String) onNameChanged;
  final Function(int) onQuantityChanged;
  final Function(String) onLocationChanged;

  const ItemInfoCardWidget({
    Key? key,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.storageLocation,
    required this.onNameChanged,
    required this.onQuantityChanged,
    required this.onLocationChanged,
  }) : super(key: key);

  @override
  State<ItemInfoCardWidget> createState() => _ItemInfoCardWidgetState();
}

class _ItemInfoCardWidgetState extends State<ItemInfoCardWidget> {
  late TextEditingController _nameController;
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.itemName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Select Storage Location',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            SizedBox(height: 3.h),
            _buildLocationOption(
                'Fridge', 'kitchen', widget.storageLocation == 'Fridge'),
            _buildLocationOption(
                'Freezer', 'ac_unit', widget.storageLocation == 'Freezer'),
            _buildLocationOption(
                'Pantry', 'inventory_2', widget.storageLocation == 'Pantry'),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationOption(
      String location, String iconName, bool isSelected) {
    return GestureDetector(
      onTap: () {
        widget.onLocationChanged(location);
        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: iconName,
              size: 24,
              color: isSelected
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurface,
            ),
            SizedBox(width: 3.w),
            Text(
              location,
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: isSelected
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            Spacer(),
            if (isSelected)
              CustomIconWidget(
                iconName: 'check_circle',
                size: 20,
                color: AppTheme.lightTheme.primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Name Section
            Row(
              children: [
                Expanded(
                  child: _isEditingName
                      ? TextField(
                          controller: _nameController,
                          style: AppTheme.lightTheme.textTheme.titleLarge,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 1.h),
                          ),
                          onSubmitted: (value) {
                            setState(() {
                              _isEditingName = false;
                            });
                            widget.onNameChanged(value);
                          },
                        )
                      : Text(
                          widget.itemName,
                          style: AppTheme.lightTheme.textTheme.titleLarge,
                        ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_isEditingName) {
                      widget.onNameChanged(_nameController.text);
                    }
                    setState(() {
                      _isEditingName = !_isEditingName;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    child: CustomIconWidget(
                      iconName: _isEditingName ? 'check' : 'edit',
                      size: 20,
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Category Section
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'category',
                  size: 20,
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
                SizedBox(width: 2.w),
                Text(
                  'Category: ',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  widget.category,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Quantity Section
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'inventory',
                  size: 20,
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
                SizedBox(width: 2.w),
                Text(
                  'Quantity: ',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (widget.quantity > 0) {
                          widget.onQuantityChanged(widget.quantity - 1);
                        }
                      },
                      child: Container(
                        width: 8.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.primaryColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: CustomIconWidget(
                          iconName: 'remove',
                          size: 18,
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    Container(
                      width: 12.w,
                      height: 4.h,
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${widget.quantity}',
                          style:
                              AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.onQuantityChanged(widget.quantity + 1);
                      },
                      child: Container(
                        width: 8.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.primaryColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: CustomIconWidget(
                          iconName: 'add',
                          size: 18,
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Storage Location Section
            GestureDetector(
              onTap: _showLocationPicker,
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: widget.storageLocation == 'Fridge'
                        ? 'kitchen'
                        : widget.storageLocation == 'Freezer'
                            ? 'ac_unit'
                            : 'inventory_2',
                    size: 20,
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Storage: ',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    widget.storageLocation,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                  Spacer(),
                  CustomIconWidget(
                    iconName: 'arrow_drop_down',
                    size: 20,
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
