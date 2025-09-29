import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sizer/sizer.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/app_export.dart';

class AddItemDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onItemAdded;

  const AddItemDialog({
    Key? key,
    required this.onItemAdded,
  }) : super(key: key);

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _selectedCategory = 'Produce';
  bool _isListening = false;
  bool _speechEnabled = false;
  SpeechToText _speechToText = SpeechToText();
  MobileScannerController _scannerController = MobileScannerController();

  final List<String> _categories = [
    'Produce',
    'Dairy',
    'Meat',
    'Bakery',
    'Canned Goods',
    'Beverages',
    'Frozen',
    'Household',
    'Personal Care',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initSpeech();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    if (_speechEnabled) {
      setState(() => _isListening = true);
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _nameController.text = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) {
        // Simulate product lookup from barcode
        _nameController.text = 'Product ${barcode.rawValue}';
        _tabController.animateTo(0);
      }
    }
  }

  void _addItem() {
    if (_nameController.text.trim().isEmpty) return;

    final item = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': _nameController.text.trim(),
      'quantity': _quantityController.text.trim(),
      'estimatedPrice': _priceController.text.trim(),
      'category': _selectedCategory,
      'isCompleted': false,
      'dateAdded': DateTime.now(),
    };

    widget.onItemAdded(item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 70.h,
        width: 90.w,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add Item',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 6.w,
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  icon: CustomIconWidget(
                    iconName: 'edit',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                  text: 'Manual',
                ),
                Tab(
                  icon: CustomIconWidget(
                    iconName: 'qr_code_scanner',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                  text: 'Scan',
                ),
                Tab(
                  icon: CustomIconWidget(
                    iconName: 'mic',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                  text: 'Voice',
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildManualTab(),
                  _buildScanTab(),
                  _buildVoiceTab(),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addItem,
                      child: Text('Add Item'),
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

  Widget _buildManualTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Item Name',
              hintText: 'Enter item name',
            ),
          ),
          SizedBox(height: 2.h),
          TextField(
            controller: _quantityController,
            decoration: InputDecoration(
              labelText: 'Quantity',
              hintText: 'e.g., 2 lbs, 1 gallon',
            ),
          ),
          SizedBox(height: 2.h),
          TextField(
            controller: _priceController,
            decoration: InputDecoration(
              labelText: 'Estimated Price',
              hintText: 'e.g., \$3.99',
              prefixText: '\$',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 2.h),
          Text(
            'Category',
            style: AppTheme.lightTheme.textTheme.titleSmall,
          ),
          SizedBox(height: 1.h),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCategory = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScanTab() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          Text(
            'Point camera at barcode',
            style: AppTheme.lightTheme.textTheme.bodyLarge,
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: MobileScanner(
                  controller: _scannerController,
                  onDetect: _onBarcodeDetected,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceTab() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: _isListening ? 'mic' : 'mic_none',
            color: _isListening
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20.w,
          ),
          SizedBox(height: 4.h),
          Text(
            _isListening
                ? 'Listening... Say item names'
                : 'Tap to start voice input',
            style: AppTheme.lightTheme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          if (_nameController.text.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Recognized: ${_nameController.text}',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ),
            SizedBox(height: 2.h),
          ],
          ElevatedButton(
            onPressed: _speechEnabled
                ? (_isListening ? _stopListening : _startListening)
                : null,
            child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
          ),
        ],
      ),
    );
  }
}
