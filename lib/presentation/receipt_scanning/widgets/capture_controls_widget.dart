import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CaptureControlsWidget extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onGallery;
  final bool isProcessing;

  const CaptureControlsWidget({
    Key? key,
    required this.onCapture,
    required this.onGallery,
    required this.isProcessing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25.h,
      width: 100.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Instructions
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Tap to capture receipt or select from gallery',
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Control Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Gallery Button
              GestureDetector(
                onTap: isProcessing ? null : onGallery,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: isProcessing
                        ? Colors.grey.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: CustomIconWidget(
                    iconName: 'photo_library',
                    color: Colors.white,
                    size: 7.w,
                  ),
                ),
              ),

              // Capture Button
              GestureDetector(
                onTap: isProcessing ? null : onCapture,
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: isProcessing
                        ? Colors.grey.withValues(alpha: 0.5)
                        : AppTheme.lightTheme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isProcessing
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : CustomIconWidget(
                          iconName: 'camera_alt',
                          color: Colors.white,
                          size: 8.w,
                        ),
                ),
              ),

              // Placeholder for symmetry
              Container(
                padding: EdgeInsets.all(4.w),
                child: CustomIconWidget(
                  iconName: 'photo_library',
                  color: Colors.transparent,
                  size: 7.w,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
