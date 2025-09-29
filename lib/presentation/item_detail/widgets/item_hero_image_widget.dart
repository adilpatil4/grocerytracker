import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ItemHeroImageWidget extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onCameraPressed;

  const ItemHeroImageWidget({
    Key? key,
    this.imageUrl,
    required this.onCameraPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 30.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? CustomImageWidget(
                    imageUrl: imageUrl!,
                    width: double.infinity,
                    height: 30.h,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: 30.h,
                    color: AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'image',
                          size: 48,
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'No Image Available',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          Positioned(
            bottom: 2.h,
            right: 4.w,
            child: GestureDetector(
              onTap: onCameraPressed,
              child: Container(
                width: 12.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: CustomIconWidget(
                  iconName: 'camera_alt',
                  size: 24,
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
