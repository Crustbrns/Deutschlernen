import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/status_counts.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';
import 'package:deutschlernen/ui/progress/view_models/progress_chart_data.dart';
import 'package:deutschlernen/ui/progress/widgets/progress_chart.dart';

/// Progress tab: title, period switch (7 / 30 / 90 days / all time), then
/// one block with the stacked chart of word statuses, and under it the
/// current count per status (also the chart's legend).
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key, required this.history});

  /// Daily status counts, keyed by local midnight.
  final Map<DateTime, StatusCounts> history;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  var _period = ChartPeriod.week;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = AppPalette.of(context);
    final bars = chartBars(_period, widget.history, DateTime.now());
    final isEmpty = bars.every((b) => (b.counts?.total ?? 0) == 0);
    // Today's snapshot (written at start-up): the counts right now.
    final latest = widget.history.isEmpty
        ? const StatusCounts()
        : widget.history[widget.history.keys.reduce(
            (a, b) => a.isAfter(b) ? a : b,
          )]!;
    final labels = {
      WordStatus.known: strings.statusKnown,
      WordStatus.learning: strings.statsLearning,
      WordStatus.review: strings.statsReview,
      WordStatus.learned: strings.statsLearned,
    };

    return SafeArea(
      bottom: false,
      child: ListView(
        // + bottom inset: the block stays above the floating bar.
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          // Same title placement as the other tabs.
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Text(
              strings.tabProgress,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(letterSpacing: -0.5),
            ),
          ),
          _PeriodSwitch(
            selected: _period,
            labels: {
              ChartPeriod.week: strings.statsPeriodWeek,
              ChartPeriod.month: strings.statsPeriodMonth,
              ChartPeriod.quarter: strings.statsPeriodQuarter,
              ChartPeriod.all: strings.statsPeriodAll,
            },
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
                : ProgressChart(bars: bars),
          ),
          const SizedBox(height: 12),
          // Also the chart's legend: same dots, top of the stack first.
          GroupedCard(
            children: [
              for (final s in ProgressChart.stackOrder.reversed)
                _TotalRow(
                  status: s,
                  label: labels[s]!,
                  count: latest.stack[ProgressChart.stackOrder.indexOf(s)],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Four equal segments in one rounded block; the chosen one is blue
/// (the app's selected state).
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
      padding: const EdgeInsets.all(4),
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p == selected
                        ? AppColors.accentBlue.withValues(alpha: 0.14)
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
                          ? AppColors.accentBlue
                          : colors.onSurface,
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

/// Colored dot, status name and how many words have it now.
class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.status,
    required this.label,
    required this.count,
  });

  final WordStatus status;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: ProgressChart.colorFor(status, context),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppListText.subtitle(colors))),
          Text('$count', style: AppListText.title(colors)),
        ],
      ),
    );
  }
}
