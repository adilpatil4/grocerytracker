import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ItemEditDialogWidget extends StatefulWidget {
  final Map<String, dynamic> item;
  final Function(Map<String, dynamic>) onSave;

  const ItemEditDialogWidget({
    Key? key,
    required this.item,
    required this.onSave,
  }) : super(key: key);

  @override
  State<ItemEditDialogWidget> createState() => _ItemEditDialogWidgetState();
}

class _ItemEditDialogWidgetState extends State<ItemEditDialogWidget> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  String _selectedCategory = 'grocery';
  String _selectedStorage = 'pantry';

  final List<String> _categories = [
    'produce',
    'dairy',
    'meat',
    'beverages',
    'canned',
    'frozen',
    'bakery',
    'grocery',
  ];

  final List<String> _storageLocations = [
    'pantry',
    'fridge',
    'freezer',
  ];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.item['name'] as String? ?? '');
    _quantityController =
        TextEditingController(text: widget.item['quantity']?.toString() ?? '1');
    _priceController =
        TextEditingController(text: widget.item['price'] as String? ?? '');
    _selectedCategory = widget.item['category'] as String? ?? 'grocery';
    _selectedStorage = widget.item['storage'] as String? ?? 'pantry';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 90.w,
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'edit',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Edit Item',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 6.w,
                  ),
                ),
              ],
            ),

            SizedBox(height: 4.h),

            // Item Name Field
            Text(
              'Item Name',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter item name',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'shopping_basket',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 5.w,
                  ),
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // Quantity and Price Row
            Row(
              children: [
                // Quantity Field
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '1',
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(3.w),
                            child: CustomIconWidget(
                              iconName: 'numbers',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 5.w,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 4.w),

                // Price Field
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      TextField(
                        controller: _priceController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: '\$0.00',
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(3.w),
                            child: CustomIconWidget(
                              iconName: 'attach_money',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 5.w,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Category Dropdown
            Text(
              'Category',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'category',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 5.w,
                  ),
                ),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(
                    category.substring(0, 1).toUpperCase() +
                        category.substring(1),
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value ?? 'grocery';
                });
              },
            ),

            SizedBox(height: 3.h),

            // Storage Location Dropdown
            Text(
              'Storage Location',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            DropdownButtonFormField<String>(
              value: _selectedStorage,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'home',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 5.w,
                  ),
                ),
              ),
              items: _storageLocations.map((storage) {
                return DropdownMenuItem<String>(
                  value: storage,
                  child: Text(
                    storage.substring(0, 1).toUpperCase() +
                        storage.substring(1),
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStorage = value ?? 'pantry';
                });
              },
            ),

            SizedBox(height: 4.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveItem,
                    child: Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveItem() {
    final updatedItem = {
      ...widget.item,
      'name': _nameController.text.trim(),
      'quantity': _quantityController.text.trim(),
      'price': _priceController.text.trim(),
      'category': _selectedCategory,
      'storage': _selectedStorage,
    };

    widget.onSave(updatedItem);
    Navigator.of(context).pop();
  }
}
