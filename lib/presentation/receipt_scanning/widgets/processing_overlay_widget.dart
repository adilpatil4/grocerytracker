import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProcessingOverlayWidget extends StatefulWidget {
  final bool isVisible;
  final String message;

  const ProcessingOverlayWidget({
    Key? key,
    required this.isVisible,
    this.message = 'Analyzing receipt...',
  }) : super(key: key);

  @override
  State<ProcessingOverlayWidget> createState() =>
      _ProcessingOverlayWidgetState();
}

class _ProcessingOverlayWidgetState extends State<ProcessingOverlayWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ProcessingOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return SizedBox.shrink();
    }

    return Container(
      width: 100.w,
      height: 100.h,
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Processing Icon
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.lightTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: CustomIconWidget(
                        iconName: 'document_scanner',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 12.w,
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 4.h),

            // Processing Message
            Text(
              widget.message,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 2.h),

            // Progress Indicator
            SizedBox(
              width: 60.w,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.lightTheme.primaryColor,
                ),
              ),
            ),

            SizedBox(height: 2.h),

            // Sub-message
            Text(
              'Please wait while we extract items from your receipt',
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
