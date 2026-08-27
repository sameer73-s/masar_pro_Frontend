import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/change_item.dart';

enum ViewMode { before, after, comparison }

class DiffTextViewer extends StatefulWidget {
  final String originalText;
  final String humanizedText;
  final List<ChangeItem> changes;

  const DiffTextViewer({
    super.key,
    required this.originalText,
    required this.humanizedText,
    required this.changes,
  });

  @override
  State<DiffTextViewer> createState() => _DiffTextViewerState();
}

class _DiffTextViewerState extends State<DiffTextViewer> {
  ViewMode _viewMode = ViewMode.comparison;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildTextContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SegmentedButton<ViewMode>(
            segments: [
              ButtonSegment(value: ViewMode.before, label: Text('viewModeBefore'.tr())),
              ButtonSegment(value: ViewMode.comparison, label: Text('viewModeComparison'.tr())),
              ButtonSegment(value: ViewMode.after, label: Text('viewModeAfter'.tr())),
            ],
            selected: {_viewMode},
            onSelectionChanged: (Set<ViewMode> newSelection) {
              setState(() {
                _viewMode = newSelection.first;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            onPressed: () {
              // Copy logic
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent() {
    String textToShow;
    if (_viewMode == ViewMode.before) {
      textToShow = widget.originalText;
    } else if (_viewMode == ViewMode.after) {
      textToShow = widget.humanizedText;
    } else {
      // Simple text display. Advanced comparison highlighting can be done here.
      return Directionality(
        textDirection: Directionality.of(context),
        child: SelectableText(
          widget.humanizedText,
          style: const TextStyle(height: 1.6, fontSize: 15, color: Color(0xFF0F172A)),
        ),
      );
    }

    return Directionality(
      textDirection: Directionality.of(context),
      child: SelectableText(
        textToShow,
        style: const TextStyle(height: 1.6, fontSize: 15, color: Color(0xFF0F172A)),
      ),
    );
  }
}
