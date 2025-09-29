import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AddItemBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddItem;

  const AddItemBottomSheet({
    Key? key,
    required this.onAddItem,
  }) : super(key: key);

  @override
  State<AddItemBottomSheet> createState() => _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends State<AddItemBottomSheet> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  String _selectedCategory = 'Produce';
  String _selectedLocation = 'Fridge';
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 7));

  final List<String> _categories = [
    'Produce',
    'Dairy',
    'Meat',
    'Beverages',
    'Canned Goods',
    'Frozen',
    'Bakery',
    'Snacks'
  ];

  final List<String> _locations = ['Fridge', 'Freezer', 'Pantry'];

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
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
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                Expanded(
                  child: Text(
                    'Add Item',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                TextButton(
                  onPressed: _addItem,
                  child: Text('Add'),
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
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Barcode scanning functionality would be implemented here
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Barcode scanning feature coming soon!')),
                            );
                          },
                          icon: CustomIconWidget(
                            iconName: 'qr_code_scanner',
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            size: 20,
                          ),
                          label: Text('Scan Barcode'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Item Details',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      hintText: 'Enter item name',
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      hintText: 'Enter quantity',
                    ),
                  ),
                  SizedBox(height: 2.h),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  SizedBox(height: 2.h),
                  DropdownButtonFormField<String>(
                    value: _selectedLocation,
                    decoration: const InputDecoration(
                      labelText: 'Storage Location',
                    ),
                    items: _locations.map((location) {
                      return DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value!;
                      });
                    },
                  ),
                  SizedBox(height: 2.h),
                  GestureDetector(
                    onTap: _selectExpirationDate,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 4.w, vertical: 1.5.h),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: AppTheme.lightTheme.dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'calendar_today',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Expiration Date',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  '${_expirationDate.month}/${_expirationDate.day}/${_expirationDate.year}',
                                  style:
                                      AppTheme.lightTheme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
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

  Future<void> _selectExpirationDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _expirationDate) {
      setState(() {
        _expirationDate = picked;
      });
    }
  }

  void _addItem() {
    if (_nameController.text.isEmpty || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final newItem = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': _nameController.text,
      'quantity': _quantityController.text,
      'category': _selectedCategory,
      'location': _selectedLocation,
      'expirationDate': _expirationDate.toIso8601String(),
      'image':
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&h=400&fit=crop',
    };

    widget.onAddItem(newItem);
    Navigator.pop(context);
  }
}
