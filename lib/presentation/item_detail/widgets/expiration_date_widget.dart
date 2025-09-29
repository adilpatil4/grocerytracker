import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ExpirationDateWidget extends StatelessWidget {
  final DateTime? expirationDate;
  final Function(DateTime) onDateChanged;

  const ExpirationDateWidget({
    Key? key,
    this.expirationDate,
    required this.onDateChanged,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  int _getDaysUntilExpiration() {
    if (expirationDate == null) return 0;
    final now = DateTime.now();
    final difference = expirationDate!.difference(now).inDays;
    return difference;
  }

  Color _getExpirationColor() {
    final daysLeft = _getDaysUntilExpiration();
    if (daysLeft < 0) return AppTheme.lightTheme.colorScheme.error;
    if (daysLeft <= 3) return Colors.orange;
    if (daysLeft <= 7) return Colors.amber;
    return AppTheme.lightTheme.primaryColor;
  }

  String _getExpirationStatus() {
    final daysLeft = _getDaysUntilExpiration();
    if (daysLeft < 0) return 'Expired ${(-daysLeft)} days ago';
    if (daysLeft == 0) return 'Expires today';
    if (daysLeft == 1) return 'Expires tomorrow';
    return 'Expires in $daysLeft days';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: expirationDate ?? DateTime.now().add(Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.lightTheme.primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateChanged(picked);
    }
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
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  size: 24,
                  color: _getExpirationColor(),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Expiration Date',
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: 2.h),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expirationDate != null
                                ? _formatDate(expirationDate!)
                                : 'Select Date',
                            style: AppTheme.lightTheme.textTheme.bodyLarge
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (expirationDate != null) ...[
                            SizedBox(height: 0.5.h),
                            Text(
                              _getExpirationStatus(),
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: _getExpirationColor(),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    CustomIconWidget(
                      iconName: 'calendar_today',
                      size: 20,
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
            if (expirationDate != null) ...[
              SizedBox(height: 2.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: _getExpirationColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: _getDaysUntilExpiration() < 0
                          ? 'warning'
                          : _getDaysUntilExpiration() <= 3
                              ? 'priority_high'
                              : 'info',
                      size: 20,
                      color: _getExpirationColor(),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        _getDaysUntilExpiration() < 0
                            ? 'This item has expired and should be discarded'
                            : _getDaysUntilExpiration() <= 3
                                ? 'This item expires soon. Consider using it first'
                                : 'This item is fresh and good to use',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: _getExpirationColor(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 2.h),
            Text(
              'Smart Suggestions',
              style: AppTheme.lightTheme.textTheme.titleSmall,
            ),
            SizedBox(height: 1.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: [
                _buildSuggestionChip('3 days',
                    () => onDateChanged(DateTime.now().add(Duration(days: 3)))),
                _buildSuggestionChip('1 week',
                    () => onDateChanged(DateTime.now().add(Duration(days: 7)))),
                _buildSuggestionChip(
                    '2 weeks',
                    () =>
                        onDateChanged(DateTime.now().add(Duration(days: 14)))),
                _buildSuggestionChip(
                    '1 month',
                    () =>
                        onDateChanged(DateTime.now().add(Duration(days: 30)))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
