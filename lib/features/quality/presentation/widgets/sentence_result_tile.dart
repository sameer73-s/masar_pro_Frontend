import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/sentence_match.dart';

class SentenceResultTile extends StatelessWidget {
  final SentenceMatch match;

  const SentenceResultTile({
    super.key,
    required this.match,
  });

  Color _getSimilarityColor(int pct) {
    if (pct < 30) return const Color(0xFF16A34A);
    if (pct < 60) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSimilarityColor(match.similarityPct);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      elevation: 0,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Text(
                '${match.similarityPct}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          title: Text(
            match.sentence,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, height: 1.5),
            textDirection: TextDirection.rtl,
          ),
          subtitle: match.isFlagged
              ? const Row(
                  children: [
                    SizedBox(height: 8),
                    Badge(
                      label: Text('مُعلَّمة', style: TextStyle(fontSize: 10)),
                      backgroundColor: Color(0xFFDC2626),
                    ),
                  ],
                )
              : null,
          children: [
            if (match.topSource != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 16, color: Color(0xFF185FA5)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final url = Uri.parse(match.topSource!);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        },
                        child: Text(
                          match.topSource!,
                          style: const TextStyle(
                            color: Color(0xFF185FA5),
                            decoration: TextDecoration.underline,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
