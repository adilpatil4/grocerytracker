import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController? cameraController;
  final bool isFlashOn;
  final VoidCallback onFlashToggle;
  final VoidCallback onCameraFlip;
  final bool showReceiptDetection;

  const CameraPreviewWidget({
    Key? key,
    required this.cameraController,
    required this.isFlashOn,
    required this.onFlashToggle,
    required this.onCameraFlip,
    required this.showReceiptDetection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Container(
        width: 100.w,
        height: 100.h,
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.primaryColor,
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Camera Preview
        SizedBox(
          width: 100.w,
          height: 100.h,
          child: CameraPreview(cameraController!),
        ),

        // Receipt Detection Overlay
        if (showReceiptDetection)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.lightTheme.primaryColor,
                  width: 3.0,
                ),
              ),
              margin: EdgeInsets.all(8.w),
            ),
          ),

        // Receipt Guide Overlay
        Positioned.fill(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.7),
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),

        // Guide Text
        Positioned(
          top: 15.h,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Position receipt within the frame',
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        // Flash Toggle Button
        Positioned(
          top: 8.h,
          right: 4.w,
          child: GestureDetector(
            onTap: onFlashToggle,
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: isFlashOn ? 'flash_on' : 'flash_off',
                color: Colors.white,
                size: 6.w,
              ),
            ),
          ),
        ),

        // Camera Flip Button
        Positioned(
          top: 8.h,
          left: 4.w,
          child: GestureDetector(
            onTap: onCameraFlip,
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'flip_camera_ios',
                color: Colors.white,
                size: 6.w,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
