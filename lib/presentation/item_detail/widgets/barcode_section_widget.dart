import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class BarcodeSectionWidget extends StatelessWidget {
  final String? barcode;

  const BarcodeSectionWidget({
    Key? key,
    this.barcode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (barcode == null || barcode!.isEmpty) {
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
                  iconName: 'qr_code',
                  size: 24,
                  color: AppTheme.lightTheme.primaryColor,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Barcode Information',
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  // Barcode visual representation
                  Container(
                    height: 8.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Simple barcode representation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(20, (index) {
                              return Container(
                                width: index % 3 == 0
                                    ? 3
                                    : index % 2 == 0
                                        ? 2
                                        : 1,
                                height: 4.h,
                                margin: EdgeInsets.symmetric(horizontal: 0.2.w),
                                color: Colors.black,
                              );
                            }),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            barcode!,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Barcode Number',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              barcode!,
                              style: AppTheme.lightTheme.textTheme.bodyLarge
                                  ?.copyWith(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Copy barcode to clipboard
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Barcode copied to clipboard'),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: CustomIconWidget(
                            iconName: 'content_copy',
                            size: 20,
                            color: AppTheme.lightTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
                    iconName: 'info',
                    size: 20,
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'This barcode was scanned when the item was added to your inventory.',
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
}
