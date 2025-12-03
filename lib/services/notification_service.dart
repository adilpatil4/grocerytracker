import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/grocery_item.dart';
import './auth_service.dart';
import './grocery_service.dart';
import './supabase_service.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance =>
      _instance ??= NotificationService._();
  NotificationService._();

  SupabaseClient get _client => SupabaseService.instance.client;
  AuthService get _auth => AuthService.instance;
  GroceryService get _grocery => GroceryService.instance;

  // Send expiration notification
  Future<bool> sendExpirationNotification({
    required String notificationType, // 'expiring_soon' or 'expired'
    int? daysBefore,
  }) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      // Get user profile for email and preferences
      final userProfile = await _auth.getUserProfile();
      if (userProfile == null || !userProfile.emailNotifications) {
        return false; // User has disabled email notifications
      }

      // Get expiring items
      List<GroceryItem> items;
      if (notificationType == 'expiring_soon') {
        items = await _grocery.getExpiringItems(
            daysBefore: daysBefore ?? userProfile.notificationDaysBefore);
      } else {
        // Get expired items
        final response = await _client
            .from('grocery_items')
            .select()
            .filter('is_consumed', 'eq', false)
            .not('expiration_date', 'is', null)
            .lt('expiration_date',
                DateTime.now().toIso8601String().split('T')[0])
            .order('expiration_date', ascending: true);

        items = response.map((item) => GroceryItem.fromJson(item)).toList();
      }

      if (items.isEmpty) {
        return false; // No items to notify about
      }

      // Prepare items data for email
      final itemsData = items
          .map((item) => {
                'name': item.name,
                'expiration_date':
                    item.expirationDate?.toIso8601String().split('T')[0],
                'days_until_expiration': item.daysUntilExpiration,
                'category': item.categoryDisplayName,
                'storage_location': item.storageDisplayName,
              })
          .toList();

      // Call edge function for email notification
      final response =
          await _client.functions.invoke('grocery-notifications', body: {
        'userId': _auth.currentUser!.id,
        'userEmail': userProfile.email,
        'userName': userProfile.fullName,
        'notificationType': notificationType,
        'items': itemsData,
      });

      if (response.status != 200) {
        throw Exception('Failed to send notification: ${response.data}');
      }

      // Create notification records in database
      await _createNotificationRecords(items, notificationType);

      return true;
    } catch (error) {
      throw Exception('Failed to send expiration notification: $error');
    }
  }

  // Create notification records in database
  Future<void> _createNotificationRecords(
      List<GroceryItem> items, String notificationType) async {
    try {
      String title = '';
      String message = '';

      if (notificationType == 'expiring_soon') {
        title = 'Items Expiring Soon';
        message =
            'You have ${items.length} items expiring in the next few days';
      } else {
        title = 'Expired Items Alert';
        message = 'You have ${items.length} expired items that need attention';
      }

      final notificationsData = items
          .map((item) => {
                'user_id': _auth.currentUser!.id,
                'grocery_item_id': item.id,
                'type': notificationType,
                'title': title,
                'message': message,
                'is_email_sent': true,
                'scheduled_for': DateTime.now().toIso8601String(),
              })
          .toList();

      await _client.from('notifications').insert(notificationsData);
    } catch (error) {
      throw Exception('Failed to create notification records: $error');
    }
  }

  // Get user notifications
  Future<List<Map<String, dynamic>>> getUserNotifications({
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      var query = _client
          .from('notifications')
          .select('*, grocery_items(name, category)')
          .order('created_at', ascending: false)
          .limit(limit);

      if (unreadOnly) {
        query = query.eq('is_read', false);
      }

      return await query;
    } catch (error) {
      throw Exception('Failed to get notifications: $error');
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      await _client.from('notifications').update({
        'is_read': true,
        'updated_at': DateTime.now().toIso8601String()
      }).filter('id', 'eq', notificationId);
    } catch (error) {
      throw Exception('Failed to mark notification as read: $error');
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      await _client.from('notifications').update({
        'is_read': true,
        'updated_at': DateTime.now().toIso8601String()
      }).filter('is_read', 'eq', false);
    } catch (error) {
      throw Exception('Failed to mark all notifications as read: $error');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      await _client
          .from('notifications')
          .delete()
          .filter('id', 'eq', notificationId);
    } catch (error) {
      throw Exception('Failed to delete notification: $error');
    }
  }

  // Schedule daily notification check (for app background processing)
  Future<void> checkAndSendDailyNotifications() async {
    try {
      if (!_auth.isSignedIn) return;

      final userProfile = await _auth.getUserProfile();
      if (userProfile == null || !userProfile.emailNotifications) return;

      // Check for expiring items
      await sendExpirationNotification(
        notificationType: 'expiring_soon',
        daysBefore: userProfile.notificationDaysBefore,
      );

      // Check for expired items
      await sendExpirationNotification(
        notificationType: 'expired',
      );
    } catch (error) {
      // Silent fail for background operations
      print('Background notification check failed: $error');
    }
  }

  // Get notification statistics
  Future<Map<String, dynamic>> getNotificationStatistics() async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final response = await _client
          .from('notifications')
          .select('type, is_read, created_at')
          .order('created_at', ascending: false);

      final notifications = response as List<dynamic>;

      int totalNotifications = notifications.length;
      int unreadCount = 0;
      int expiringCount = 0;
      int expiredCount = 0;

      for (final notification in notifications) {
        if (!(notification['is_read'] as bool)) {
          unreadCount++;
        }

        final type = notification['type'] as String;
        if (type == 'expiring_soon') {
          expiringCount++;
        } else if (type == 'expired') {
          expiredCount++;
        }
      }

      return {
        'total_notifications': totalNotifications,
        'unread_count': unreadCount,
        'expiring_notifications': expiringCount,
        'expired_notifications': expiredCount,
        'read_percentage': totalNotifications > 0
            ? ((totalNotifications - unreadCount) / totalNotifications * 100)
                .round()
            : 100,
      };
    } catch (error) {
      throw Exception('Failed to get notification statistics: $error');
    }
  }
}