import 'package:flutter/foundation.dart';

import './redcircle_service.dart';
import './veryfi_service.dart';

class ReceiptProcessingService {
  final VeryfiService _veryfiService = VeryfiService();
  final RedCircleService _redCircleService = RedCircleService();

  /// Process receipt image with full OCR and item enhancement
  Future<List<Map<String, dynamic>>> processReceiptImage({
    required Uint8List imageBytes,
    required String fileName,
    Function(String)? onProgressUpdate,
  }) async {
    try {
      // Pre-processing validation
      onProgressUpdate?.call('Validating image...');

      if (imageBytes.isEmpty) {
        throw ReceiptProcessingException('Image data is empty');
      }

      if (kDebugMode) {
        print('🎯 Processing receipt: $fileName (${imageBytes.length} bytes)');
      }

      // ENHANCED: Check API connectivity first with detailed logging
      onProgressUpdate?.call('Testing API connectivity...');
      final isVeryfiConnected = await _checkVeryfiConnection();
      final isRedCircleConnected = await _checkRedCircleConnection();

      if (kDebugMode) {
        print(
            '🔗 API Status - Veryfi: ${isVeryfiConnected ? "✅" : "❌"}, RedCircle: ${isRedCircleConnected ? "✅" : "❌"}');
      }

      // If we're on web and APIs aren't working, provide helpful error
      if (kIsWeb && !isVeryfiConnected) {
        throw ReceiptProcessingException(
            'Web platform CORS restriction detected. '
            'Receipt scanning requires server-side API calls or CORS proxy. '
            'The APIs are configured correctly but blocked by browser security policies.');
      }

      // Step 1: OCR Processing with Veryfi
      onProgressUpdate?.call('Analyzing receipt with OCR...');

      Map<String, dynamic> veryfiResponse;
      try {
        veryfiResponse = await _veryfiService.processReceipt(
          imageBytes: imageBytes,
          fileName: fileName,
        );

        if (kDebugMode) {
          print('✅ Veryfi processing successful');
          print('📄 Response keys: ${veryfiResponse.keys.toList()}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Veryfi processing failed: $e');
        }

        // Provide more specific error information
        if (e.toString().contains('CORS')) {
          throw ReceiptProcessingException(
              'CORS Error: Browser blocked the API request. '
              'This is a web platform limitation. Try the mobile app or contact support for server-side processing setup.');
        } else if (e.toString().contains('401')) {
          throw ReceiptProcessingException(
              'Authentication Failed: Veryfi API credentials are invalid. '
              'Please verify your VERYFI_CLIENT_ID, VERYFI_CLIENT_SECRET, VERYFI_USERNAME, and VERYFI_API_KEY in env.json.');
        } else if (e.toString().contains('Network')) {
          throw ReceiptProcessingException(
              'Network Error: Cannot reach Veryfi API servers. '
              'Please check your internet connection and try again.');
        }

        rethrow;
      }

      // Step 2: Transform Veryfi data to app format
      onProgressUpdate?.call('Extracting line items...');

      final items = _veryfiService.transformVeryfiResponse(veryfiResponse);

      if (items.isEmpty) {
        // Try to get more information about why extraction failed
        final hasOcrText =
            veryfiResponse['ocr_text']?.toString().isNotEmpty ?? false;
        final hasLineItems = veryfiResponse['line_items'] is List &&
            (veryfiResponse['line_items'] as List).isNotEmpty;

        String detailedError = 'No items found in receipt. ';
        if (!hasOcrText) {
          detailedError +=
              'OCR text extraction failed - the image may be too blurry or low quality.';
        } else if (!hasLineItems) {
          detailedError +=
              'Receipt format not recognized - try a clearer image or different receipt.';
        } else {
          detailedError +=
              'Item parsing failed - receipt format may be unsupported.';
        }

        throw ReceiptProcessingException(detailedError);
      }

      if (kDebugMode) {
        print('📊 Extracted ${items.length} items from Veryfi');
      }

      // Step 3: Enhance items with RedCircle data for Target receipts
      onProgressUpdate?.call('Enhancing item details...');

      final enhancedItems =
          await _enhanceItemsWithRedCircle(items, onProgressUpdate);

      // Step 4: Post-process and validate items
      onProgressUpdate?.call('Finalizing items...');

      final finalItems = _postProcessItems(enhancedItems);

      if (kDebugMode) {
        print('🎉 Processing complete: ${finalItems.length} items');
        final enhancedCount = finalItems
            .where((item) => item['enhanced_with_redcircle'] == true)
            .length;
        print('✨ Enhanced with RedCircle: $enhancedCount items');
      }

      return finalItems;
    } catch (e) {
      if (kDebugMode) {
        print('💥 Receipt processing failed: $e');
      }

      if (e is ReceiptProcessingException) {
        rethrow;
      } else if (e is VeryfiException) {
        // Convert VeryfiException to ReceiptProcessingException with more context
        throw ReceiptProcessingException('OCR Processing Failed: ${e.message}');
      } else {
        throw ReceiptProcessingException('Unexpected processing error: $e');
      }
    }
  }

  /// Enhanced Veryfi connectivity check
  Future<bool> _checkVeryfiConnection() async {
    try {
      return await _veryfiService.testApiConnection().timeout(
            const Duration(seconds: 10),
            onTimeout: () => false,
          );
    } catch (e) {
      if (kDebugMode) {
        print('🔗 Veryfi connection check failed: $e');
      }
      return false;
    }
  }

  /// Enhanced RedCircle connectivity check
  Future<bool> _checkRedCircleConnection() async {
    try {
      return await _redCircleService.testApiConnection().timeout(
            const Duration(seconds: 10),
            onTimeout: () => false,
          );
    } catch (e) {
      if (kDebugMode) {
        print('🔗 RedCircle connection check failed: $e');
      }
      return false;
    }
  }

  /// Fallback processing for web platform - REMOVED AUTOMATIC FALLBACK
  Future<List<Map<String, dynamic>>> _processReceiptForWeb(
    Uint8List imageBytes,
    String fileName,
    Function(String)? onProgressUpdate,
  ) async {
    // This method is now only called explicitly, not automatically
    throw ReceiptProcessingException(
        'Web platform fallback requested. This indicates the main processing failed due to CORS restrictions. '
        'Consider implementing a server-side proxy for production use.');
  }

  /// Enhanced connectivity check
  Future<bool> checkApiConnectivity() async {
    try {
      if (kIsWeb) {
        // Web platform - skip actual API check
        return false;
      }

      final isVeryfiConnected = await _veryfiService.testApiConnection();
      final isRedCircleConnected = await _redCircleService.testApiConnection();

      if (kDebugMode) {
        print(
            '🔗 Veryfi API: ${isVeryfiConnected ? "Connected" : "Disconnected"}');
        print(
            '🔗 RedCircle API: ${isRedCircleConnected ? "Connected" : "Disconnected"}');
      }

      return isVeryfiConnected;
    } catch (e) {
      if (kDebugMode) {
        print('❌ API connectivity check failed: $e');
      }
      return false;
    }
  }

  /// Enhance items with RedCircle API data
  Future<List<Map<String, dynamic>>> _enhanceItemsWithRedCircle(
    List<Map<String, dynamic>> items,
    Function(String)? onProgressUpdate,
  ) async {
    final enhancedItems = <Map<String, dynamic>>[];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      onProgressUpdate?.call('Enhancing item ${i + 1} of ${items.length}...');

      try {
        // Check if this looks like a Target receipt item
        final isTargetItem = _isTargetReceiptItem(item);

        if (isTargetItem) {
          final enhancedItem =
              await _redCircleService.enhanceItemWithRedCircleData(item);
          enhancedItems.add(enhancedItem);
        } else {
          // For non-Target items, just add basic enhancements
          enhancedItems.add(_addBasicEnhancements(item));
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error enhancing item ${item['name']}: $e');
        }

        // Add item without enhancement if API fails
        enhancedItems.add(_addBasicEnhancements(item));
      }

      // Add small delay to avoid rate limiting
      if (i < items.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    return enhancedItems;
  }

  /// Check if item is from Target receipt with enhanced detection
  bool _isTargetReceiptItem(Map<String, dynamic> item) {
    final veryfiData = item['original_veryfi_data'] as Map<String, dynamic>?;

    // 1) Vendor checks from Veryfi
    final vendorName =
        (veryfiData?['vendor']?['name'] ?? veryfiData?['vendor_name'] ?? '')
            .toString()
            .toLowerCase();
    final vendorAddress =
        (veryfiData?['vendor']?['address'] ?? '').toString().toLowerCase();

    if (vendorName.contains('target') || vendorAddress.contains('target')) {
      if (kDebugMode) print('🎯 Target receipt detected via vendor info');
      return true;
    }

    // 2) Store number heuristic (Target stores often have 4-digit numbers)
    final storeInfo = veryfiData?['store_number']?.toString() ?? '';
    if (storeInfo.isNotEmpty && RegExp(r'^[T]?\d{4}$').hasMatch(storeInfo)) {
      if (kDebugMode)
        print('🎯 Target receipt detected via store number: $storeInfo');
      return true;
    }

    // 3) Item-number patterns: DPCI and TCIN with enhanced detection
    final itemNumber = (item['item_number'] ?? '').toString();
    final hasDpci = RegExp(r'^\d{3}-\d{2}-\d{4}$').hasMatch(itemNumber);
    final looksLikeTcin = RegExp(r'^\d{6,12}$').hasMatch(itemNumber);

    // Check for DPCI/TCIN in multiple fields
    final dpciPresent = (item['dpci']?.toString().isNotEmpty ?? false);
    final tcinPresent = (item['tcin']?.toString().isNotEmpty ?? false);

    if (hasDpci || looksLikeTcin || dpciPresent || tcinPresent) {
      if (kDebugMode) print('🎯 Target item by ID pattern: $itemNumber');
      return true;
    }

    // 4) Enhanced house-brand detection for Target
    final name = (item['name'] ?? '').toString().toLowerCase();
    const targetBrands = [
      'good & gather',
      'good&gather',
      'market pantry',
      'up & up',
      'up&up',
      'favorite day',
      'archer farms',
      'room essentials',
      'simply balanced', // legacy brand
      'threshold', // home brand
      'cat & jack', // kids brand
    ];

    for (final brand in targetBrands) {
      if (name.contains(brand)) {
        if (kDebugMode) print('🎯 Target item via brand: $brand');
        return true;
      }
    }

    // 5) Receipt format patterns specific to Target
    if (item['extracted_from_text'] == true) {
      final rawLine = veryfiData?['raw_line']?.toString().toLowerCase() ?? '';

      // Target-specific receipt patterns
      if (rawLine.contains('cartwheel') ||
          rawLine.contains('target circle') ||
          rawLine.contains('redcard') ||
          rawLine.contains('t-circle')) {
        if (kDebugMode) print('🎯 Target item via receipt text patterns');
        return true;
      }
    }

    // 6) Price pattern analysis - Target often uses specific pricing
    final priceStr = (item['price'] ?? '').toString();
    final price = double.tryParse(priceStr.replaceAll('\$', ''));
    if (price != null) {
      // Target often has prices ending in .99, .49, .29, .79
      final cents = ((price % 1) * 100).round();
      if ([99, 49, 29, 79, 89].contains(cents) && price >= 1.0) {
        // Additional validation for Target-specific context
        if (name.isNotEmpty && name.length > 3) {
          if (kDebugMode)
            print(
                '🎯 Target item via price pattern: \$${price.toStringAsFixed(2)}');
          return true;
        }
      }
    }

    return false;
  }

  /// Add basic enhancements for non-Target items
  Map<String, dynamic> _addBasicEnhancements(Map<String, dynamic> item) {
    final enhanced = Map<String, dynamic>.from(item);

    // Add confidence scores
    enhanced['confidence_score'] = 'medium';

    // Improve category detection
    final improvedCategory = _improveCategory(
        item['name']?.toString() ?? '', item['category']?.toString() ?? '');
    if (improvedCategory != item['category']) {
      enhanced['refined_category'] = improvedCategory;
    }

    // Add storage recommendation
    enhanced['storage_recommendation'] = _getStorageRecommendation(
        enhanced['refined_category'] ?? enhanced['category'] ?? 'general');

    // Add basic nutritional flags
    enhanced['dietary_flags'] =
        _getDietaryFlags(item['name']?.toString() ?? '');

    return enhanced;
  }

  /// Improve category detection based on item name
  String _improveCategory(String itemName, String currentCategory) {
    final name = itemName.toLowerCase();

    // Specific product matching
    if (name.contains(RegExp(
        r'\b(organic|fresh|baby)\s+(spinach|lettuce|kale|arugula|salad)')))
      return 'produce';
    if (name.contains(RegExp(r'\b(greek|vanilla|strawberry|plain)\s+(yogurt)')))
      return 'dairy';
    if (name.contains(RegExp(r'\b(whole|2%|skim|almond|oat)\s+(milk)')))
      return 'dairy';
    if (name.contains(
        RegExp(r'\b(ground|lean|chuck|sirloin)\s+(beef|turkey|chicken)')))
      return 'meat';
    if (name.contains(
        RegExp(r'\b(whole\s+wheat|multigrain|sourdough)\s+(bread|roll)')))
      return 'bakery';
    if (name.contains(RegExp(r'\b(frozen)\s+(pizza|meal|vegetable|fruit)')))
      return 'frozen';
    if (name.contains(
        RegExp(r'\b(sparkling|mineral|coconut|orange|apple)\s+(water|juice)')))
      return 'beverages';

    // Return improved category or original
    return currentCategory;
  }

  /// Get storage recommendation based on category
  String _getStorageRecommendation(String category) {
    switch (category) {
      case 'dairy':
      case 'meat':
        return 'fridge';
      case 'frozen':
        return 'freezer';
      case 'produce':
        return 'fridge'; // Most produce items
      default:
        return 'pantry';
    }
  }

  /// Get dietary flags for item
  List<String> _getDietaryFlags(String itemName) {
    final flags = <String>[];
    final name = itemName.toLowerCase();

    if (name.contains(RegExp(r'\b(organic)\b'))) flags.add('organic');
    if (name.contains(RegExp(r'\b(gluten[-\s]?free)\b')))
      flags.add('gluten-free');
    if (name.contains(RegExp(r'\b(non[-\s]?dairy|vegan)\b')))
      flags.add('vegan');
    if (name.contains(RegExp(r'\b(low[-\s]?(fat|sodium|sugar))\b')))
      flags.add('health-conscious');
    if (name.contains(RegExp(r'\b(whole\s+grain|fiber)\b')))
      flags.add('high-fiber');

    return flags;
  }

  /// Post-process items for final validation and formatting with Target enhancement
  List<Map<String, dynamic>> _postProcessItems(
      List<Map<String, dynamic>> items) {
    final processedItems = <Map<String, dynamic>>[];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final processedItem = Map<String, dynamic>.from(item);

      // Ensure required fields
      processedItem['id'] = i + 1;

      // Clean up name
      if (processedItem['enhanced_name'] != null) {
        processedItem['display_name'] = processedItem['enhanced_name'];
      } else {
        processedItem['display_name'] = processedItem['name'];
      }

      // Use refined category if available
      if (processedItem['refined_category'] != null) {
        processedItem['category'] = processedItem['refined_category'];
      }

      // Set storage location
      if (processedItem['storage_recommendation'] != null) {
        processedItem['storage'] = processedItem['storage_recommendation'];
      }

      // Enhanced Target receipt processing
      if (_isTargetReceiptItem(processedItem)) {
        processedItem['store_type'] = 'target';
        processedItem['tcin'] = processedItem['item_number'];

        // Add Target-specific enhancements - FIX THE NULLABLE BOOL ISSUE
        final itemNumber = processedItem['item_number']?.toString() ?? '';
        if (itemNumber.isNotEmpty) {
          processedItem['redcircle_eligible'] = true;
        }
      }

      // Add processing timestamp
      processedItem['processed_at'] = DateTime.now().toIso8601String();

      // Add confidence indicator with Target-specific boost
      if (processedItem['enhanced_with_redcircle'] == true) {
        processedItem['confidence_score'] = 'high';
      } else if (processedItem['store_type'] == 'target' &&
          (processedItem['item_number']?.toString() ?? '').isNotEmpty) {
        processedItem['confidence_score'] = 'medium-high';
      } else if (processedItem['confidence_score'] == null) {
        processedItem['confidence_score'] = 'medium';
      }

      // Add extraction method tracking
      if (processedItem['extracted_from_text'] == true) {
        processedItem['extraction_method'] = 'text_parsing';
      } else if (processedItem['demo_data'] == true) {
        processedItem['extraction_method'] = 'demo';
      } else {
        processedItem['extraction_method'] = 'structured_data';
      }

      processedItems.add(processedItem);
    }

    if (kDebugMode) {
      final targetItems =
          processedItems.where((item) => item['store_type'] == 'target').length;
      print(
          '📊 Processing complete: ${processedItems.length} total items, $targetItems Target items');
    }

    return processedItems;
  }

  /// Get processing statistics
  Map<String, dynamic> getProcessingStats(List<Map<String, dynamic>> items) {
    final stats = <String, dynamic>{};

    final totalItems = items.length;
    final enhancedItems =
        items.where((item) => item['enhanced_with_redcircle'] == true).length;
    final highConfidenceItems =
        items.where((item) => item['confidence_score'] == 'high').length;
    final webFallbackItems =
        items.where((item) => item['web_fallback'] == true).length;

    // Category distribution
    final categoryCount = <String, int>{};
    for (final item in items) {
      final category = item['category']?.toString() ?? 'unknown';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }

    stats.addAll({
      'total_items': totalItems,
      'enhanced_items': enhancedItems,
      'high_confidence_items': highConfidenceItems,
      'web_fallback_items': webFallbackItems,
      'enhancement_rate':
          totalItems > 0 ? (enhancedItems / totalItems * 100).round() : 0,
      'confidence_rate':
          totalItems > 0 ? (highConfidenceItems / totalItems * 100).round() : 0,
      'category_distribution': categoryCount,
      'processed_at': DateTime.now().toIso8601String(),
      'platform': kIsWeb ? 'web' : 'mobile',
    });

    return stats;
  }
}

class ReceiptProcessingException implements Exception {
  final String message;
  ReceiptProcessingException(this.message);

  @override
  String toString() => 'ReceiptProcessingException: $message';
}
