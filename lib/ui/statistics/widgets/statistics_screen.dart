import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/status_counts.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/statistics/view_models/progress_chart_data.dart';
import 'package:deutschlernen/ui/statistics/widgets/progress_chart.dart';

/// Progress tab: title, period switch (7 / 30 / 90 days / all time), then
/// one block with the legend and the stacked chart of word statuses.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key, required this.history});

  /// Daily status counts, keyed by local midnight.
  final Map<DateTime, StatusCounts> history;

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  var _period = ChartPeriod.week;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = AppPalette.of(context);
    final bars = chartBars(_period, widget.history, DateTime.now());
    final isEmpty = bars.every((b) => (b.counts?.total ?? 0) == 0);

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
              strings.tabStatistics,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Legend(
                  labels: {
                    WordStatus.known: strings.statusKnown,
                    WordStatus.learning: strings.statusLearning,
                    WordStatus.review: strings.statsReview,
                    WordStatus.learned: strings.statsLearned,
                  },
                ),
                const SizedBox(height: 16),
                if (isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Text(
                      strings.statsEmpty,
                      textAlign: TextAlign.center,
                      style: AppListText.caption(context),
                    ),
                  )
                else
                  ProgressChart(bars: bars),
              ],
            ),
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

/// Colored dot + status name, in the chart's stacking order.
class _Legend extends StatelessWidget {
  const _Legend({required this.labels});

  final Map<WordStatus, String> labels;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        for (final s in ProgressChart.stackOrder)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.forWordStatus(s, colors),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                labels[s]!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
