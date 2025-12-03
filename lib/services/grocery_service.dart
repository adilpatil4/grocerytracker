import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/grocery_item.dart';
import './auth_service.dart';
import './supabase_service.dart';

class GroceryService {
  static GroceryService? _instance;
  static GroceryService get instance => _instance ??= GroceryService._();
  GroceryService._();

  SupabaseClient get _client => SupabaseService.instance.client;
  AuthService get _auth => AuthService.instance;

  // Get all grocery items for current user
  Future<List<GroceryItem>> getGroceryItems({
    String? category,
    String? storageLocation,
    bool excludeConsumed = true,
  }) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      var query = _client.from('grocery_items').select();

      if (excludeConsumed) {
        query = query.eq('is_consumed', false);
      }

      if (category != null && category != 'all') {
        query = query.eq('category', category);
      }

      if (storageLocation != null && storageLocation != 'all') {
        query = query.eq('storage_location', storageLocation);
      }

      final response = await query.order('expiration_date', ascending: true);

      return response.map((item) => GroceryItem.fromJson(item)).toList();
    } catch (error) {
      throw Exception('Failed to get grocery items: $error');
    }
  }

  // Get expiring items
  Future<List<GroceryItem>> getExpiringItems({int daysBefore = 3}) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final cutoffDate = DateTime.now().add(Duration(days: daysBefore));

      final response = await _client
          .from('grocery_items')
          .select()
          .eq('is_consumed', false)
          .not('expiration_date', 'is', null)
          .lte('expiration_date', cutoffDate.toIso8601String().split('T')[0])
          .gte(
              'expiration_date', DateTime.now().toIso8601String().split('T')[0])
          .order('expiration_date', ascending: true);

      return response.map((item) => GroceryItem.fromJson(item)).toList();
    } catch (error) {
      throw Exception('Failed to get expiring items: $error');
    }
  }

  // Add new grocery item
  Future<GroceryItem> addGroceryItem({
    required String name,
    required String category,
    String? brand,
    String? barcode,
    required int quantity,
    required String unit,
    DateTime? purchaseDate,
    DateTime? expirationDate,
    required String storageLocation,
    String? notes,
    double? purchasePrice,
    String? storeName,
  }) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final itemData = {
        'user_id': _auth.currentUser!.id,
        'name': name,
        'category': category,
        'brand': brand,
        'barcode': barcode,
        'quantity': quantity,
        'unit': unit,
        'purchase_date':
            (purchaseDate ?? DateTime.now()).toIso8601String().split('T')[0],
        'expiration_date': expirationDate?.toIso8601String().split('T')[0],
        'storage_location': storageLocation,
        'notes': notes,
        'purchase_price': purchasePrice,
        'store_name': storeName,
      };

      final response = await _client
          .from('grocery_items')
          .insert(itemData)
          .select()
          .single();

      return GroceryItem.fromJson(response);
    } catch (error) {
      throw Exception('Failed to add grocery item: $error');
    }
  }

  // Update grocery item
  Future<GroceryItem> updateGroceryItem({
    required String itemId,
    String? name,
    String? category,
    String? brand,
    String? barcode,
    int? quantity,
    String? unit,
    DateTime? purchaseDate,
    DateTime? expirationDate,
    String? storageLocation,
    String? notes,
    double? purchasePrice,
    String? storeName,
    bool? isConsumed,
  }) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (category != null) updateData['category'] = category;
      if (brand != null) updateData['brand'] = brand;
      if (barcode != null) updateData['barcode'] = barcode;
      if (quantity != null) updateData['quantity'] = quantity;
      if (unit != null) updateData['unit'] = unit;
      if (purchaseDate != null)
        updateData['purchase_date'] =
            purchaseDate.toIso8601String().split('T')[0];
      if (expirationDate != null)
        updateData['expiration_date'] =
            expirationDate.toIso8601String().split('T')[0];
      if (storageLocation != null)
        updateData['storage_location'] = storageLocation;
      if (notes != null) updateData['notes'] = notes;
      if (purchasePrice != null) updateData['purchase_price'] = purchasePrice;
      if (storeName != null) updateData['store_name'] = storeName;
      if (isConsumed != null) {
        updateData['is_consumed'] = isConsumed;
        if (isConsumed) {
          updateData['consumed_at'] = DateTime.now().toIso8601String();
        }
      }

      final response = await _client
          .from('grocery_items')
          .update(updateData)
          .eq('id', itemId)
          .select()
          .single();

      return GroceryItem.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update grocery item: $error');
    }
  }

  // Mark item as consumed
  Future<void> markItemAsConsumed(String itemId) async {
    try {
      await updateGroceryItem(itemId: itemId, isConsumed: true);
    } catch (error) {
      throw Exception('Failed to mark item as consumed: $error');
    }
  }

  // Delete grocery item
  Future<void> deleteGroceryItem(String itemId) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      await _client.from('grocery_items').delete().eq('id', itemId);
    } catch (error) {
      throw Exception('Failed to delete grocery item: $error');
    }
  }

  // Get inventory statistics
  Future<Map<String, dynamic>> getInventoryStatistics() async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      // Get all active items
      final itemsResponse = await _client
          .from('grocery_items')
          .select('category, expiration_date, is_consumed, purchase_price')
          .eq('is_consumed', false);

      final items = itemsResponse as List<dynamic>;
      final now = DateTime.now();

      int totalItems = items.length;
      int expiredItems = 0;
      int expiringSoonItems = 0;
      double totalValue = 0;
      Map<String, int> categoryCount = {};

      for (final item in items) {
        // Count by category
        final category = item['category'] as String? ?? 'other';
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;

        // Calculate value
        final price = item['purchase_price'] as num?;
        if (price != null) {
          totalValue += price.toDouble();
        }

        // Check expiration
        final expirationDateStr = item['expiration_date'] as String?;
        if (expirationDateStr != null) {
          final expirationDate = DateTime.parse(expirationDateStr);
          final daysUntilExpiration = expirationDate.difference(now).inDays;

          if (daysUntilExpiration < 0) {
            expiredItems++;
          } else if (daysUntilExpiration <= 3) {
            expiringSoonItems++;
          }
        }
      }

      return {
        'total_items': totalItems,
        'expired_items': expiredItems,
        'expiring_soon_items': expiringSoonItems,
        'total_value': totalValue,
        'category_breakdown': categoryCount,
        'health_score': totalItems > 0
            ? ((totalItems - expiredItems - expiringSoonItems) /
                    totalItems *
                    100)
                .round()
            : 100,
      };
    } catch (error) {
      throw Exception('Failed to get inventory statistics: $error');
    }
  }

  // Search items
  Future<List<GroceryItem>> searchItems(String query) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final response = await _client
          .from('grocery_items')
          .select()
          .eq('is_consumed', false)
          .ilike('name', '%$query%')
          .order('name', ascending: true);

      return response.map((item) => GroceryItem.fromJson(item)).toList();
    } catch (error) {
      throw Exception('Failed to search items: $error');
    }
  }

  // Bulk add items (for receipt processing)
  Future<List<GroceryItem>> addMultipleItems(
      List<Map<String, dynamic>> items) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final itemsData = items
          .map((item) => {
                ...item,
                'user_id': _auth.currentUser!.id,
                'purchase_date':
                    (item['purchase_date'] as DateTime? ?? DateTime.now())
                        .toIso8601String()
                        .split('T')[0],
                'expiration_date': (item['expiration_date'] as DateTime?)
                    ?.toIso8601String()
                    .split('T')[0],
              })
          .toList();

      final response =
          await _client.from('grocery_items').insert(itemsData).select();

      return response.map((item) => GroceryItem.fromJson(item)).toList();
    } catch (error) {
      throw Exception('Failed to add multiple items: $error');
    }
  }
}
