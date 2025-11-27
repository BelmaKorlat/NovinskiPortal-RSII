import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/models/category/category_menu_models.dart';
import 'package:novinskiportal_mobile/providers/article/category_feed_provider.dart';
import 'package:novinskiportal_mobile/providers/category/category_menu_provider.dart';
import 'package:novinskiportal_mobile/screens/article/category_articles_feed_page.dart';
import 'package:novinskiportal_mobile/utils/color_utils.dart';
import 'package:provider/provider.dart';

class CategoryMenuSection extends StatefulWidget {
  const CategoryMenuSection({super.key});

  @override
  State<CategoryMenuSection> createState() => _CategoryMenuSectionState();
}

class _CategoryMenuSectionState extends State<CategoryMenuSection> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<CategoryMenuProvider>().load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryMenuProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.error != null) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(provider.error!),
          );
        }

        if (provider.items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Nema kategorija.'),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.items.length,
          itemBuilder: (context, index) {
            final category = provider.items[index];
            return _CategoryItem(
              category: category,
              onToggleExpand: () {
                provider.toggleExpanded(category.id);
              },
              onCategoryTap: () {
                final theme = Theme.of(context);
                final cs = theme.colorScheme;
                final color = tryParseHexColor(category.color) ?? cs.primary;

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) =>
                          CategoryFeedProvider(categoryId: category.id),
                      child: CategoryArticlesFeedPage(
                        categoryId: category.id,
                        categoryName: category.name,
                        categoryColor: color,
                      ),
                    ),
                  ),
                );
              },
              onSubcategoryTap: (sub) {
                final theme = Theme.of(context);
                final cs = theme.colorScheme;

                final color = tryParseHexColor(category.color) ?? cs.primary;

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) =>
                          CategoryFeedProvider(subcategoryId: sub.id),
                      child: CategoryArticlesFeedPage(
                        categoryId: sub.id,
                        categoryName: sub.name,
                        categoryColor: color,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final CategoryMenuDto category;
  final VoidCallback onToggleExpand;
  final VoidCallback onCategoryTap;
  final void Function(SubcategoryMenuDto subcategory) onSubcategoryTap;

  const _CategoryItem({
    required this.category,
    required this.onToggleExpand,
    required this.onCategoryTap,
    required this.onSubcategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = tryParseHexColor(category.color);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onCategoryTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onToggleExpand,
                  icon: Icon(
                    category.isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (category.isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: category.subcategories.map((sub) {
                return InkWell(
                  onTap: () => onSubcategoryTap(sub),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      sub.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        const Divider(height: 1),
      ],
    );
  }
}
