import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/receipt_processing_service.dart';
import './widgets/camera_preview_widget.dart';
import './widgets/capture_controls_widget.dart';
import './widgets/item_edit_dialog_widget.dart';
import './widgets/processing_overlay_widget.dart';
import './widgets/receipt_items_list_widget.dart';

class ReceiptScanning extends StatefulWidget {
  const ReceiptScanning({Key? key}) : super(key: key);

  @override
  State<ReceiptScanning> createState() => _ReceiptScanningState();
}

class _ReceiptScanningState extends State<ReceiptScanning>
    with WidgetsBindingObserver {
  // Camera related variables
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  int _selectedCameraIndex = 0;

  // Processing states
  bool _isProcessing = false;
  bool _showReceiptDetection = false;
  String _processingMessage = 'Analyzing receipt...';

  // Receipt data
  List<Map<String, dynamic>> _detectedItems = [];
  bool _showItemsList = false;
  Map<String, dynamic>? _processingStats;

  // Services
  final ReceiptProcessingService _processingService =
      ReceiptProcessingService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Safely dispose camera controller
    final controller = _cameraController;
    if (controller != null) {
      controller.dispose().catchError((e) {
        // Handle disposal errors silently
        if (kDebugMode) {
          print('Camera disposal error (safe to ignore): $e');
        }
      });
      _cameraController = null;
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Dispose safely without causing errors
      controller.dispose().catchError((e) {
        if (kDebugMode) {
          print('Camera lifecycle disposal error (safe to ignore): $e');
        }
      });
      _cameraController = null;
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_cameraController == null && mounted) {
        _initializeCamera();
      }
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      // Dispose previous controller if exists - SAFE DISPOSAL
      final previousController = _cameraController;
      if (previousController != null) {
        await previousController.dispose().catchError((e) {
          // Handle disposal errors silently
          if (kDebugMode) {
            print('Previous camera disposal error (safe to ignore): $e');
          }
        });
      }
      _cameraController = null;

      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        _showPermissionDialog();
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _showNoCameraDialog();
        return;
      }

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first,
            )
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first,
            );

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Camera initialization error: $e');
      }
      if (mounted) {
        _showCameraErrorDialog();
      }
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        await _cameraController!.setFlashMode(FlashMode.auto);
      }
    } catch (e) {
      // Settings not supported on this platform
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
        _processingMessage = 'Capturing receipt...';
      });

      final XFile photo = await _cameraController!.takePicture();
      await _processReceiptImage(photo);
    } catch (e) {
      _showCaptureErrorDialog();
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _isProcessing = true;
          _processingMessage = 'Processing image...';
        });

        await _processReceiptImage(image);
      }
    } catch (e) {
      _showGalleryErrorDialog();
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processReceiptImage(XFile image) async {
    try {
      // Read image bytes
      final imageBytes = await image.readAsBytes();
      final fileName = image.name.isNotEmpty
          ? image.name
          : 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Process with real OCR and API services
      final items = await _processingService.processReceiptImage(
        imageBytes: imageBytes,
        fileName: fileName,
        onProgressUpdate: (message) {
          if (mounted) {
            setState(() {
              _processingMessage = message;
            });
          }
        },
      );

      // Get processing statistics
      final stats = _processingService.getProcessingStats(items);

      if (mounted) {
        setState(() {
          _detectedItems = items;
          _processingStats = stats;
          _isProcessing = false;
          _showItemsList = true;
        });

        // Show processing results
        _showProcessingResultsSnackBar(stats);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Receipt processing error: $e');
      }

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        // Show error and fallback to mock data for demonstration
        _showProcessingErrorDialog(e.toString());
      }
    }
  }

  void _showProcessingResultsSnackBar(Map<String, dynamic> stats) {
    final totalItems = stats['total_items'] ?? 0;
    final enhancementRate = stats['enhancement_rate'] ?? 0;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Found $totalItems items • ${enhancementRate}% enhanced with detailed info',
        ),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showProcessingErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              color: Colors.red,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Text('Scan Unsuccessful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'The receipt scan was unsuccessful. Here\'s what happened:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(2.w),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                errorMessage,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Common causes:\n'
              '• Poor image quality or lighting\n'
              '• Receipt is folded, torn, or faded\n'
              '• API connectivity issues\n'
              '• Unsupported receipt format\n\n'
              'Solutions:\n'
              '• Try better lighting when scanning\n'
              '• Flatten the receipt completely\n'
              '• Check your internet connection\n'
              '• Use a different receipt',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _useFallbackMockData();
            },
            child: const Text('Show Demo'),
          ),
        ],
      ),
    );
  }

  void _useFallbackMockData() {
    // Enhanced mock data that clearly indicates demo mode
    final mockData = [
      {
        "id": 1,
        "name": "Good & Gather Organic Milk",
        "display_name": "Good & Gather Organic Milk",
        "quantity": "1",
        "price": "\$4.29",
        "category": "dairy",
        "storage": "fridge",
        "item_number": "013-02-0445",
        "confidence_score": "demo",
        "processed_at": DateTime.now().toIso8601String(),
        "demo_data": true,
        "store_type": "target",
        "extraction_method": "demo_fallback",
      },
      {
        "id": 2,
        "name": "Market Pantry Greek Yogurt",
        "display_name": "Market Pantry Greek Yogurt",
        "quantity": "2",
        "price": "\$3.98",
        "category": "dairy",
        "storage": "fridge",
        "item_number": "013-01-0892",
        "confidence_score": "demo",
        "processed_at": DateTime.now().toIso8601String(),
        "demo_data": true,
        "store_type": "target",
        "extraction_method": "demo_fallback",
      },
      {
        "id": 3,
        "name": "Applegate Organic Turkey",
        "display_name": "Applegate Organic Turkey",
        "quantity": "1",
        "price": "\$6.49",
        "category": "meat",
        "storage": "fridge",
        "item_number": "020-12-1205",
        "confidence_score": "demo",
        "processed_at": DateTime.now().toIso8601String(),
        "demo_data": true,
        "store_type": "target",
        "extraction_method": "demo_fallback",
      },
      {
        "id": 4,
        "name": "Good & Gather Vegetable Oil",
        "display_name": "Good & Gather Vegetable Oil",
        "quantity": "1",
        "price": "\$3.99",
        "category": "general",
        "storage": "pantry",
        "item_number": "071-05-0324",
        "confidence_score": "demo",
        "processed_at": DateTime.now().toIso8601String(),
        "demo_data": true,
        "store_type": "target",
        "extraction_method": "demo_fallback",
      },
    ];

    setState(() {
      _detectedItems = mockData;
      _isProcessing = false;
      _showItemsList = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Demo Mode Active',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Showing sample Target receipt items - not real data',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Understood',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _toggleFlash() async {
    if (_cameraController == null || kIsWeb) return;

    try {
      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.off : FlashMode.torch,
      );
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      // Flash not supported
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;

    if (mounted) {
      setState(() {
        _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
        _isCameraInitialized = false;
      });
    }

    // Dispose current controller properly - SAFE DISPOSAL
    final currentController = _cameraController;
    if (currentController != null) {
      await currentController.dispose().catchError((e) {
        if (kDebugMode) {
          print('Camera flip disposal error (safe to ignore): $e');
        }
      });
    }
    _cameraController = null;

    try {
      _cameraController = CameraController(
        _cameras[_selectedCameraIndex],
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Camera flip error: $e');
      }
      if (mounted) {
        _showCameraErrorDialog();
      }
    }
  }

  void _editItem(int index) {
    showDialog(
      context: context,
      builder: (context) => ItemEditDialogWidget(
        item: _detectedItems[index],
        onSave: (updatedItem) {
          setState(() {
            _detectedItems[index] = updatedItem;
          });
        },
      ),
    );
  }

  void _deleteItem(int index) {
    setState(() {
      _detectedItems.removeAt(index);
    });
  }

  void _addToInventory() {
    // Show success message with scan status
    final isDemoData = _detectedItems.any((item) =>
        item['demo_data'] == true ||
        item['web_fallback'] == true ||
        item['confidence_score'] == 'demo');

    final enhancedCount = _detectedItems
        .where((item) => item['enhanced_with_redcircle'] == true)
        .length;

    String message;
    Color backgroundColor;

    if (isDemoData) {
      message =
          '${_detectedItems.length} demo items added to inventory (not real data)';
      backgroundColor = Colors.orange;
    } else if (enhancedCount > 0) {
      message =
          '${_detectedItems.length} items added • $enhancedCount with enhanced details!';
      backgroundColor = AppTheme.lightTheme.primaryColor;
    } else {
      message = '${_detectedItems.length} scanned items added to inventory!';
      backgroundColor = AppTheme.lightTheme.primaryColor;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: isDemoData ? 'science' : 'check_circle',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/inventory-management');
          },
        ),
      ),
    );

    // Reset state for another scan
    setState(() {
      _detectedItems.clear();
      _showItemsList = false;
      _processingStats = null;
    });
  }

  void _scanAnotherReceipt() {
    setState(() {
      _detectedItems.clear();
      _showItemsList = false;
      _isProcessing = false;
      _processingStats = null;
    });
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text('Please grant camera permission to scan receipts.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  void _showNoCameraDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Camera Available'),
        content: const Text('No camera was found on this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCameraErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Error'),
        content: const Text('Failed to initialize camera. Please try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeCamera();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showCaptureErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Capture Failed'),
        content: const Text('Failed to capture photo. Please try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showGalleryErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gallery Error'),
        content: const Text('Failed to select image from gallery.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview or Items List
          if (!_showItemsList) ...[
            // Camera Preview
            if (_isCameraInitialized)
              CameraPreviewWidget(
                cameraController: _cameraController,
                isFlashOn: _isFlashOn,
                onFlashToggle: _toggleFlash,
                onCameraFlip: _flipCamera,
                showReceiptDetection: _showReceiptDetection,
              )
            else
              Container(
                width: 100.w,
                height: 100.h,
                color: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                ),
              ),

            // Capture Controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CaptureControlsWidget(
                onCapture: _capturePhoto,
                onGallery: _selectFromGallery,
                isProcessing: _isProcessing,
              ),
            ),
          ] else ...[
            // Receipt Items List
            ReceiptItemsListWidget(
              items: _detectedItems,
              onEditItem: _editItem,
              onDeleteItem: _deleteItem,
              onAddToInventory: _addToInventory,
            ),
          ],

          // Close Button
          Positioned(
            top: 8.h,
            left: 4.w,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: Colors.white,
                    size: 6.w,
                  ),
                ),
              ),
            ),
          ),

          // Scan Another Receipt Button (when showing items list)
          if (_showItemsList)
            Positioned(
              top: 8.h,
              right: 4.w,
              child: SafeArea(
                child: GestureDetector(
                  onTap: _scanAnotherReceipt,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'camera_alt',
                          color: Colors.white,
                          size: 4.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Scan Another',
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Processing Overlay
          ProcessingOverlayWidget(
            isVisible: _isProcessing,
            message: _processingMessage,
          ),
        ],
      ),
    );
  }
}
