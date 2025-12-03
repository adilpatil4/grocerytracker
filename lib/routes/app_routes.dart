import 'package:flutter/material.dart';
import '../presentation/main_dashboard/main_dashboard.dart';
import '../presentation/shopping_list/shopping_list.dart';
import '../presentation/item_detail/item_detail.dart';
import '../presentation/receipt_scanning/receipt_scanning.dart';
import '../presentation/inventory_management/inventory_management.dart';
import '../presentation/recipe_recommendations/recipe_recommendations.dart';
import '../presentation/auth/signin_screen.dart';
import '../presentation/auth/signup_screen.dart';
import '../presentation/auth/forgot_password_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = signIn;
  static const String mainDashboard = '/main-dashboard';
  static const String shoppingList = '/shopping-list';
  static const String itemDetail = '/item-detail';
  static const String receiptScanning = '/receipt-scanning';
  static const String inventoryManagement = '/inventory-management';
  static const String recipeRecommendations = '/recipe-recommendations';

  // Add new auth routes
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String notifications = '/notifications';
  static const String addItem = '/add-item';

  static Map<String, WidgetBuilder> get routes => {
        initial: (context) => const MainDashboard(),
        mainDashboard: (context) => const MainDashboard(),
        shoppingList: (context) => const ShoppingList(),
        itemDetail: (context) => const ItemDetail(),
        receiptScanning: (context) => const ReceiptScanning(),
        inventoryManagement: (context) => const InventoryManagement(),
        recipeRecommendations: (context) => const RecipeRecommendations(),

        // Add new auth routes
        signIn: (context) => const SignInScreen(),
        signUp: (context) => const SignUpScreen(),
        forgotPassword: (context) => const ForgotPasswordScreen(),
      };
}
