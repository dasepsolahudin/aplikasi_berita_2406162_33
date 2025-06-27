import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/article_model.dart';
import '../utils/helper.dart' as helper;

class NewsDetailScreen extends StatelessWidget {
  final Article article;

  const NewsDetailScreen({super.key, required this.article});

  // Fungsi helper untuk placeholder dan error gambar (tidak berubah)
  Widget _buildLoadingPlaceholder(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    double imageHeight,
  ) {
    return Container(
      width: double.infinity,
      height: imageHeight,
      color: theme.highlightColor.withOpacity(0.5),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildImageErrorPlaceholder(
    BuildContext context,
    ThemeData theme,
    double imageHeight, {
    String? message,
  }) {
    return Container(
      width: double.infinity,
      height: imageHeight,
      color: theme.cardColor.withOpacity(0.8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: theme.hintColor.withOpacity(0.7),
            size: 60,
          ),
          if (message != null) ...[
            helper.vsSmall,
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double imageHeight = screenHeight * 0.35;

    String formattedDate = article.publishedAt != null
        ? DateFormat(
            'EEEE, dd MMMM yyyy, HH:mm',
            'id_ID',
          ).format(article.publishedAt!)
        : 'Tanggal tidak tersedia';

    String authorDisplay = article.author?.isNotEmpty ?? false
        ? article.author!
        : (article.sourceName?.isNotEmpty ?? false
              ? article.sourceName!
              : 'Sumber tidak diketahui');

    Widget imageDisplayWidget;
    if (article.urlToImage != null && article.urlToImage!.isNotEmpty) {
      if (article.urlToImage!.startsWith('http')) {
        imageDisplayWidget = Image.network(
          article.urlToImage!,
          width: double.infinity,
          height: imageHeight,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingPlaceholder(
              context,
              theme,
              colorScheme,
              imageHeight,
            );
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint(
              "Error loading network image in Detail: ${article.urlToImage}, Error: $error",
            );
            return _buildImageErrorPlaceholder(
              context,
              theme,
              imageHeight,
              message: "Gagal memuat gambar",
            );
          },
        );
      } else {
        File imageFile = File(article.urlToImage!);
        if (imageFile.existsSync()) {
          imageDisplayWidget = Image.file(
            imageFile,
            width: double.infinity,
            height: imageHeight,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint(
                "Error loading local file image in Detail: ${article.urlToImage}, Error: $error",
              );
              return _buildImageErrorPlaceholder(
                context,
                theme,
                imageHeight,
                message: "Gambar lokal tidak ditemukan",
              );
            },
          );
        } else {
          debugPrint(
            "Local image file does not exist in Detail: ${article.urlToImage}",
          );
          imageDisplayWidget = _buildImageErrorPlaceholder(
            context,
            theme,
            imageHeight,
            message: "File gambar tidak ada",
          );
        }
      }
    } else {
      imageDisplayWidget = _buildImageErrorPlaceholder(
        context,
        theme,
        imageHeight,
        message: "Gambar tidak tersedia",
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.appBarTheme.foregroundColor,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          article.sourceName ?? 'Detail Berita',
          style: theme.appBarTheme.titleTextStyle,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // --- PERUBAHAN FUNGSI SHARE DI SINI ---
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: theme.appBarTheme.foregroundColor,
            ),
            onPressed: () {
              // Teks yang akan dibagikan
              final String shareText =
                  "Baca artikel menarik ini: ${article.title}\n\n${article.url ?? 'Aplikasi Berita Anda'}";
              // Menggunakan Share.share untuk memunculkan dialog share
              Share.share(
                shareText,
                subject: "Artikel dari Berita Anda: ${article.title}",
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Konten detail berita tidak ada perubahan, tetap sama
            Card(
              margin: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0),
              elevation: 3.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              clipBehavior: Clip.antiAlias,
              color: theme.cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag:
                        article.urlToImage ??
                        (article.title +
                            (article.publishedAt?.toIso8601String() ?? "")),
                    child: imageDisplayWidget,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          article.title,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textTheme.displayLarge?.color,
                          ),
                        ),
                        helper.vsMedium,
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 16,
                              color: theme.hintColor,
                            ),
                            helper.hsTiny,
                            Expanded(
                              child: Text(
                                authorDisplay,
                                style: textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        helper.vsSuperTiny,
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: theme.hintColor,
                            ),
                            helper.hsTiny,
                            Text(
                              formattedDate,
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
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.content != null && article.content!.isNotEmpty)
                    Text(
                      article.content!.contains(' [+')
                          ? article.content!.substring(
                              0,
                              article.content!.indexOf(' [+'),
                            )
                          : article.content!,
                      style: textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.justify,
                    )
                  else if (article.description != null &&
                      article.description!.isNotEmpty)
                    Text(
                      article.description!,
                      style: textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.justify,
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Text(
                          "Konten detail tidak tersedia untuk artikel ini.",
                          style: textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ),
                    ),
                  helper.vsLarge,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
