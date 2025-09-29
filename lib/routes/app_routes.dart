import 'package:flutter/material.dart';
import '../presentation/main_dashboard/main_dashboard.dart';
import '../presentation/shopping_list/shopping_list.dart';
import '../presentation/item_detail/item_detail.dart';
import '../presentation/receipt_scanning/receipt_scanning.dart';
import '../presentation/inventory_management/inventory_management.dart';
import '../presentation/recipe_recommendations/recipe_recommendations.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String mainDashboard = '/main-dashboard';
  static const String shoppingList = '/shopping-list';
  static const String itemDetail = '/item-detail';
  static const String receiptScanning = '/receipt-scanning';
  static const String inventoryManagement = '/inventory-management';
  static const String recipeRecommendations = '/recipe-recommendations';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const MainDashboard(),
    mainDashboard: (context) => const MainDashboard(),
    shoppingList: (context) => const ShoppingList(),
    itemDetail: (context) => const ItemDetail(),
    receiptScanning: (context) => const ReceiptScanning(),
    inventoryManagement: (context) => const InventoryManagement(),
    recipeRecommendations: (context) => const RecipeRecommendations(),
    // TODO: Add your other routes here
  };
}
