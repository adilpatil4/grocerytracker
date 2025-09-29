import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ShoppingListHeader extends StatefulWidget {
  final String listName;
  final VoidCallback onShare;
  final VoidCallback onClearCompleted;
  final Function(String) onListNameChanged;

  const ShoppingListHeader({
    Key? key,
    required this.listName,
    required this.onShare,
    required this.onClearCompleted,
    required this.onListNameChanged,
  }) : super(key: key);

  @override
  State<ShoppingListHeader> createState() => _ShoppingListHeaderState();
}

class _ShoppingListHeaderState extends State<ShoppingListHeader> {
  bool _isEditing = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.listName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        widget.onListNameChanged(_nameController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _isEditing
                      ? TextField(
                          controller: _nameController,
                          style: AppTheme.lightTheme.textTheme.headlineSmall,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.h,
                            ),
                          ),
                          onSubmitted: (_) => _toggleEdit(),
                        )
                      : GestureDetector(
                          onTap: _toggleEdit,
                          child: Text(
                            widget.listName,
                            style: AppTheme.lightTheme.textTheme.headlineSmall,
                          ),
                        ),
                ),
                SizedBox(width: 3.w),
                IconButton(
                  onPressed: _isEditing ? _toggleEdit : widget.onShare,
                  icon: CustomIconWidget(
                    iconName: _isEditing ? 'check' : 'share',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 6.w,
                  ),
                ),
                IconButton(
                  onPressed: widget.onClearCompleted,
                  icon: CustomIconWidget(
                    iconName: 'clear_all',
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    size: 6.w,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Container(
              height: 0.5,
              color: AppTheme.lightTheme.dividerColor,
            ),
          ],
        ),
      ),
    );
  }
}
