import 'dart:io'; // Import untuk File
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/article_model.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';

class NewsCardWidget extends StatelessWidget {
  final Article article;
  final bool isBookmarked;
  final VoidCallback onBookmarkTap;

  const NewsCardWidget({
    super.key,
    required this.article,
    required this.isBookmarked,
    required this.onBookmarkTap,
  });

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Theme.of(context).hintColor.withOpacity(0.5),
          size: 50,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    bool isLocalArticle = article.url == null || article.url!.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          context.pushNamed(RouteName.articleDetail, extra: article);
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Card(
          elevation: 0.5,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(
              color: theme.dividerColor.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  // Image
                  _buildImageWidget(context),
                  // Bookmark Icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: onBookmarkTap,
                      customBorder: const CircleBorder(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isLocalArticle
                              ? Icons.delete_outline_rounded
                              : (isBookmarked
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded),
                          color: isLocalArticle
                              ? theme.colorScheme.error
                              : Colors.white,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Teknologi", // Static category as per image
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    helper.vsSmall,
                    Text(
                      article.title,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textTheme.bodyLarge?.color,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    helper.vsSmall,
                    Text(
                      article.description ??
                          'Industri kecerdasan buatan di Indonesia mengalami pertumbuhan signifikan dengan berbagai inovasi dari startup lokal.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    helper.vsMedium,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          article.author ?? "Ahmad Rizki",
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textTheme.bodyLarge?.color,
                          ),
                        ),
                        helper.hsTiny,
                        Text(
                          "•",
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        helper.hsTiny,
                        Text(
                          '5 min read', // Static as per image
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          article.publishedAt != null
                              ? DateFormat(
                                  'dd MMM yyyy',
                                  'id_ID',
                                ).format(article.publishedAt!)
                              : '15 Jan 2024',
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final String? imageUrl = article.urlToImage;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildImagePlaceholder(context),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              color: theme.highlightColor,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
              ),
            );
          },
        );
      } else {
        File imageFile = File(imageUrl);
        if (imageFile.existsSync()) {
          return Image.file(
            imageFile,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildImagePlaceholder(context),
          );
        }
      }
    }
    // Default placeholder if no image
    return _buildImagePlaceholder(context);
  }
}
