import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:go_router/go_router.dart';

import '../../controllers/bookmark_controller.dart';
import 'news_card_widget.dart';
import '../utils/helper.dart' as helper;
// import '../../routes/route_name.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBarAndFilter(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ).copyWith(bottom: 12.0, top: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) {
                // TODO: Implement search functionality for bookmarks if desired
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Pencarian bookmark untuk "$value" (belum diimplementasikan)',
                    ),
                  ),
                );
              },
              style: helper.subtitle2.copyWith(
                color: theme.textTheme.bodyMedium?.color,
              ),
              decoration: InputDecoration(
                hintText: "Search in bookmarks...",
                hintStyle: helper.subtitle2.copyWith(color: theme.hintColor),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: theme.hintColor,
                  size: 22,
                ),
                filled: true,
                fillColor: theme.brightness == Brightness.dark
                    ? Colors.grey.shade800.withOpacity(0.5)
                    : helper.cGrey.withOpacity(0.7),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          helper.hsMedium,
          InkWell(
            onTap: () {
              // TODO: Implement filter functionality for bookmarks if desired
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Fitur filter bookmark belum diimplementasikan',
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey.shade800.withOpacity(0.5)
                    : helper.cGrey.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: theme.textTheme.bodyMedium?.color,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    return ChangeNotifierProvider(
      create: (_) => BookmarkController(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 20.0,
                bottom: 8.0,
              ),
              child: Row(
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/icon.png',
                        height: 50.0,
                        width: 50.0,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.newspaper_rounded,
                            color: theme.colorScheme.primary,
                            size: 28.0,
                          );
                        },
                      ),
                      helper.hsLarge,
                      Text(
                        "Bookmark",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildSearchBarAndFilter(context, theme),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                "Artikel yang telah Anda simpan:",
                style: textTheme.titleSmall?.copyWith(
                  color: textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
              ),
            ),
            Expanded(
              child: Consumer<BookmarkController>(
                builder: (context, controller, child) {
                  if (controller.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    );
                  }
                  if (controller.errorMessage != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          controller.errorMessage!,
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  if (controller.bookmarkedArticles.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            size: 80,
                            color: theme.hintColor.withOpacity(0.5),
                          ),
                          helper.vsMedium,
                          Text(
                            "Belum ada artikel yang di-bookmark.",
                            style: textTheme.titleMedium?.copyWith(
                              color: textTheme.bodyMedium?.color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          helper.vsSmall,
                          Text(
                            "Simpan artikel untuk dibaca nanti.",
                            style: textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => controller.loadBookmarks(),
                    color: colorScheme.primary,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 16.0, top: 4.0),
                      itemCount: controller.bookmarkedArticles.length,
                      itemBuilder: (context, index) {
                        final article = controller.bookmarkedArticles[index];
                        return NewsCardWidget(
                          article: article,
                          isBookmarked:
                              true, // All articles here are bookmarked
                          onBookmarkTap: () {
                            controller.removeArticleFromBookmark(article);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "'${article.title}' dihapus dari bookmark.",
                                ),
                              ),
                            );
                          },
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
}
