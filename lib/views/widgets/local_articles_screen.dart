import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/local_article_controller.dart';

import '../../data/models/article_model.dart';
import '../utils/helper.dart' as helper;
import 'news_card_widget.dart';

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
                    // PERUBAHAN: Judul halaman diubah agar lebih jelas
                    Text(
                      "Artikel Saya",
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
            child: Consumer<LocalArticleController>(
              builder: (context, localArticleController, child) {
                final List<Article> articles =
                    localArticleController.localArticles;

                // PERUBAHAN: Pesan saat daftar kosong dibuat lebih informatif
                if (articles.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.post_add_outlined,
                            size: 80,
                            color: theme.hintColor.withOpacity(0.6),
                          ),
                          helper.vsMedium,
                          Text(
                            'Anda belum mempublikasikan artikel',
                            style: textTheme.titleMedium?.copyWith(
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          helper.vsSmall,
                          Text(
                            "Tekan tombol '+' di bawah untuk mulai menulis artikel pertama Anda.",
                            style: textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
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
                        isBookmarked: false,
                        onBookmarkTap: () {
                          // Fungsi untuk menghapus artikel lokal
                          showDialog(
                            context: context,
                            builder: (BuildContext ctx) {
                              return AlertDialog(
                                title: const Text('Hapus Artikel?'),
                                content: Text(
                                  'Apakah Anda yakin ingin menghapus "${article.title}"? Aksi ini tidak bisa dibatalkan.',
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                actionsAlignment:
                                    MainAxisAlignment.spaceBetween,
                                actions: <Widget>[
                                  TextButton(
                                    child: Text(
                                      'Batal',
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
                                      'Hapus',
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
                                              '"${article.title}" dihapus.',
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
