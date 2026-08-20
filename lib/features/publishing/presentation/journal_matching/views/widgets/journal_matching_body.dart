import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masar_pro/core/presentation/widgets/primary_button.dart';
import 'package:masar_pro/core/presentation/widgets/pub/ai_worker_card.dart';
import 'package:masar_pro/core/presentation/widgets/pub/empty_state.dart';
import 'package:masar_pro/core/presentation/widgets/pub/journal_match_card.dart';

import '../../../../domain/entities/journal_match.dart';
import '../../../bloc/publishing_bloc/publishing_bloc.dart';
import '../../../manuscript_preparation/views/manuscript_preparation_page.dart';

class JournalMatchingBody extends StatefulWidget {
  const JournalMatchingBody({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  State<JournalMatchingBody> createState() => _JournalMatchingBodyState();
}

class _JournalMatchingBodyState extends State<JournalMatchingBody> {
  JournalMatch? _selected;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<PublishingBloc>();
    if (bloc.state is! PublishingJournalsMatched &&
        bloc.state is! PublishingLoading) {
      bloc.add(MatchJournalsRequested(widget.projectId));
    }
  }

  void _onPrepareManuscript() {
    final selected = _selected;
    if (selected == null) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ManuscriptPreparationPage(
          projectId: widget.projectId,
          journalId: selected.journalId,
          journalName: selected.journalName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublishingBloc, PublishingState>(
      builder: (context, state) {
        if (state is PublishingLoading || state is PublishingInitial) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: AIWorkerCard(
              taskTitle: 'Matching journals...',
              progress: 0.62,
              state: AIWorkerState.processing,
            ),
          );
        }

        if (state is PublishingFailure) {
          return EmptyState(
            message: state.error.isEmpty
                ? 'No matching journals found.'
                : state.error,
          );
        }

        if (state is PublishingJournalsMatched) {
          final matches = state.matches;
          if (matches.isEmpty) {
            return const EmptyState(
              message: 'No matching journals found.',
            );
          }

          return _JournalMatchesView(
            matches: matches,
            selectedJournalId: _selected?.journalId,
            onSelect: (match) => setState(() => _selected = match),
            onPrepare: _selected == null ? null : _onPrepareManuscript,
          );
        }

        return const EmptyState(
          message: 'No matching journals found.',
        );
      },
    );
  }
}

class _JournalMatchesView extends StatelessWidget {
  const _JournalMatchesView({
    required this.matches,
    required this.selectedJournalId,
    required this.onSelect,
    required this.onPrepare,
  });

  final List<JournalMatch> matches;
  final String? selectedJournalId;
  final ValueChanged<JournalMatch> onSelect;
  final VoidCallback? onPrepare;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            itemCount: matches.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final match = matches[index];
              return JournalMatchCard(
                journalName: match.journalName,
                quartile: match.quartile,
                publisher: '',
                apcPrice: _formatApc(match.apc),
                matchScore: _normalizedScore(match.matchScore),
                isSelected: selectedJournalId == match.journalId,
                onSelect: () => onSelect(match),
              );
            },
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: PrimaryButton(
            text: 'Prepare Manuscript for this Journal',
            onPressed: onPrepare,
            width: double.infinity,
            height: 52,
          ),
        ),
      ],
    );
  }

  static String _formatApc(double apc) {
    if (apc <= 0) return 'Free';
    if (apc == apc.roundToDouble()) return '\$${apc.round()}';
    return '\$${apc.toStringAsFixed(2)}';
  }

  static double _normalizedScore(double raw) {
    if (raw <= 1) return raw.clamp(0.0, 1.0);
    return (raw / 100).clamp(0.0, 1.0);
  }
}
