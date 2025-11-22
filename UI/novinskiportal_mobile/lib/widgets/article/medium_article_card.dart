import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/core/api_client.dart';
import 'package:novinskiportal_mobile/models/article/article_models.dart';
import 'package:novinskiportal_mobile/utils/datetime_utils.dart';

class MediumArticleCard extends StatelessWidget {
  final ArticleDto article;
  final Color categoryColor;
  final VoidCallback? onTap;

  const MediumArticleCard({
    super.key,
    required this.article,
    required this.categoryColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      color: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2.2,
              child: Image.network(
                ApiClient.resolveUrl(article.mainPhotoPath),
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.subheadline.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: categoryColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    article.headline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatRelative(article.publishedAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.comment,
                        size: 16,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// DRUGI DIZAJN PA RAZMISLITI
// import 'package:flutter/material.dart';
// import 'package:novinskiportal_mobile/models/article/article_models.dart';
// import 'package:novinskiportal_mobile/core/api_client.dart';
// import 'package:novinskiportal_mobile/utils/datetime_utils.dart';

// class MediumArticleCard extends StatelessWidget {
//   final ArticleDto article;
//   final Color categoryColor;
//   final VoidCallback? onTap;

//   const MediumArticleCard({
//     super.key,
//     required this.article,
//     required this.categoryColor,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final cs = theme.colorScheme;

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
//       color: cs.surface,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 3,
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         onTap: onTap,
//         child: AspectRatio(
//           aspectRatio: 2.2,
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               // slika u pozadini
//               Image.network(
//                 ApiClient.resolveUrl(article.mainPhotoPath),
//                 fit: BoxFit.cover,
//               ),

//               // lagani vertikalni gradient preko cijele slike
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.black.withValues(alpha: 0.05),
//                       Colors.black.withValues(alpha: 0.6),
//                     ],
//                   ),
//                 ),
//               ),

//               // bedž sa podnaslovom gore lijevo
//               Positioned(
//                 top: 12,
//                 left: 12,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: categoryColor,
//                     borderRadius: BorderRadius.circular(999),
//                   ),
//                   child: Text(
//                     article.subheadline.toUpperCase(),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: theme.textTheme.labelSmall?.copyWith(
//                       color: cs.onPrimary,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 0.6,
//                     ),
//                   ),
//                 ),
//               ),

//               // naslov + meta dole
//               Positioned(
//                 left: 12,
//                 right: 12,
//                 bottom: 12,
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withValues(alpha: 0.35),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         article.headline,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: theme.textTheme.bodyMedium?.copyWith(
//                           fontWeight: FontWeight.w600, // isto kao standard card
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.access_time,
//                             size: 14,
//                             color: Colors.white.withValues(alpha: 0.8),
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             formatRelative(article.publishedAt),
//                             style: theme.textTheme.bodyMedium?.copyWith(
//                               color: Colors.white.withValues(alpha: 0.8),
//                             ),
//                           ),
//                           const Spacer(),
//                           Icon(
//                             Icons.comment,
//                             size: 16,
//                             color: Colors.white.withValues(alpha: 0.8),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
