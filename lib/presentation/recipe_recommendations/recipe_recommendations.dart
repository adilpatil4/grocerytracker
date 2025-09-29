import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/filter_modal_widget.dart';
import './widgets/recipe_card_widget.dart';
import './widgets/recipe_section_widget.dart';

class RecipeRecommendations extends StatefulWidget {
  const RecipeRecommendations({Key? key}) : super(key: key);

  @override
  State<RecipeRecommendations> createState() => _RecipeRecommendationsState();
}

class _RecipeRecommendationsState extends State<RecipeRecommendations> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedMealType = 'All';
  Set<String> _favoriteRecipes = {};
  Map<String, dynamic> _filters = {
    'dietary': <String>[],
    'maxCookingTime': 60.0,
    'difficulty': null,
  };
  bool _isLoading = false;
  List<Map<String, dynamic>> _filteredRecipes = [];

  // Mock recipe data
  final List<Map<String, dynamic>> _allRecipes = [
    {
      "id": "1",
      "name": "Chicken Stir Fry",
      "imageUrl":
          "https://images.pexels.com/photos/2338407/pexels-photo-2338407.jpeg",
      "cookingTime": 25,
      "matchPercentage": 95,
      "status": "can_make",
      "mealType": "Dinner",
      "ingredients": [
        "chicken breast",
        "bell peppers",
        "onion",
        "soy sauce",
        "garlic"
      ],
      "difficulty": "Easy",
      "dietary": ["Gluten-Free"],
      "description":
          "A quick and healthy stir fry with fresh vegetables and tender chicken."
    },
    {
      "id": "2",
      "name": "Avocado Toast",
      "imageUrl":
          "https://images.pexels.com/photos/1351238/pexels-photo-1351238.jpeg",
      "cookingTime": 10,
      "matchPercentage": 85,
      "status": "can_make",
      "mealType": "Breakfast",
      "ingredients": ["bread", "avocado", "tomato", "lime", "salt"],
      "difficulty": "Easy",
      "dietary": ["Vegetarian", "Vegan"],
      "description":
          "Simple and nutritious breakfast with creamy avocado and fresh tomatoes."
    },
    {
      "id": "3",
      "name": "Pasta Carbonara",
      "imageUrl":
          "https://images.pexels.com/photos/4518843/pexels-photo-4518843.jpeg",
      "cookingTime": 30,
      "matchPercentage": 70,
      "status": "missing_few",
      "mealType": "Dinner",
      "ingredients": ["pasta", "eggs", "bacon", "parmesan", "black pepper"],
      "difficulty": "Medium",
      "dietary": [],
      "description":
          "Classic Italian pasta dish with creamy egg sauce and crispy bacon."
    },
    {
      "id": "4",
      "name": "Greek Salad",
      "imageUrl":
          "https://images.pexels.com/photos/1213710/pexels-photo-1213710.jpeg",
      "cookingTime": 15,
      "matchPercentage": 90,
      "status": "can_make",
      "mealType": "Lunch",
      "ingredients": [
        "cucumber",
        "tomatoes",
        "feta cheese",
        "olives",
        "olive oil"
      ],
      "difficulty": "Easy",
      "dietary": ["Vegetarian", "Gluten-Free"],
      "description":
          "Fresh Mediterranean salad with crisp vegetables and tangy feta."
    },
    {
      "id": "5",
      "name": "Smoothie Bowl",
      "imageUrl":
          "https://images.pexels.com/photos/1092730/pexels-photo-1092730.jpeg",
      "cookingTime": 8,
      "matchPercentage": 80,
      "status": "can_make",
      "mealType": "Breakfast",
      "ingredients": ["banana", "berries", "yogurt", "granola", "honey"],
      "difficulty": "Easy",
      "dietary": ["Vegetarian"],
      "description":
          "Healthy and colorful breakfast bowl packed with fruits and nutrients."
    },
    {
      "id": "6",
      "name": "Beef Tacos",
      "imageUrl":
          "https://images.pexels.com/photos/2087748/pexels-photo-2087748.jpeg",
      "cookingTime": 35,
      "matchPercentage": 65,
      "status": "missing_few",
      "mealType": "Dinner",
      "ingredients": ["ground beef", "tortillas", "lettuce", "cheese", "salsa"],
      "difficulty": "Medium",
      "dietary": [],
      "description":
          "Flavorful Mexican-style tacos with seasoned beef and fresh toppings."
    },
    {
      "id": "7",
      "name": "Trail Mix",
      "imageUrl":
          "https://images.pexels.com/photos/1295572/pexels-photo-1295572.jpeg",
      "cookingTime": 5,
      "matchPercentage": 100,
      "status": "can_make",
      "mealType": "Snacks",
      "ingredients": ["almonds", "dried fruit", "chocolate chips", "peanuts"],
      "difficulty": "Easy",
      "dietary": ["Vegetarian"],
      "description": "Quick and energizing snack mix perfect for on-the-go."
    },
    {
      "id": "8",
      "name": "Vegetable Curry",
      "imageUrl":
          "https://images.pexels.com/photos/2474661/pexels-photo-2474661.jpeg",
      "cookingTime": 45,
      "matchPercentage": 75,
      "status": "missing_few",
      "mealType": "Dinner",
      "ingredients": [
        "mixed vegetables",
        "coconut milk",
        "curry powder",
        "rice",
        "onion"
      ],
      "difficulty": "Medium",
      "dietary": ["Vegetarian", "Vegan", "Gluten-Free"],
      "description":
          "Rich and aromatic curry with seasonal vegetables in creamy coconut sauce."
    }
  ];

  final List<String> _mealTypes = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snacks'
  ];

  @override
  void initState() {
    super.initState();
    _filteredRecipes = List.from(_allRecipes);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterRecipes();
  }

  void _filterRecipes() {
    setState(() {
      _filteredRecipes = _allRecipes.where((recipe) {
        // Search filter
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch = searchQuery.isEmpty ||
            (recipe['name'] as String).toLowerCase().contains(searchQuery) ||
            (recipe['ingredients'] as List).any((ingredient) =>
                ingredient.toString().toLowerCase().contains(searchQuery));

        // Meal type filter
        final matchesMealType = _selectedMealType == 'All' ||
            recipe['mealType'] == _selectedMealType;

        // Dietary filter
        final recipeDietary = recipe['dietary'] as List<String>;
        final selectedDietary = _filters['dietary'] as List<String>;
        final matchesDietary = selectedDietary.isEmpty ||
            selectedDietary.every((diet) => recipeDietary.contains(diet));

        // Cooking time filter
        final maxTime = _filters['maxCookingTime'] as double;
        final matchesTime = (recipe['cookingTime'] as int) <= maxTime;

        // Difficulty filter
        final selectedDifficulty = _filters['difficulty'] as String?;
        final matchesDifficulty = selectedDifficulty == null ||
            recipe['difficulty'] == selectedDifficulty;

        return matchesSearch &&
            matchesMealType &&
            matchesDietary &&
            matchesTime &&
            matchesDifficulty;
      }).toList();
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  void _toggleFavorite(Map<String, dynamic> recipe) {
    setState(() {
      final recipeId = recipe['id'] as String;
      if (_favoriteRecipes.contains(recipeId)) {
        _favoriteRecipes.remove(recipeId);
      } else {
        _favoriteRecipes.add(recipeId);
      }
    });

    // Haptic feedback
    // HapticFeedback.lightImpact();
  }

  void _onRecipeTap(Map<String, dynamic> recipe) {
    // Navigate to recipe detail screen
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRecipeDetailModal(recipe),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModalWidget(
        currentFilters: _filters,
        onApplyFilters: (filters) {
          setState(() {
            _filters = filters;
          });
          _filterRecipes();
        },
      ),
    );
  }

  void _cookRecipe(Map<String, dynamic> recipe) {
    // Mark ingredients as consumed
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cook Recipe'),
        content: Text(
            'Mark ingredients as consumed and reduce inventory quantities?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement inventory reduction logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ingredients marked as consumed!'),
                  backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
                ),
              );
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _filteredRecipes.isEmpty && _searchController.text.isEmpty
          ? EmptyStateWidget(
              onAddInventory: () =>
                  Navigator.pushNamed(context, '/inventory-management'),
            )
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: Column(
                children: [
                  _buildSearchBar(),
                  _buildMealTypeFilters(),
                  Expanded(
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : _buildRecipeContent(),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Recipe Recommendations'),
      actions: [
        IconButton(
          onPressed: _showFilterModal,
          icon: CustomIconWidget(
            iconName: 'tune',
            size: 24,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(4.w),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search recipes or ingredients...',
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'search',
              size: 20,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _filterRecipes();
                  },
                  icon: CustomIconWidget(
                    iconName: 'clear',
                    size: 20,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildMealTypeFilters() {
    return Container(
      height: 6.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: _mealTypes.length,
        itemBuilder: (context, index) {
          final mealType = _mealTypes[index];
          return FilterChipWidget(
            label: mealType,
            isSelected: _selectedMealType == mealType,
            onTap: () {
              setState(() {
                _selectedMealType = mealType;
              });
              _filterRecipes();
            },
          );
        },
      ),
    );
  }

  Widget _buildRecipeContent() {
    if (_filteredRecipes.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'search_off',
                size: 60,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(height: 2.h),
              Text(
                'No recipes found',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              SizedBox(height: 1.h),
              Text(
                'Try adjusting your search or filters',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final quickMeals = _filteredRecipes
        .where((recipe) => (recipe['cookingTime'] as int) <= 30)
        .toList();
    final useUpSoon = _filteredRecipes
        .where((recipe) => (recipe['matchPercentage'] as int) >= 80)
        .toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Quick Meals Section
          if (quickMeals.isNotEmpty)
            RecipeSectionWidget(
              title: 'Quick Meals (Under 30 min)',
              recipes: quickMeals.take(5).toList(),
              onRecipeTap: _onRecipeTap,
              onFavorite: _toggleFavorite,
              favoriteRecipes: _favoriteRecipes,
            ),

          // Use Up Soon Section
          if (useUpSoon.isNotEmpty)
            RecipeSectionWidget(
              title: 'Use Up Soon',
              recipes: useUpSoon.take(5).toList(),
              onRecipeTap: _onRecipeTap,
              onFavorite: _toggleFavorite,
              favoriteRecipes: _favoriteRecipes,
            ),

          // All Recipes
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Row(
              children: [
                Text(
                  'All Recipes',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Text(
                  '${_filteredRecipes.length} recipes',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _filteredRecipes.length,
            itemBuilder: (context, index) {
              final recipe = _filteredRecipes[index];
              final recipeId = recipe['id'] as String;

              return RecipeCardWidget(
                recipe: recipe,
                isFavorited: _favoriteRecipes.contains(recipeId),
                onTap: () => _onRecipeTap(recipe),
                onFavorite: () => _toggleFavorite(recipe),
              );
            },
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildRecipeDetailModal(Map<String, dynamic> recipe) {
    final ingredients = recipe['ingredients'] as List;
    final description = recipe['description'] as String;

    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomImageWidget(
                      imageUrl: recipe['imageUrl'] as String,
                      width: double.infinity,
                      height: 25.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Recipe Name and Details
                  Text(
                    recipe['name'] as String,
                    style:
                        AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),

                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'access_time',
                        size: 16,
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 1.w),
                      Text('${recipe['cookingTime']} min'),
                      SizedBox(width: 4.w),
                      CustomIconWidget(
                        iconName: 'bar_chart',
                        size: 16,
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 1.w),
                      Text(recipe['difficulty'] as String),
                    ],
                  ),
                  SizedBox(height: 2.h),

                  // Description
                  Text(
                    'Description',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    description,
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 2.h),

                  // Ingredients
                  Text(
                    'Ingredients',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  ...ingredients
                      .map((ingredient) => Padding(
                            padding: EdgeInsets.only(bottom: 0.5.h),
                            child: Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'check_circle',
                                  size: 16,
                                  color:
                                      AppTheme.lightTheme.colorScheme.tertiary,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  ingredient.toString(),
                                  style:
                                      AppTheme.lightTheme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ],
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleFavorite(recipe),
                    icon: CustomIconWidget(
                      iconName: _favoriteRecipes.contains(recipe['id'])
                          ? 'favorite'
                          : 'favorite_border',
                      size: 20,
                      color: _favoriteRecipes.contains(recipe['id'])
                          ? Colors.red
                          : AppTheme.lightTheme.colorScheme.primary,
                    ),
                    label: Text('Favorite'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _cookRecipe(recipe);
                    },
                    icon: CustomIconWidget(
                      iconName: 'restaurant',
                      size: 20,
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                    ),
                    label: Text('Cook This'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 4, // Recipes tab
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/main-dashboard');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/receipt-scanning');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/inventory-management');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/shopping-list');
            break;
          case 4:
            // Current screen
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: CustomIconWidget(
              iconName: 'dashboard',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
          activeIcon: CustomIconWidget(
              iconName: 'dashboard',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
              iconName: 'camera_alt',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
          activeIcon: CustomIconWidget(
              iconName: 'camera_alt',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary),
          label: 'Scan',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
              iconName: 'inventory',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
          activeIcon: CustomIconWidget(
              iconName: 'inventory',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
              iconName: 'shopping_cart',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
          activeIcon: CustomIconWidget(
              iconName: 'shopping_cart',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary),
          label: 'Shopping',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
              iconName: 'restaurant_menu',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
          activeIcon: CustomIconWidget(
              iconName: 'restaurant_menu',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary),
          label: 'Recipes',
        ),
      ],
    );
  }
}
