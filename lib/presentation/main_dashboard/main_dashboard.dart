import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/dashboard_header.dart';
import './widgets/empty_state_widget.dart';
import './widgets/expiring_items_card.dart';
import './widgets/quick_action_button.dart';
import './widgets/quick_stats_card.dart';
import './widgets/recent_activity_item.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard>
    with TickerProviderStateMixin {
  int _currentTabIndex = 0;
  bool _isRefreshing = false;

  // Mock data for dashboard
  final List<Map<String, dynamic>> _expiringItems = [
    {
      "id": 1,
      "name": "Organic Bananas",
      "image":
          "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "location": "Kitchen Counter",
      "daysRemaining": 1,
      "category": "Produce"
    },
    {
      "id": 2,
      "name": "Greek Yogurt",
      "image":
          "https://images.unsplash.com/photo-1488477181946-6428a0291777?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "location": "Refrigerator",
      "daysRemaining": 2,
      "category": "Dairy"
    },
    {
      "id": 3,
      "name": "Fresh Spinach",
      "image":
          "https://images.unsplash.com/photo-1576045057995-568f588f82fb?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "location": "Refrigerator",
      "daysRemaining": 0,
      "category": "Produce"
    },
    {
      "id": 4,
      "name": "Whole Milk",
      "image":
          "https://images.unsplash.com/photo-1550583724-b2692b85b150?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "location": "Refrigerator",
      "daysRemaining": -1,
      "category": "Dairy"
    }
  ];

  final List<Map<String, dynamic>> _recentActivities = [
    {
      "id": 1,
      "type": "scan",
      "title": "Receipt Scanned",
      "description": "Whole Foods Market - 12 items added",
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
    },
    {
      "id": 2,
      "type": "add",
      "title": "Item Added Manually",
      "description": "Organic Apples added to Refrigerator",
      "timestamp": DateTime.now().subtract(Duration(hours: 5)),
    },
    {
      "id": 3,
      "type": "expire",
      "title": "Expiration Alert",
      "description": "3 items expiring within 24 hours",
      "timestamp": DateTime.now().subtract(Duration(hours: 8)),
    },
    {
      "id": 4,
      "type": "update",
      "title": "Inventory Updated",
      "description": "Moved 2 items from Pantry to Freezer",
      "timestamp": DateTime.now().subtract(Duration(days: 1)),
    },
    {
      "id": 5,
      "type": "remove",
      "title": "Items Consumed",
      "description": "Marked 5 items as used",
      "timestamp": DateTime.now().subtract(Duration(days: 2)),
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppTheme.lightTheme.colorScheme.primary,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: DashboardHeader(
                  userName: "Adil",
                  onProfileTap: () => _navigateToProfile(),
                ),
              ),

              // Quick Stats Cards
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: QuickStatsCard(
                              title: "Expiring Soon",
                              value:
                                  "${_expiringItems.where((item) => (item['daysRemaining'] as int) <= 3).length}",
                              iconName: "warning",
                              backgroundColor:
                                  Colors.orange.withValues(alpha: 0.1),
                              onTap: () => _navigateToInventory(),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: QuickStatsCard(
                              title: "Total Items",
                              value: "47",
                              iconName: "inventory",
                              onTap: () => _navigateToInventory(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.w),
                      QuickStatsCard(
                        title: "Recent Scans",
                        value:
                            "${(_recentActivities.where((activity) => (activity['type'] as String) == 'scan').length)}",
                        iconName: "document_scanner",
                        onTap: () => _navigateToScanHistory(),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 4.h).sliver,

              // Expiring Soon Section
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Expiring Soon",
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextButton(
                            onPressed: () => _navigateToInventory(),
                            child: Text(
                              "View All",
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    _expiringItems.isNotEmpty
                        ? Container(
                            height: 25.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              itemCount: _expiringItems.length,
                              itemBuilder: (context, index) {
                                return ExpiringItemsCard(
                                  item: _expiringItems[index],
                                  onTap: () => _navigateToItemDetail(
                                      _expiringItems[index]['id']),
                                );
                              },
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Container(
                              height: 20.h,
                              child: EmptyStateWidget(
                                title: "No Items Expiring",
                                description:
                                    "All your items are fresh! Scan a receipt to add more items.",
                                iconName: "check_circle",
                                buttonText: "Scan Receipt",
                                onButtonPressed: () =>
                                    _navigateToReceiptScanning(),
                              ),
                            ),
                          ),
                  ],
                ),
              ),

              SizedBox(height: 4.h).sliver,

              // Recent Activity Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Recent Activity",
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _navigateToScanHistory(),
                        child: Text(
                          "View All",
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 2.h).sliver,

              // Recent Activity List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= 3) return null; // Show only first 3 activities
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: RecentActivityItem(
                        activity: _recentActivities[index],
                        onTap: () =>
                            _handleActivityTap(_recentActivities[index]),
                      ),
                    );
                  },
                  childCount: _recentActivities.length > 3
                      ? 3
                      : _recentActivities.length,
                ),
              ),

              SizedBox(height: 4.h).sliver,

              // Quick Actions Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Quick Actions",
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Expanded(
                            child: QuickActionButton(
                              title: "Scan Receipt",
                              iconName: "document_scanner",
                              onTap: () => _navigateToReceiptScanning(),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: QuickActionButton(
                              title: "Add Item",
                              iconName: "add_circle",
                              onTap: () => _navigateToAddItem(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.w),
                      QuickActionButton(
                        title: "View Full Inventory",
                        iconName: "inventory",
                        onTap: () => _navigateToInventory(),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10.h).sliver, // Bottom padding for FAB
            ],
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
