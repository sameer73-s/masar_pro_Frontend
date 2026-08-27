import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/presentation/widgets/app_success_dialog.dart';
import '../../../../core/presentation/widgets/custom_app_bar.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../bloc/research_bloc.dart';
import '../bloc/research_event.dart';
import '../bloc/research_state.dart';
import '../widgets/animated_progress_ring.dart';
import '../widgets/premium_badge_widget.dart';
import '../widgets/previous_research_tile.dart';
import 'research_form_screen.dart';
import 'research_progress_screen.dart';

/// الشاشة الرئيسية لميزة بحوث التخرج
class ResearchHubScreen extends StatefulWidget {
  const ResearchHubScreen({super.key});

  @override
  State<ResearchHubScreen> createState() => _ResearchHubScreenState();
}

class _ResearchHubScreenState extends State<ResearchHubScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ResearchBloc>().add(LoadResearchHistoryEvent());
  }

  void _navigateToForm() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ResearchBloc>(),
          child: const ResearchFormScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: kBgLight,
        appBar: CustomAppBar(title: 'researchHubTitle'),
        body: BlocConsumer<ResearchBloc, ResearchState>(
          listener: (context, state) {
            // Navigate once when a job starts — not on every progress tick
            // (would stack ProgressScreens and leak routes/listeners).
            if (state is ResearchStarting) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ResearchBloc>(),
                    child: const ResearchProgressScreen(),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Premium badge
                  const PremiumBadgeWidget(),
                  const SizedBox(height: 20),

                  // Hero card
                  _HeroCard(onStart: _navigateToForm),
                  const SizedBox(height: 24),

                  // Previous research section
                  if (state is ResearchFormReady &&
                      state.history.isNotEmpty) ...[
                    Text(
                      'researchPreviousSection'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...state.history.map(
                      (job) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: PreviousResearchTile(
                          job: job,
                          onDownload: job.downloadUrl.isNotEmpty
                              ? () => _openFile(job.downloadUrl)
                              : null,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openFile(String path) {
    AppSuccessDialog.show(
      context,
      message: 'researchOpenFile'.tr(args: [path]),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final VoidCallback onStart;
  const _HeroCard({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(kCardRadius + 4),
        boxShadow: [
          BoxShadow(
            color: kGoldAccent.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        children: [
          // أيقونة كبيرة
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: kResearchBg,
              shape: BoxShape.circle,
              border: Border.all(
                  color: kGoldAccent.withOpacity(0.3), width: 2),
            ),
            child: const Center(
              child: Text(
                '📚',
                style: TextStyle(fontSize: 36),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'researchHeroTitle'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'researchHeroSubtitle'.tr(),
            style: const TextStyle(
              fontSize: 13,
              color: kTextSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // زر البدء
          PrimaryButton(
            text: 'researchStartNew'.tr(),
            onPressed: onStart,
            icon: Icons.auto_awesome,
            width: double.infinity,
            height: 52,
          ),
        ],
      ),
    );
  }
}
