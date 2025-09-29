import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/barcode_section_widget.dart';
import './widgets/expiration_date_widget.dart';
import './widgets/item_hero_image_widget.dart';
import './widgets/item_info_card_widget.dart';
import './widgets/nutritional_info_widget.dart';
import './widgets/purchase_history_widget.dart';
import './widgets/related_recipes_widget.dart';

class ItemDetail extends StatefulWidget {
  const ItemDetail({Key? key}) : super(key: key);

  @override
  State<ItemDetail> createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  // Camera related variables
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  final ImagePicker _imagePicker = ImagePicker();

  // Item data
  late Map<String, dynamic> _itemData;
  bool _hasUnsavedChanges = false;

  // Mock data for the item
  final Map<String, dynamic> _mockItemData = {
    "id": 1,
    "name": "Organic Bananas",
    "category": "Produce",
    "quantity": 6,
    "storageLocation": "Pantry",
    "expirationDate": "2025-01-05",
    "image":
        "https://images.pexels.com/photos/2872755/pexels-photo-2872755.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "barcode": "1234567890123",
    "nutritionalInfo": {
      "calories": 105,
      "protein": 1.3,
      "carbs": 27,
      "fat": 0.3,
      "fiber": 3.1,
      "sugar": 14.4,
      "vitaminC": 10.3,
      "potassium": 422
    },
    "purchaseHistory": [
      {
        "date": "2024-12-25",
        "store": "Fresh Market",
        "price": 2.99,
        "quantity": 6
      },
      {
        "date": "2024-12-18",
        "store": "Grocery Plus",
        "price": 3.49,
        "quantity": 8
      },
      {
        "date": "2024-12-10",
        "store": "Fresh Market",
        "price": 2.79,
        "quantity": 6
      },
      {
        "date": "2024-12-03",
        "store": "Super Store",
        "price": 3.29,
        "quantity": 7
      }
    ]
  };

  final List<Map<String, dynamic>> _relatedRecipes = [
    {
      "id": 1,
      "name": "Banana Bread",
      "image":
          "https://images.pexels.com/photos/830894/pexels-photo-830894.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "cookTime": 60,
      "rating": 4.8,
      "difficulty": "Easy"
    },
    {
      "id": 2,
      "name": "Banana Smoothie",
      "image":
          "https://images.pexels.com/photos/775032/pexels-photo-775032.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "cookTime": 5,
      "rating": 4.6,
      "difficulty": "Easy"
    },
    {
      "id": 3,
      "name": "Banana Pancakes",
      "image":
          "https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "cookTime": 20,
      "rating": 4.7,
      "difficulty": "Medium"
    }
  ];

  @override
  void initState() {
    super.initState();
    _itemData = Map<String, dynamic>.from(_mockItemData);
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      if (!await _requestCameraPermission()) return;

      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
          camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

      await _cameraController!.initialize();
      await _applySettings();
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {
          print('Flash mode not supported: $e');
        }
      }
    } catch (e) {
      print('Camera settings error: $e');
    }
  }

  Future<void> _capturePhoto() async {
    try {
      if (_cameraController == null ||
          !_cameraController!.value.isInitialized) {
        // Fallback to image picker
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );

        if (image != null) {
          setState(() {
            _itemData['image'] = image.path;
            _hasUnsavedChanges = true;
          });
          _showSuccessToast('Photo updated successfully');
        }
        return;
      }

      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _itemData['image'] = photo.path;
        _hasUnsavedChanges = true;
      });
      _showSuccessToast('Photo updated successfully');
    } catch (e) {
      print('Photo capture error: $e');
      _showErrorToast('Failed to capture photo');
    }
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.primaryColor,
      textColor: Colors.white,
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.error,
      textColor: Colors.white,
    );
  }

  void _onNameChanged(String newName) {
    setState(() {
      _itemData['name'] = newName;
      _hasUnsavedChanges = true;
    });
  }

  void _onQuantityChanged(int newQuantity) {
    setState(() {
      _itemData['quantity'] = newQuantity;
      _hasUnsavedChanges = true;
    });
  }

  void _onLocationChanged(String newLocation) {
    setState(() {
      _itemData['storageLocation'] = newLocation;
      _hasUnsavedChanges = true;
    });
    _showSuccessToast('Storage location updated to $newLocation');
  }

  void _onExpirationDateChanged(DateTime newDate) {
    setState(() {
      _itemData['expirationDate'] = newDate.toIso8601String().split('T')[0];
      _hasUnsavedChanges = true;
    });
    _showSuccessToast('Expiration date updated');
  }

  void _onMoveLocation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Move to Different Location',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            SizedBox(height: 3.h),
            _buildMoveLocationOption('Fridge', 'kitchen'),
            _buildMoveLocationOption('Freezer', 'ac_unit'),
            _buildMoveLocationOption('Pantry', 'inventory_2'),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMoveLocationOption(String location, String iconName) {
    final isCurrentLocation = _itemData['storageLocation'] == location;

    return GestureDetector(
      onTap: isCurrentLocation
          ? null
          : () {
              _onLocationChanged(location);
              Navigator.pop(context);
            },
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: isCurrentLocation
              ? AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.surface,
          border: Border.all(
            color: isCurrentLocation
                ? AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.3)
                : AppTheme.lightTheme.colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: iconName,
              size: 24,
              color: isCurrentLocation
                  ? AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.5)
                  : AppTheme.lightTheme.primaryColor,
            ),
            SizedBox(width: 3.w),
            Text(
              location,
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: isCurrentLocation
                    ? AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.5)
                    : AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
            Spacer(),
            if (isCurrentLocation)
              Text(
                'Current',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onAddToShoppingList() {
    _showSuccessToast('${_itemData['name']} added to shopping list');
    Navigator.pushNamed(context, '/shopping-list');
  }

  void _onShareItem() {
    _showSuccessToast('Item details shared successfully');
  }

  void _onDeleteItem() {
    _showSuccessToast('${_itemData['name']} deleted from inventory');
    Navigator.pop(context);
  }

  void _onViewAllRecipes() {
    Navigator.pushNamed(context, '/recipe-recommendations');
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unsaved Changes'),
        content: Text(
            'You have unsaved changes. Do you want to save them before leaving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Discard'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              _showSuccessToast('Changes saved successfully');
            },
            child: Text('Save'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            _itemData['name'] as String,
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          leading: IconButton(
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          actions: [
            if (_hasUnsavedChanges)
              IconButton(
                onPressed: () {
                  setState(() {
                    _hasUnsavedChanges = false;
                  });
                  _showSuccessToast('Changes saved successfully');
                },
                icon: CustomIconWidget(
                  iconName: 'save',
                  size: 24,
                  color: AppTheme.lightTheme.primaryColor,
                ),
              ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/main-dashboard');
              },
              icon: CustomIconWidget(
                iconName: 'home',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Image Section
              ItemHeroImageWidget(
                imageUrl: _itemData['image'] as String?,
                onCameraPressed: _capturePhoto,
              ),
              SizedBox(height: 3.h),

              // Item Information Card
              ItemInfoCardWidget(
                itemName: _itemData['name'] as String,
                category: _itemData['category'] as String,
                quantity: _itemData['quantity'] as int,
                storageLocation: _itemData['storageLocation'] as String,
                onNameChanged: _onNameChanged,
                onQuantityChanged: _onQuantityChanged,
                onLocationChanged: _onLocationChanged,
              ),
              SizedBox(height: 2.h),

              // Expiration Date Section
              ExpirationDateWidget(
                expirationDate: _itemData['expirationDate'] != null
                    ? DateTime.parse(_itemData['expirationDate'] as String)
                    : null,
                onDateChanged: _onExpirationDateChanged,
              ),
              SizedBox(height: 2.h),

              // Nutritional Information
              NutritionalInfoWidget(
                nutritionalInfo:
                    _itemData['nutritionalInfo'] as Map<String, dynamic>?,
              ),
              SizedBox(height: 2.h),

              // Purchase History
              PurchaseHistoryWidget(
                purchaseHistory: (_itemData['purchaseHistory'] as List)
                    .cast<Map<String, dynamic>>(),
              ),
              SizedBox(height: 2.h),

              // Barcode Section
              BarcodeSectionWidget(
                barcode: _itemData['barcode'] as String?,
              ),
              SizedBox(height: 2.h),

              // Related Recipes
              RelatedRecipesWidget(
                relatedRecipes: _relatedRecipes,
                onViewAllRecipes: _onViewAllRecipes,
              ),
              SizedBox(height: 3.h),

              // Action Buttons
              ActionButtonsWidget(
                onMoveLocation: _onMoveLocation,
                onAddToShoppingList: _onAddToShoppingList,
                onShareItem: _onShareItem,
                onDeleteItem: _onDeleteItem,
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}
