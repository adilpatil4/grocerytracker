import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import './recipe_card_widget.dart';

class RecipeSectionWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> recipes;
  final Function(Map<String, dynamic>) onRecipeTap;
  final Function(Map<String, dynamic>) onFavorite;
  final Set<String> favoriteRecipes;

  const RecipeSectionWidget({
    Key? key,
    required this.title,
    required this.recipes,
    required this.onRecipeTap,
    required this.onFavorite,
    required this.favoriteRecipes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Text(
            title,
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 32.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final recipeId = recipe['id']?.toString() ?? '';

              return SizedBox(
                width: 70.w,
                child: RecipeCardWidget(
                  recipe: recipe,
                  isFavorited: favoriteRecipes.contains(recipeId),
                  onTap: () => onRecipeTap(recipe),
                  onFavorite: () => onFavorite(recipe),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
