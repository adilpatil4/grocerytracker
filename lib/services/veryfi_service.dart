import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class VeryfiService {
  static const String baseUrl =
      'https://api.veryfi.com/api/v8/partner/documents';

  // Environment variables
  static const String clientId = String.fromEnvironment('VERYFI_CLIENT_ID');
  static const String clientSecret =
      String.fromEnvironment('VERYFI_CLIENT_SECRET');
  static const String username = String.fromEnvironment('VERYFI_USERNAME');
  static const String apiKey = String.fromEnvironment('VERYFI_API_KEY');

  final Dio _dio = Dio();

  VeryfiService() {
    _validateEnvironmentVariables();
    _setupDio();
  }

  void _validateEnvironmentVariables() {
    if (clientId.isEmpty) {
      throw Exception(
          'VERYFI_CLIENT_ID is not configured. Please check your env.json file.');
    }
    if (clientSecret.isEmpty) {
      throw Exception(
          'VERYFI_CLIENT_SECRET is not configured. Please check your env.json file.');
    }
    if (username.isEmpty) {
      throw Exception(
          'VERYFI_USERNAME is not configured. Please check your env.json file.');
    }
    if (apiKey.isEmpty) {
      throw Exception(
          'VERYFI_API_KEY is not configured. Please check your env.json file.');
    }
  }

  void _setupDio() {
    // Extended timeouts for better reliability
    _dio.options.connectTimeout = const Duration(seconds: 45);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.sendTimeout = const Duration(seconds: 60);

    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'GrocerEase-Flutter/1.0',
    };

    // Add interceptors for better error handling and logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            print('🔄 Veryfi API Request: ${options.method} ${options.uri}');
            print('📊 Request Headers: ${options.headers}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('✅ Veryfi API Response: ${response.statusCode}');
          }
          handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print('❌ Veryfi API Error: ${e.type} - ${e.message}');
            print('📍 Error Details: ${e.response?.data}');
          }
          handler.next(e);
        },
      ),
    );
  }

  /// Test API connectivity and credentials
  Future<bool> testApiConnection() async {
    try {
      final timestamp =
          (DateTime.now().millisecondsSinceEpoch / 1000).floor().toString();
      final httpVerb = 'GET';
      final requestPath = '/api/v8/partner/documents';
      final body = '';

      final signature =
          _generateSignature(timestamp, httpVerb, requestPath, body);

      final headers = {
        'CLIENT-ID': clientId,
        'AUTHORIZATION': 'apikey $username:$apiKey',
        'X-VERYFI-REQUEST-TIMESTAMP': timestamp,
        'X-VERYFI-REQUEST-SIGNATURE': signature,
        'Accept': 'application/json',
      };

      final response = await _dio.get(
        '$baseUrl?limit=1',
        options: Options(headers: headers),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Veryfi API connection test failed: $e');
      }
      return false;
    }
  }

  /// Generate Veryfi signature for authentication
  String _generateSignature(
      String timestamp, String httpVerb, String requestPath, String body) {
    final payloadString = '$timestamp,$httpVerb,$requestPath,$body';

    final key = utf8.encode(clientSecret);
    final bytes = utf8.encode(payloadString);

    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);

    return digest.toString();
  }

  /// Process receipt image using Veryfi OCR with enhanced error handling
  Future<Map<String, dynamic>> processReceipt({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      // REMOVE THE WEB BLOCKING - Let the API call attempt and handle CORS properly
      if (kDebugMode) {
        print('🔄 Starting Veryfi processing for: $fileName');
        print('📊 Image size: ${imageBytes.length} bytes');
      }

      // Pre-flight connectivity check with timeout
      final connectivityFuture = testApiConnection();
      final isConnected = await connectivityFuture.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (kDebugMode) {
            print('⚠️ Connectivity test timeout - proceeding with API call');
          }
          return true; // Proceed anyway - let the main API call handle the real test
        },
      );

      if (!isConnected && !kIsWeb) {
        throw VeryfiException(
            'Unable to connect to Veryfi API. Please check your internet connection and API credentials.');
      }

      final timestamp =
          (DateTime.now().millisecondsSinceEpoch / 1000).floor().toString();
      final httpVerb = 'POST';
      final requestPath = '/api/v8/partner/documents';

      // Validate image size (Veryfi has size limits)
      if (imageBytes.length > 20 * 1024 * 1024) {
        // 20MB limit
        throw VeryfiException('Image file too large. Maximum size is 20MB.');
      }

      // Convert image to base64
      final base64Image = base64Encode(imageBytes);

      final body = jsonEncode({
        'file_name': fileName,
        'file_data': base64Image,
        'boost_mode': 1,
        'external_id': 'grocerease_${DateTime.now().millisecondsSinceEpoch}',
        'max_pages_to_process': 1,
        'categories': ['Grocery', 'Food & Dining'],
        'auto_delete': false,
      });

      final signature =
          _generateSignature(timestamp, httpVerb, requestPath, body);

      final headers = {
        'CLIENT-ID': clientId,
        'AUTHORIZATION': 'apikey $username:$apiKey',
        'X-VERYFI-REQUEST-TIMESTAMP': timestamp,
        'X-VERYFI-REQUEST-SIGNATURE': signature,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (kDebugMode) {
        print('🚀 Making Veryfi API request to: $baseUrl');
        print('📋 Request headers: ${headers.keys.toList()}');
      }

      final response = await _dio.post(
        baseUrl,
        data: body,
        options: Options(headers: headers),
      );

      if (kDebugMode) {
        print('✅ Veryfi API responded with status: ${response.statusCode}');
        print('📄 Response data keys: ${response.data?.keys?.toList()}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw VeryfiException(
            'Failed to process receipt: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMsg = _handleDioError(e);
      if (kDebugMode) {
        print('❌ Veryfi DioException: $errorMsg');
        print('📍 Full error: ${e.toString()}');
        print('📍 Response data: ${e.response?.data}');
      }
      throw VeryfiException(errorMsg);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Veryfi unexpected error: $e');
      }
      if (e is VeryfiException) {
        rethrow;
      }
      throw VeryfiException('Unexpected error during OCR processing: $e');
    }
  }

  /// Get document by ID
  Future<Map<String, dynamic>> getDocument(String documentId) async {
    try {
      final timestamp =
          (DateTime.now().millisecondsSinceEpoch / 1000).floor().toString();
      final httpVerb = 'GET';
      final requestPath = '/api/v8/partner/documents/$documentId';
      final body = '';

      final signature =
          _generateSignature(timestamp, httpVerb, requestPath, body);

      final headers = {
        'CLIENT-ID': clientId,
        'AUTHORIZATION': 'apikey $username:$apiKey',
        'X-VERYFI-REQUEST-TIMESTAMP': timestamp,
        'X-VERYFI-REQUEST-SIGNATURE': signature,
        'Accept': 'application/json',
      };

      final response = await _dio.get(
        '$baseUrl/$documentId',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw VeryfiException('Failed to get document: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw VeryfiException(_handleDioError(e));
    } catch (e) {
      throw VeryfiException('Unexpected error: $e');
    }
  }

  /// Transform Veryfi response to app format with enhanced Target receipt support
  List<Map<String, dynamic>> transformVeryfiResponse(
      Map<String, dynamic> veryfiData) {
    final items = <Map<String, dynamic>>[];

    try {
      // Primary extraction from line_items
      final lineItems = veryfiData['line_items'] as List?;

      if (lineItems != null && lineItems.isNotEmpty) {
        for (int i = 0; i < lineItems.length; i++) {
          final item = lineItems[i] as Map<String, dynamic>;
          items.add(_createItemFromVeryfiData(item, i + 1));
        }

        if (kDebugMode) {
          print('✅ Extracted ${items.length} items from line_items');
        }
        return items;
      }

      // Enhanced fallback extraction for different receipt formats
      if (kDebugMode) {
        print(
            '⚠️ No line_items found, trying alternative extraction methods...');
      }

      // Try extracting from other possible fields
      items.addAll(_extractFromAlternativeFields(veryfiData));

      // If still no items, try parsing raw text with Target receipt patterns
      if (items.isEmpty) {
        items.addAll(_extractFromRawText(veryfiData));
      }

      if (kDebugMode) {
        print('📊 Final extraction result: ${items.length} items found');
        if (items.isNotEmpty) {
          print('🔍 First item example: ${items.first}');
        }
      }

      return items;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error transforming Veryfi response: $e');
        print('📄 Raw response keys: ${veryfiData.keys}');
      }
      return [];
    }
  }

  /// Create item from Veryfi data with enhanced Target support
  Map<String, dynamic> _createItemFromVeryfiData(
      Map<String, dynamic> item, int id) {
    return {
      'id': id,
      'name':
          _cleanItemName(item['description'] ?? item['text'] ?? 'Unknown Item'),
      'quantity': _extractQuantity(item),
      'price': _formatPrice(item['total'] ?? item['amount'] ?? item['price']),
      'category': _categorizeItem(item['description'] ?? item['text'] ?? ''),
      'storage': _determineStorage(item['description'] ?? item['text'] ?? ''),
      'sku': item['sku'] ?? item['product_code'] ?? '',
      'item_number': _extractItemNumber(item),
      'original_veryfi_data': item,
      'vendor_info': item['vendor'] ?? {},
    };
  }

  /// Enhanced extraction from alternative fields for Target receipts
  List<Map<String, dynamic>> _extractFromAlternativeFields(
      Map<String, dynamic> veryfiData) {
    final items = <Map<String, dynamic>>[];

    try {
      // Check for items in different possible locations
      final possibleItemFields = [
        'items',
        'products',
        'receipt_items',
        'purchased_items',
        'line_item',
        'transaction_items',
        'itemization'
      ];

      for (final field in possibleItemFields) {
        final itemsData = veryfiData[field];
        if (itemsData is List && itemsData.isNotEmpty) {
          if (kDebugMode) {
            print('✅ Found items in field: $field');
          }
          for (int i = 0; i < itemsData.length; i++) {
            if (itemsData[i] is Map<String, dynamic>) {
              items.add(_createItemFromVeryfiData(
                  itemsData[i] as Map<String, dynamic>, i + 1));
            }
          }
          break;
        }
      }

      // Try to extract from vendor-specific formats
      if (items.isEmpty) {
        items.addAll(_extractFromVendorSpecificFormat(veryfiData));
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error in alternative extraction: $e');
      }
    }

    return items;
  }

  /// Extract from vendor-specific formats (Target, Walmart, etc.)
  List<Map<String, dynamic>> _extractFromVendorSpecificFormat(
      Map<String, dynamic> veryfiData) {
    final items = <Map<String, dynamic>>[];

    try {
      final vendor = veryfiData['vendor'] as Map<String, dynamic>?;
      final vendorName = vendor?['name']?.toString().toLowerCase() ?? '';

      // Target-specific extraction
      if (vendorName.contains('target')) {
        items.addAll(_extractTargetItems(veryfiData));
      }

      // Generic vendor extraction fallback
      if (items.isEmpty) {
        final total = veryfiData['total'] ?? 0.0;
        if (total > 0) {
          items.add({
            'id': 1,
            'name': 'Receipt Items - Total Amount',
            'quantity': '1',
            'price': _formatPrice(total),
            'category': 'general',
            'storage': 'pantry',
            'sku': '',
            'item_number': '',
            'original_veryfi_data': veryfiData,
            'needs_manual_review': true,
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error in vendor-specific extraction: $e');
      }
    }

    return items;
  }

  /// Target-specific item extraction
  List<Map<String, dynamic>> _extractTargetItems(
      Map<String, dynamic> veryfiData) {
    final items = <Map<String, dynamic>>[];

    try {
      // Look for Target-specific fields
      final targetFields = ['target_items', 'tcin_items', 'dpci_items'];

      for (final field in targetFields) {
        final targetItems = veryfiData[field];
        if (targetItems is List && targetItems.isNotEmpty) {
          for (int i = 0; i < targetItems.length; i++) {
            items.add(_createItemFromVeryfiData(
                targetItems[i] as Map<String, dynamic>, i + 1));
          }
          break;
        }
      }

      if (kDebugMode) {
        print('🎯 Target-specific extraction found: ${items.length} items');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error in Target extraction: $e');
      }
    }

    return items;
  }

  /// Enhanced raw-text extraction with improved Target receipt parsing
  List<Map<String, dynamic>> _extractFromRawText(
      Map<String, dynamic> veryfiData) {
    final items = <Map<String, dynamic>>[];

    try {
      final rawText =
          (veryfiData['ocr_text'] ?? veryfiData['text'] ?? '').toString();
      if (rawText.isEmpty) return items;

      final lines = rawText
          .replaceAll('\\u2013', '-') // en dash
          .replaceAll('\\u2014', '-') // em dash
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      final reDpci = RegExp(r'\b(\d{3}-\d{2}-\d{4})\b'); // DPCI
      final reTcin =
          RegExp(r'\bTCIN[:\s]*([0-9]{6,12})\b', caseSensitive: false);
      final reQtyAt = RegExp(r'\b(\d+)\s*@\s*(\d+\.\d{2})\b'); // "2 @ 3.49"
      final reXQty = RegExp(r'\bx\s*(\d+)\b', caseSensitive: false); // "x2"
      final rePrice = RegExp(r'(\$?\d+\.\d{2})'); // prices
      final reDiscount = RegExp(r'(target\s*circle|coupon|mfr|promo|cartwheel)',
          caseSensitive: false);
      final reTotals = RegExp(
          r'\b(subtotal|total|tax|change|tender|balance due|amount tendered)\b',
          caseSensitive: false);

      // Enhanced item detection - more flexible patterns
      bool looksLikeNewItem(String line) {
        // Skip obvious non-item lines
        if (reTotals.hasMatch(line) ||
            line.toLowerCase().contains('thank you') ||
            line.toLowerCase().contains('receipt') ||
            line.length < 3) {
          return false;
        }

        final endsWithPrice = RegExp(r'\d+\.\d{2}\s*$').hasMatch(line);
        final hasQtyAt = reQtyAt.hasMatch(line);
        final hasAlphaAndPrice =
            RegExp(r'[a-zA-Z]').hasMatch(line) && rePrice.hasMatch(line);

        return (endsWithPrice || hasQtyAt || hasAlphaAndPrice) &&
            line.length >= 3;
      }

      Map<String, dynamic>? current;
      int nextId = 1;

      void flushCurrent() {
        if (current == null) return;

        // Enhanced validation before adding
        final name = current!['name']?.toString().trim() ?? '';
        if (name.isNotEmpty && name.length >= 2) {
          final qty = int.tryParse('${current!['quantity'] ?? '1'}') ?? 1;
          final priceStr =
              (current!['price'] ?? '').toString().replaceAll('\$', '');
          if (priceStr.isNotEmpty) {
            final price = double.tryParse(priceStr);
            if (price != null && qty > 1 && (current!['unit_price'] == null)) {
              current!['unit_price'] = (price / qty).toStringAsFixed(2);
            }
          }
          items.add(current!);
        }
        current = null;
      }

      for (final line in lines) {
        if (looksLikeNewItem(line)) {
          flushCurrent();

          int qty = 1;
          double? unit;
          double? total;
          final prices = rePrice
              .allMatches(line)
              .map((m) => m.group(1)!.replaceAll('\$', ''))
              .toList();

          final mQtyAt = reQtyAt.firstMatch(line);
          if (mQtyAt != null) {
            qty = int.tryParse(mQtyAt.group(1)!) ?? 1;
            unit = double.tryParse(mQtyAt.group(2)!);
            if (prices.isNotEmpty) total = double.tryParse(prices.last);
          } else {
            final mX = reXQty.firstMatch(line);
            if (mX != null) qty = int.tryParse(mX.group(1)!) ?? 1;

            if (prices.length == 1) {
              final p = double.tryParse(prices.first);
              if (p != null) {
                if (qty > 1) {
                  total = p;
                  unit = double.parse((p / qty).toStringAsFixed(2));
                } else {
                  unit = p;
                  total = p;
                }
              }
            } else if (prices.length >= 2) {
              unit = double.tryParse(prices.first);
              total = double.tryParse(prices.last);
            }
          }

          String name = line
              .replaceAll(reQtyAt, '')
              .replaceAll(reXQty, '')
              .replaceAll(RegExp(r'\$?\d+\.\d{2}'), '')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();

          // Enhanced name cleaning
          name = name.replaceAll(RegExp(r'^[^a-zA-Z]+'), '').trim();

          if (name.length >= 2) {
            // Minimum name length
            current = {
              'id': nextId++,
              'name': name,
              'quantity': '$qty',
              'price': total != null
                  ? '\$${total.toStringAsFixed(2)}'
                  : (unit != null ? '\$${unit.toStringAsFixed(2)}' : ''),
              'unit_price': unit?.toStringAsFixed(2),
              'category': _categorizeItem(name),
              'storage': _determineStorage(name),
              'sku': '',
              'item_number': '',
              'adjustments': <String>[],
              'original_veryfi_data': {'raw_line': line},
              'extracted_from_text': true,
              'store_type': 'target',
            };
          }
        } else if (current != null) {
          final mDpci = reDpci.firstMatch(line);
          final mTcin = reTcin.firstMatch(line);

          if (mDpci != null) {
            current!['dpci'] = mDpci.group(1)!;
            current!['item_number'] =
                current!['item_number'] ?? mDpci.group(1)!;
          } else if (mTcin != null) {
            current!['tcin'] = mTcin.group(1)!;
            current!['item_number'] =
                current!['item_number'] ?? mTcin.group(1)!;
          } else if (reDiscount.hasMatch(line) || rePrice.hasMatch(line)) {
            (current!['adjustments'] as List<String>).add(line);
          } else if (!reTotals.hasMatch(line) && line.length < 50) {
            // Only add reasonable length continuation lines
            final cleanLine =
                line.replaceAll(RegExp(r'[^a-zA-Z0-9\s&-]'), ' ').trim();
            if (cleanLine.isNotEmpty && cleanLine.length >= 2) {
              current!['name'] = '${current!['name']} $cleanLine'.trim();
            }
          }
        }
      }
      flushCurrent();

      if (kDebugMode) {
        print('📊 Text extraction completed: ${items.length} items found');
        if (items.isNotEmpty) {
          print(
              '🔍 Sample extracted item: ${items.first['name']} - ${items.first['price']}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error in text extraction: $e');
      }
    }

    return items;
  }

  /// Enhanced item number extraction with better Target support
  String _extractItemNumber(Map<String, dynamic> item) {
    final candidates = <String?>[
      item['tcin']?.toString(),
      item['dpci']?.toString(),
      item['upc']?.toString(),
      item['sku']?.toString(),
      item['product_code']?.toString(),
      item['item_code']?.toString(),
      item['barcode']?.toString(),
      item['item_number']?.toString(),
      item['product_number']?.toString(),
    ].where((e) => e != null && e.trim().isNotEmpty).cast<String>().toList();

    if (candidates.isEmpty) return '';

    // Prioritize DPCI format for Target
    final dpciRe = RegExp(r'\b(\d{3}-\d{2}-\d{4})\b');
    for (final candidate in candidates) {
      final match = dpciRe.firstMatch(candidate);
      if (match != null) return match.group(1)!;
    }

    // Look for TCIN format
    final tcinRe = RegExp(r'\b(\d{6,12})\b');
    for (final candidate in candidates) {
      final match = tcinRe.firstMatch(candidate);
      if (match != null) {
        final tcin = match.group(1)!;
        // Validate TCIN length (typically 8-12 digits)
        if (tcin.length >= 6 && tcin.length <= 12) {
          return tcin;
        }
      }
    }

    // Fallback: clean the first candidate
    return candidates.first.replaceAll(RegExp(r'[^0-9-]'), '');
  }

  String _cleanItemName(String name) {
    return name
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^[^a-zA-Z]+'), '')
        .trim();
  }

  String _extractQuantity(Map<String, dynamic> item) {
    final quantity = item['quantity'] ?? 1;
    final unit = item['unit_of_measure'] ?? '';

    if (unit.isNotEmpty) {
      return '$quantity $unit';
    }
    return quantity.toString();
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '\$0.00';
    final priceValue = double.tryParse(price.toString()) ?? 0.0;
    return '\$${priceValue.toStringAsFixed(2)}';
  }

  String _categorizeItem(String description) {
    final desc = description.toLowerCase();

    if (desc.contains(RegExp(r'\b(milk|cheese|yogurt|butter|cream)\b')))
      return 'dairy';
    if (desc.contains(RegExp(r'\b(apple|banana|orange|grape|berry|fruit)\b')))
      return 'produce';
    if (desc.contains(RegExp(r'\b(beef|chicken|pork|fish|meat|turkey)\b')))
      return 'meat';
    if (desc.contains(RegExp(r'\b(bread|bagel|muffin|croissant|bakery)\b')))
      return 'bakery';
    if (desc.contains(RegExp(r'\b(frozen|ice cream|pizza)\b'))) return 'frozen';
    if (desc.contains(RegExp(r'\b(soda|juice|water|drink|beverage)\b')))
      return 'beverages';

    return 'general';
  }

  String _determineStorage(String description) {
    final category = _categorizeItem(description);

    switch (category) {
      case 'dairy':
      case 'meat':
        return 'fridge';
      case 'frozen':
        return 'freezer';
      default:
        return 'pantry';
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection and try again.';
      case DioExceptionType.sendTimeout:
        return 'Upload timeout. The image might be too large or connection is slow.';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout. The server is taking too long to process your request.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 400) {
          return 'Invalid request. Please check the image format and try again.';
        } else if (statusCode == 401) {
          return 'Invalid Veryfi credentials. Please check your API keys in env.json file.';
        } else if (statusCode == 403) {
          return 'Access forbidden. Your API account may have insufficient permissions.';
        } else if (statusCode == 429) {
          return 'Too many requests. Please wait a moment before trying again.';
        } else if (statusCode == 500) {
          return 'Veryfi server error. Please try again later.';
        }
        return 'Server error: $statusCode. Please try again later.';
      case DioExceptionType.cancel:
        return 'Request was cancelled. Please try again.';
      case DioExceptionType.unknown:
        if (e.error.toString().contains('XMLHttpRequest')) {
          return 'Network connection error. This may be due to CORS restrictions on web platform. Please check your API configuration in env.json file.';
        }
        return 'Network error. Please check your internet connection and try again.';
      default:
        return 'Request failed: ${e.message ?? 'Unknown error'}. Please check your API configuration in env.json file.';
    }
  }
}

class VeryfiException implements Exception {
  final String message;
  VeryfiException(this.message);

  @override
  String toString() => 'VeryfiException: $message';
}
