import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ReceiptItemsListWidget extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final Function(int) onEditItem;
  final Function(int) onDeleteItem;
  final Function() onAddToInventory;

  const ReceiptItemsListWidget({
    Key? key,
    required this.items,
    required this.onEditItem,
    required this.onDeleteItem,
    required this.onAddToInventory,
  }) : super(key: key);

  @override
  State<ReceiptItemsListWidget> createState() => _ReceiptItemsListWidgetState();
}

class _ReceiptItemsListWidgetState extends State<ReceiptItemsListWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 100.h,
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header with scan status
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Status indicator
                  _buildScanStatusHeader(),
                  SizedBox(height: 3.w),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'receipt_long',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 6.w,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        _getHeaderTitle(),
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.w),
                  Row(
                    children: [
                      _buildInfoChip(
                        '${widget.items.length} items',
                        Colors.blue,
                      ),
                      SizedBox(width: 2.w),
                      _buildInfoChip(
                        _getEnhancedItemsCount(),
                        Colors.green,
                      ),
                      SizedBox(width: 2.w),
                      _buildInfoChip(
                        _getTotalPrice(),
                        Colors.orange,
                      ),
                      if (_hasDemoData()) ...[
                        SizedBox(width: 2.w),
                        _buildInfoChip(
                          'Demo Mode',
                          Colors.orange,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Items List
            Expanded(
              child: widget.items.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: EdgeInsets.all(4.w),
                      itemCount: widget.items.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 3.w),
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        return _buildItemCard(item, index);
                      },
                    ),
            ),

            // Add to Inventory Button
            if (widget.items.isNotEmpty)
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Success message for real data
                    if (_hasRealData())
                      Container(
                        margin: EdgeInsets.only(bottom: 3.w),
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(2.w),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'check_circle',
                              color: Colors.green.shade700,
                              size: 5.w,
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Receipt Scan Successful!',
                                    style: AppTheme
                                        .lightTheme.textTheme.titleSmall
                                        ?.copyWith(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _getSuccessMessage(),
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Add to inventory button
                    SizedBox(
                      width: 100.w,
                      child: ElevatedButton(
                        onPressed: widget.onAddToInventory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasRealData()
                              ? AppTheme.lightTheme.primaryColor
                              : Colors.orange,
                          padding: EdgeInsets.symmetric(vertical: 4.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.w),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: _hasRealData()
                                  ? 'add_shopping_cart'
                                  : 'science',
                              color: Colors.white,
                              size: 5.w,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              _hasRealData()
                                  ? 'Add ${widget.items.length} Items to Inventory'
                                  : 'Add Demo Items (${widget.items.length} items)',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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

  Widget _buildScanStatusHeader() {
    if (_hasDemoData()) {
      return Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'info',
              color: Colors.orange.shade700,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan Unsuccessful - Demo Data Shown',
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Receipt processing failed or is running in demo mode. Try with a different receipt.',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'check_circle',
            color: Colors.green.shade700,
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Receipt Scanned Successfully',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Items extracted from your receipt using OCR technology',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getHeaderTitle() {
    if (_hasDemoData()) {
      return 'Demo Items';
    }
    return 'Scanned Items';
  }

  bool _hasDemoData() {
    return widget.items.any((item) =>
        item['demo_data'] == true ||
        item['web_fallback'] == true ||
        item['confidence_score'] == 'demo');
  }

  bool _hasRealData() {
    return !_hasDemoData();
  }

  String _getSuccessMessage() {
    final enhancedCount = widget.items
        .where((item) => item['enhanced_with_redcircle'] == true)
        .length;
    final targetCount =
        widget.items.where((item) => item['store_type'] == 'target').length;

    if (enhancedCount > 0) {
      return 'Found ${widget.items.length} items with $enhancedCount enhanced using RedCircle API';
    } else if (targetCount > 0) {
      return 'Found ${widget.items.length} items from Target receipt with detailed information';
    }
    return 'Successfully extracted ${widget.items.length} items from your receipt';
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getEnhancedItemsCount() {
    final enhancedCount = widget.items
        .where((item) => item['enhanced_with_redcircle'] == true)
        .length;
    final targetCount =
        widget.items.where((item) => item['store_type'] == 'target').length;

    if (enhancedCount > 0) {
      return '$enhancedCount enhanced';
    } else if (targetCount > 0) {
      return '$targetCount Target items';
    }
    return 'Basic items';
  }

  String _getTotalPrice() {
    double total = 0.0;
    for (final item in widget.items) {
      final priceStr = item['price']?.toString() ?? '\$0.00';
      final price = double.tryParse(priceStr.replaceAll('\$', '')) ?? 0.0;
      total += price;
    }
    return '\$${total.toStringAsFixed(2)}';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'receipt',
            color: Colors.grey.shade400,
            size: 20.w,
          ),
          SizedBox(height: 4.w),
          Text(
            'No items found',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.w),
          Text(
            'The receipt could not be processed or no items were detected.',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, int index) {
    final isDemo = item['demo_data'] == true || item['web_fallback'] == true;
    final confidence = item['confidence_score'] ?? 'unknown';
    final isTargetItem = item['store_type'] == 'target';
    final extractionMethod = item['extraction_method'] ?? 'unknown';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status indicators
            Row(
              children: [
                Expanded(
                  child: Text(
                    item['display_name'] ?? item['name'] ?? 'Unknown Item',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusBadge(isDemo, confidence, extractionMethod),
              ],
            ),

            const SizedBox(height: 8),

            // Item details row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Qty: ${item['quantity'] ?? '1'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${item['category'] ?? 'general'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item['price'] ?? '\$0.00',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    if (item['unit_price'] != null)
                      Text(
                        'Unit: \$${item['unit_price']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Enhanced details for real scanned items
            if (!isDemo) ...[
              const SizedBox(height: 12),
              _buildEnhancedDetails(item, isTargetItem),
            ],

            // Demo data warning
            if (isDemo) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This is demo data. Scan a real receipt to see actual items.',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
      bool isDemo, String confidence, String extractionMethod) {
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    if (isDemo) {
      badgeColor = Colors.orange;
      badgeText = 'DEMO';
      badgeIcon = Icons.visibility;
    } else {
      switch (confidence) {
        case 'high':
          badgeColor = Colors.green;
          badgeText = 'HIGH';
          badgeIcon = Icons.check_circle;
          break;
        case 'medium-high':
          badgeColor = Colors.lightGreen;
          badgeText = 'GOOD';
          badgeIcon = Icons.check;
          break;
        case 'medium':
          badgeColor = Colors.blue;
          badgeText = 'OK';
          badgeIcon = Icons.info;
          break;
        default:
          badgeColor = Colors.grey;
          badgeText = 'LOW';
          badgeIcon = Icons.help_outline;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDetails(Map<String, dynamic> item, bool isTargetItem) {
    final details = <Widget>[];

    // Target-specific enhancements
    if (isTargetItem) {
      details.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.store, size: 14, color: Colors.red),
              SizedBox(width: 4),
              Text(
                'Target Receipt',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.red,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    // Item number/DPCI/TCIN
    final itemNumber =
        item['item_number'] ?? item['dpci'] ?? item['tcin'] ?? '';
    if (itemNumber.isNotEmpty) {
      details.add(
        Chip(
          label: Text(
            'ID: $itemNumber',
            style: const TextStyle(fontSize: 10),
          ),
          backgroundColor: Colors.blue[50],
          side: BorderSide(color: Colors.blue[200]!),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      );
    }

    // RedCircle enhancement indicator
    if (item['enhanced_with_redcircle'] == true) {
      details.add(
        Chip(
          label: const Text(
            'RedCircle Enhanced',
            style: TextStyle(fontSize: 10),
          ),
          backgroundColor: Colors.green[50],
          side: BorderSide(color: Colors.green[200]!),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      );
    }

    // Extraction method indicator
    final extractionMethod = item['extraction_method'] ?? '';
    if (extractionMethod.isNotEmpty && extractionMethod != 'demo') {
      String methodLabel;
      Color methodColor;

      switch (extractionMethod) {
        case 'structured_data':
          methodLabel = 'API Data';
          methodColor = Colors.green;
          break;
        case 'text_parsing':
          methodLabel = 'Text Parsed';
          methodColor = Colors.orange;
          break;
        default:
          methodLabel = 'Processed';
          methodColor = Colors.blue;
      }

      details.add(
        Chip(
          label: Text(
            methodLabel,
            style: const TextStyle(fontSize: 10),
          ),
          backgroundColor: methodColor.withAlpha(26),
          side: BorderSide(color: methodColor.withAlpha(77)),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      );
    }

    if (details.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: details,
    );
  }
}
