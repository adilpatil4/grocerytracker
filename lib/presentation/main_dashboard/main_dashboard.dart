import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/grocery_item.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/grocery_service.dart';
import '../../services/notification_service.dart';
import './widgets/dashboard_header.dart';
import './widgets/empty_state_widget.dart';
import './widgets/expiring_items_card.dart';
import './widgets/quick_action_button.dart';
import './widgets/quick_stats_card.dart';
import './widgets/recent_activity_item.dart';

// Add new imports

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentTabIndex = 0;
  bool _isRefreshing = false;
  bool _isLoading = true;

  // Add new state variables for Supabase data
  UserProfile? _userProfile;
  List<GroceryItem> _expiringItems = [];
  Map<String, dynamic> _inventoryStats = {};
  Map<String, dynamic> _notificationStats = {};
  List<Map<String, dynamic>> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Replace mock data loading with real Supabase data
  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // Check if user is authenticated
      if (!AuthService.instance.isSignedIn) {
        Navigator.pushReplacementNamed(context, AppRoutes.signIn);
        return;
      }

      // Load all dashboard data in parallel
      final futures = await Future.wait([
        AuthService.instance.getUserProfile(),
        GroceryService.instance.getExpiringItems(daysBefore: 3),
        GroceryService.instance.getInventoryStatistics(),
        NotificationService.instance.getNotificationStatistics(),
      ]);

      setState(() {
        _userProfile = futures[0] as UserProfile?;
        _expiringItems = futures[1] as List<GroceryItem>;
        _inventoryStats = futures[2] as Map<String, dynamic>;
        _notificationStats = futures[3] as Map<String, dynamic>;
        _isLoading = false;
      });

      // Send daily notifications check in background
      _checkDailyNotifications();
    } catch (error) {
      print('Error loading dashboard data: $error');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkDailyNotifications() async {
    try {
      await NotificationService.instance.checkAndSendDailyNotifications();
    } catch (error) {
      // Silent fail for background operations
      print('Background notification check failed: $error');
    }
  }

  Future<void> _refreshData() async {
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              )
            : RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dashboard Header with real user data
                      DashboardHeader(
                        userName: _userProfile?.fullName ?? 'User',
                        onNotificationTap: () {
                          Navigator.pushNamed(context, AppRoutes.notifications);
                        },
                      ),

                      SizedBox(height: 24.h),

                      // Quick Stats with real data
                      Row(
                        children: [
                          Expanded(
                            child: QuickStatsCard(
                              title: 'Total Items',
                              value: (_inventoryStats['total_items'] ?? 0)
                                  .toString(),
                              iconName: 'inventory',
                              backgroundColor: Colors.blue,
                              onTap: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.inventoryManagement);
                              },
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: QuickStatsCard(
                              title: 'Expiring Soon',
                              value: _expiringItems.length.toString(),
                              iconName: 'schedule',
                              backgroundColor: _expiringItems.isNotEmpty
                                  ? Colors.orange
                                  : Colors.green,
                              onTap: () {
                                if (_expiringItems.isNotEmpty) {
                                  _showExpiringItemsBottomSheet();
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      Row(
                        children: [
                          Expanded(
                            child: QuickStatsCard(
                              title: 'Health Score',
                              value:
                                  '${_inventoryStats['health_score'] ?? 100}%',
                              iconName: 'health_and_safety',
                              backgroundColor:
                                  (_inventoryStats['health_score'] ?? 100) >= 80
                                      ? Colors.green
                                      : (_inventoryStats['health_score'] ??
                                                  100) >=
                                              60
                                          ? Colors.orange
                                          : Colors.red,
                              onTap: () {},
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: QuickStatsCard(
                              title: 'Total Value',
                              value:
                                  '\$${(_inventoryStats['total_value'] ?? 0).toStringAsFixed(0)}',
                              iconName: 'attach_money',
                              backgroundColor: Colors.purple,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 32.h),

                      // Expiring Soon Section with real data
                      if (_expiringItems.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Expiring Soon',
                              style: GoogleFonts.inter(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ),
                            TextButton(
                              onPressed: () => _showExpiringItemsBottomSheet(),
                              child: Text(
                                'View All',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Column(
                          children: _expiringItems
                              .take(3)
                              .map((item) => Padding(
                                    padding: EdgeInsets.only(bottom: 12.h),
                                    child: ExpiringItemsCard(
                                      item: {
                                        'name': item.name,
                                        'daysRemaining':
                                            item.daysUntilExpiration,
                                        'category': item.categoryDisplayName,
                                        'location': item.storageDisplayName,
                                      },
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.itemDetail,
                                          arguments: item.id,
                                        );
                                      },
                                    ),
                                  ))
                              .toList(),
                        ),
                      ] else ...[
                        EmptyStateWidget(
                          title: 'All Items Fresh!',
                          description:
                              'No items are expiring soon. Great job managing your inventory!',
                          iconName: 'check_circle',
                          buttonText: 'Add New Items',
                          onButtonPressed: () {
                            Navigator.pushNamed(context, AppRoutes.addItem);
                          },
                        ),
                      ],

                      SizedBox(height: 32.h),

                      // Recent Activity Section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Recent Activity",
                              style: AppTheme.lightTheme.textTheme.titleLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextButton(
                              onPressed: () => _navigateToScanHistory(),
                              child: Text(
                                "View All",
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 2.h),

                      // Recent Activity List - Convert from Sliver to regular widgets
                      if (_recentActivities.isNotEmpty)
                        Column(
                          children: _recentActivities
                              .take(3)
                              .map((activity) => Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 4.w, vertical: 4.h),
                                    child: RecentActivityItem(
                                      activity: activity,
                                      onTap: () => _handleActivityTap(activity),
                                    ),
                                  ))
                              .toList(),
                        ),

                      SizedBox(height: 4.h),

                      // Quick Actions with updated navigation
                      Text(
                        'Quick Actions',
                        style: GoogleFonts.inter(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),

                      SizedBox(height: 16.h),

                      Row(
                        children: [
                          Expanded(
                            child: QuickActionButton(
                              title: 'Scan Receipt',
                              iconName: 'camera_alt',
                              backgroundColor: Colors.green,
                              onTap: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.receiptScanning);
                              },
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: QuickActionButton(
                              title: 'Add Item',
                              iconName: 'add_circle',
                              backgroundColor: Colors.blue,
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.addItem);
                              },
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      Row(
                        children: [
                          Expanded(
                            child: QuickActionButton(
                              title: 'Shopping List',
                              iconName: 'shopping_cart',
                              backgroundColor: Colors.orange,
                              onTap: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.shoppingList);
                              },
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: QuickActionButton(
                              title: 'View Inventory',
                              iconName: 'inventory',
                              backgroundColor: Colors.purple,
                              onTap: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.inventoryManagement);
                              },
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        selectedItemColor: AppTheme.lightTheme.colorScheme.primary,
        unselectedItemColor:
            AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'dashboard',
              size: 6.w,
              color: _currentTabIndex == 0
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'document_scanner',
              size: 6.w,
              color: _currentTabIndex == 1
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
            ),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'inventory',
              size: 6.w,
              color: _currentTabIndex == 2
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
            ),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'restaurant',
              size: 6.w,
              color: _currentTabIndex == 3
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
            ),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              size: 6.w,
              color: _currentTabIndex == 4
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
            ),
            label: 'Profile',
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToReceiptScanning(),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        elevation: 4,
        child: CustomIconWidget(
          iconName: 'camera_alt',
          size: 7.w,
          color: AppTheme.lightTheme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  void _showExpiringItemsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Items Expiring Soon',
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _expiringItems.length,
                itemBuilder: (context, index) {
                  final item = _expiringItems[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: ExpiringItemsCard(
                      item: {
                        'name': item.name,
                        'daysRemaining': item.daysUntilExpiration,
                        'category': item.categoryDisplayName,
                        'location': item.storageDisplayName,
                      },
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.itemDetail,
                          arguments: item.id,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate refresh delay
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });

    // Show refresh feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dashboard refreshed'),
        duration: Duration(seconds: 2),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentTabIndex = index;
    });

    // Navigate to respective screens based on tab
    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        _navigateToReceiptScanning();
        break;
      case 2:
        _navigateToInventory();
        break;
      case 3:
        _navigateToRecipes();
        break;
      case 4:
        _navigateToProfile();
        break;
    }
  }

  void _navigateToReceiptScanning() {
    Navigator.pushNamed(context, '/receipt-scanning');
  }

  void _navigateToInventory() {
    Navigator.pushNamed(context, '/inventory-management');
  }

  void _navigateToItemDetail(int itemId) {
    Navigator.pushNamed(context, '/item-detail', arguments: {'itemId': itemId});
  }

  void _navigateToRecipes() {
    Navigator.pushNamed(context, '/recipe-recommendations');
  }

  void _navigateToProfile() {
    // Navigate to profile screen (not specified in requirements)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToScanHistory() {
    // Navigate to scan history (not specified in requirements)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scan history feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToAddItem() {
    // Navigate to add item manually (not specified in requirements)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Manual add item feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleActivityTap(Map<String, dynamic> activity) {
    final String type = (activity['type'] as String?) ?? '';

    switch (type) {
      case 'scan':
        _navigateToScanHistory();
        break;
      case 'add':
      case 'update':
      case 'remove':
        _navigateToInventory();
        break;
      case 'expire':
        _navigateToInventory();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Activity details coming soon'),
            duration: Duration(seconds: 2),
          ),
        );
    }
  }
}

// Extension to convert SizedBox to Sliver
extension SizedBoxSliver on SizedBox {
  Widget get sliver => SliverToBoxAdapter(child: this);
}
