import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class RedCircleService {
  static const String baseUrl = 'https://api.redcircleapi.com/request';

  // Environment variables
  static const String apiKey = String.fromEnvironment('REDCIRCLE_API_KEY');

  final Dio _dio = Dio();

  RedCircleService() {
    _validateEnvironmentVariables();
    _setupDio();
  }

  void _validateEnvironmentVariables() {
    if (apiKey.isEmpty) {
      throw Exception(
          'REDCIRCLE_API_KEY is not configured. Please check your env.json file.');
    }
  }

  void _setupDio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Get product details by Target item number
  // === REPLACEMENT START: redcircle_service.dart ===

  Future<Map<String, dynamic>?> getProductByItemNumber(
      String itemNumber) async {
    if (itemNumber.isEmpty) return null;

    String cleaned = _cleanItemNumber(itemNumber); // digits only
    final isNineDigits =
        RegExp(r'^\d{9}$').hasMatch(cleaned); // DPCI style (digits only)
    final looksLikeTcin =
        RegExp(r'^\d{6,12}$').hasMatch(cleaned); // TCIN-ish range

    try {
      // 1) If it looks like a TCIN, ask RedCircle for the product directly
      if (looksLikeTcin && !isNineDigits) {
        final byTcin = await _dio.get(
          baseUrl,
          queryParameters: {
            'api_key': apiKey,
            'type': 'product',
            'target_domain': 'target.com',
            'tcin': cleaned,
          },
        );
        if (byTcin.statusCode == 200 &&
            byTcin.data['request_info']['success'] == true) {
          return byTcin.data['product'];
        }
      }

      // 2) If it's DPCI (9 digits), search by DPCI text to obtain a TCIN, then re-query
      if (isNineDigits) {
        final search = await _dio.get(
          baseUrl,
          queryParameters: {
            'api_key': apiKey,
            'type': 'search',
            'target_domain': 'target.com',
            'search_term': itemNumber, // keep hyphens if provided upstream
            'max_page': '1',
          },
        );
        if (search.statusCode == 200 &&
            search.data['request_info']['success'] == true) {
          final results = (search.data['search_results'] as List?)
                  ?.cast<Map<String, dynamic>>() ??
              const [];
          if (results.isNotEmpty) {
            final first = results.first;
            final tcin = (first['tcin'] ??
                    first['product']?['tcin'] ??
                    first['product_id'])
                ?.toString();
            if (tcin != null && tcin.isNotEmpty) {
              final byTcin = await _dio.get(
                baseUrl,
                queryParameters: {
                  'api_key': apiKey,
                  'type': 'product',
                  'target_domain': 'target.com',
                  'tcin': tcin,
                },
              );
              if (byTcin.statusCode == 200 &&
                  byTcin.data['request_info']['success'] == true) {
                return byTcin.data['product'];
              }
            }
            // If no TCIN field, return the search doc so caller can at least enrich basic fields
            return first;
          }
        }
      }

      return null;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('RedCircle API error: ${_handleDioError(e)}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('RedCircle unexpected error: $e');
      }
      return null;
    }
  }

  /// Search for products by keyword
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await _dio.get(
        baseUrl,
        queryParameters: {
          'api_key': apiKey,
          'type': 'search',
          'target_domain': 'target.com',
          'search_term': query,
          'max_page': '1',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['request_info']['success'] == true) {
          final searchResults = data['search_results'] as List?;
          if (searchResults != null) {
            return searchResults.cast<Map<String, dynamic>>();
          }
        }
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('RedCircle search error: $e');
      }
      return [];
    }
  }

  /// Test API connectivity - FIXED ENDPOINT
  Future<bool> testApiConnection() async {
    try {
      if (kDebugMode) {
        print('🔗 Testing RedCircle API connectivity...');
      }

      final testResponse = await _dio.get(
        baseUrl, // Use the correct base URL
        queryParameters: {
          'api_key': apiKey,
          'type': 'product',
          'target_domain': 'target.com',
          'tcin': '13860428', // Test TCIN
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      final success = testResponse.statusCode == 200;
      if (kDebugMode) {
        print(
            '🔗 RedCircle API test result: ${success ? "✅ Connected" : "❌ Failed"}');
        if (!success) {
          print(
              '📍 Response: ${testResponse.statusCode} - ${testResponse.data}');
        }
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('❌ RedCircle API connection test failed: $e');
      }
      return false;
    }
  }

  /// Enhance item with RedCircle data
  Future<Map<String, dynamic>> enhanceItemWithRedCircleData(
      Map<String, dynamic> item) async {
    final enhancedItem = Map<String, dynamic>.from(item);

    try {
      String? tcin = (item['tcin'] ?? '').toString();
      String? dpci = (item['dpci'] ?? '').toString();
      String? itemNumber = (item['item_number'] ?? '').toString();

      // Normalize: if item_number is a hyphenated DPCI, adopt it as dpci
      if (dpci.isEmpty && RegExp(r'^\d{3}-\d{2}-\d{4}$').hasMatch(itemNumber)) {
        dpci = itemNumber;
      }

      Map<String, dynamic>? productData;

      if (tcin.isNotEmpty) {
        productData = await getProductByItemNumber(tcin);
      }
      if (productData == null && dpci.isNotEmpty) {
        productData = await getProductByItemNumber(dpci);
      }
      if (productData == null) {
        final itemName = item['name'] as String? ?? '';
        if (itemName.isNotEmpty) {
          final results = await searchProducts(itemName);
          if (results.isNotEmpty) {
            productData = results.first;
          }
        }
      }

      if (productData != null) {
        enhancedItem.addAll(_transformRedCircleProduct(productData));
        enhancedItem['enhanced_with_redcircle'] = true;
        enhancedItem['redcircle_data'] = productData;
        return enhancedItem;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error enhancing item with RedCircle data: $e');
      }
    }

    return enhancedItem;
  }
// === REPLACEMENT END ===

  /// Transform RedCircle product data to app format
  Map<String, dynamic> _transformRedCircleProduct(
      Map<String, dynamic> productData) {
    final enhancement = <String, dynamic>{};

    try {
      // Enhanced name
      final title = productData['title'];
      if (title != null && title.toString().isNotEmpty) {
        enhancement['enhanced_name'] = title.toString();
      }

      // Brand information
      final brand = productData['brand'];
      if (brand != null && brand.toString().isNotEmpty) {
        enhancement['brand'] = brand.toString();
      }

      // Description
      final description = productData['description'];
      if (description != null && description.toString().isNotEmpty) {
        enhancement['description'] = description.toString();
      }

      // Price information
      final price = productData['price'];
      if (price != null) {
        if (price is Map) {
          final currentPrice = price['current'];
          if (currentPrice != null) {
            enhancement['market_price'] = '\$${currentPrice.toString()}';
          }
        } else {
          enhancement['market_price'] = '\$${price.toString()}';
        }
      }

      // Images
      final images = productData['images'];
      if (images is List && images.isNotEmpty) {
        enhancement['product_images'] = images.cast<String>();
        enhancement['primary_image'] = images.first.toString();
      }

      // Nutritional information
      final nutrition = productData['nutrition_facts'];
      if (nutrition != null && nutrition is Map) {
        enhancement['nutrition_facts'] = nutrition;
      }

      // Ingredients
      final ingredients = productData['ingredients'];
      if (ingredients != null && ingredients.toString().isNotEmpty) {
        enhancement['ingredients'] = ingredients.toString();
      }

      // Category refinement
      final categoryHierarchy = productData['category_hierarchy'];
      if (categoryHierarchy is List && categoryHierarchy.isNotEmpty) {
        final category = _mapTargetCategoryToApp(categoryHierarchy);
        if (category != null) {
          enhancement['refined_category'] = category;
        }
      }

      // Specifications
      final specifications = productData['specifications'];
      if (specifications != null && specifications is Map) {
        enhancement['specifications'] = specifications;
      }

      // Rating and reviews
      final rating = productData['rating'];
      if (rating != null) {
        enhancement['rating'] = rating.toString();
      }

      final reviewCount = productData['reviews_count'];
      if (reviewCount != null) {
        enhancement['review_count'] = reviewCount.toString();
      }

      // Add RedCircle data flag
      enhancement['enhanced_with_redcircle'] = true;
      enhancement['redcircle_data'] = productData;
    } catch (e) {
      if (kDebugMode) {
        print('Error transforming RedCircle product: $e');
      }
    }

    return enhancement;
  }

  String _cleanItemNumber(String itemNumber) {
    // Remove common prefixes and clean up the item number
    return itemNumber
        .replaceAll(RegExp(r'^[^0-9]*'), '') // Remove non-numeric prefix
        .replaceAll(RegExp(r'[^0-9]'), '') // Keep only numbers
        .trim();
  }

  String? _mapTargetCategoryToApp(List categoryHierarchy) {
    final categories =
        categoryHierarchy.map((c) => c.toString().toLowerCase()).toList();

    // Map Target categories to app categories
    for (final category in categories) {
      if (category.contains('dairy') ||
          category.contains('milk') ||
          category.contains('cheese')) {
        return 'dairy';
      } else if (category.contains('produce') ||
          category.contains('fruit') ||
          category.contains('vegetable')) {
        return 'produce';
      } else if (category.contains('meat') ||
          category.contains('poultry') ||
          category.contains('seafood')) {
        return 'meat';
      } else if (category.contains('bakery') || category.contains('bread')) {
        return 'bakery';
      } else if (category.contains('frozen')) {
        return 'frozen';
      } else if (category.contains('beverage') || category.contains('drink')) {
        return 'beverages';
      }
    }

    return null;
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.receiveTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return 'Invalid RedCircle API key. Please check your configuration.';
        } else if (statusCode == 429) {
          return 'Too many requests. Please wait before trying again.';
        } else if (statusCode == 500) {
          return 'RedCircle server error. Please try again later.';
        }
        return 'Server error: $statusCode';
      case DioExceptionType.unknown:
        return 'Network error. Please check your internet connection.';
      default:
        return 'Request failed: ${e.message}';
    }
  }
}

class RedCircleException implements Exception {
  final String message;
  RedCircleException(this.message);

  @override
  String toString() => 'RedCircleException: $message';
}
