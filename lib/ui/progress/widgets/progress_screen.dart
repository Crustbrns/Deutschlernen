import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/study_streak.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/tab_page.dart';
import 'package:deutschlernen/domain/models/chart_bars.dart';
import 'package:deutschlernen/ui/progress/widgets/goal_card.dart';
import 'package:deutschlernen/ui/progress/widgets/progress_chart.dart';
import 'package:deutschlernen/ui/progress/widgets/progress_totals.dart';
import 'package:deutschlernen/ui/progress/widgets/streak_card.dart';

/// Progress tab: title, the daily streak, the word goal, period switch
/// (7 / 30 / 90 days / all time), then
/// one block with the stacked chart of what was done per day, week or month,
/// and under it the totals per status, for the period and for all time (also
/// the chart's legend).
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({
    super.key,
    required this.streak,
    required this.mastered,
    required this.wordGoal,
    required this.currentTotals,
    required this.chartFor,
  });

  final StudyStreak streak;

  /// Words known now (green or "already know") out of [wordGoal].
  final int mastered;
  final int wordGoal;

  /// Words in each status now, per chart layer ("Всего").
  final List<int> currentTotals;

  /// The chart of a period: its bars and their totals per layer.
  final ({List<ChartBar> bars, List<int> totals}) Function(ChartPeriod)
  chartFor;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  var _period = ChartPeriod.week;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = AppPalette.of(context);
    final (:bars, :totals) = widget.chartFor(_period);
    final isEmpty = bars.every((b) => b.layers?.every((v) => v == 0) ?? true);
    // "All time" would show the same numbers twice: one column then.
    final periodTotal = _period == ChartPeriod.all ? null : totals;
    final periodLabels = {
      ChartPeriod.week: strings.statsPeriodWeek,
      ChartPeriod.month: strings.statsPeriodMonth,
      ChartPeriod.quarter: strings.statsPeriodQuarter,
      ChartPeriod.all: strings.statsPeriodAll,
    };
    final labels = {
      WordStatus.known: strings.statusKnown,
      WordStatus.learning: strings.statsLearning,
      WordStatus.review: strings.statsReview,
      WordStatus.learned: strings.statsLearned,
    };

    return TabPage(
      title: strings.tabProgress,
      children: [
        StreakCard(streak: widget.streak),
        const SizedBox(height: 12),
        GoalCard(known: widget.mastered, goal: widget.wordGoal),
        const SizedBox(height: 12),
        _PeriodSwitch(
          selected: _period,
          labels: periodLabels,
          onSelected: (p) => setState(() => _period = p),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(20),
          ),
          child: isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Text(
                    strings.statsEmpty,
                    textAlign: TextAlign.center,
                    style: AppListText.caption(context),
                  ),
                )
              : ProgressChart(bars: bars, byMonth: _period.byMonth),
        ),
        const SizedBox(height: 20),
        ProgressTotals(
          labels: labels,
          periodLabel: periodTotal == null ? null : periodLabels[_period],
          period: periodTotal,
          total: widget.currentTotals,
        ),
      ],
    );
  }
}

/// Four equal segments in one rounded block; the chosen one is solid
/// lime with black text (the app's selected state).
class _PeriodSwitch extends StatelessWidget {
  const _PeriodSwitch({
    required this.selected,
    required this.labels,
    required this.onSelected,
  });

  final ChartPeriod selected;
  final Map<ChartPeriod, String> labels;
  final ValueChanged<ChartPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      // Vertical padding sits inside each segment's tap area: 44 tall.
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppPalette.of(context).card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final p in ChartPeriod.values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelected(p),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: p == selected
                          ? AppColors.lime
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      labels[p]!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: p == selected
                            ? AppColors.onLime
                            : colors.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
