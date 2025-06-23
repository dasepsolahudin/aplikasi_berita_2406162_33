// lib/views/widgets/local_articles_screen.dart
// import 'dart:io';
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/local_article_controller.dart';

import '../../data/models/article_model.dart';
import '../utils/helper.dart' as helper;
import 'news_card_widget.dart';
// import 'package:go_router/go_router.dart';
// import '../../routes/route_name.dart';

class LocalArticlesScreen extends StatelessWidget {
  const LocalArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return SafeArea(
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
                      "Lokal berita anda",
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
          Expanded(
            // Gunakan Consumer untuk mendengarkan perubahan pada LocalArticleController
            child: Consumer<LocalArticleController>(
              builder: (context, localArticleController, child) {
                final List<Article> articles =
                    localArticleController.localArticles;

                if (articles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 80,
                          color: theme.hintColor.withOpacity(0.6),
                        ),
                        helper.vsMedium,
                        Text(
                          'No local articles yet.',
                          style: textTheme.titleMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        helper.vsSmall,
                        Text(
                          'Tap the "+" button to add your first article.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: articles.length,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return NewsCardWidget(
                        article: article,
                        isBookmarked:
                            false, // Untuk artikel lokal, bookmark mungkin tidak relevan
                        onBookmarkTap: () {
                          // Fungsi ini sekarang akan menghapus artikel lokal
                          showDialog(
                            context: context,
                            builder: (BuildContext ctx) {
                              return AlertDialog(
                                title: const Text('Delete Article?'),
                                content: Text(
                                  'Are you sure you want to delete "${article.title}"? This action cannot be undone.',
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                actionsAlignment:
                                    MainAxisAlignment.spaceBetween,
                                actions: <Widget>[
                                  TextButton(
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color:
                                            theme.textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: theme.colorScheme.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      localArticleController.removeLocalArticle(
                                        article,
                                      );
                                      Navigator.of(ctx).pop();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '"${article.title}" deleted.',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
