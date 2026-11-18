import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/day_snapshot.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';
import 'package:deutschlernen/ui/core/widgets/menu_row.dart';
import 'package:deutschlernen/ui/core/widgets/tab_page.dart';
import 'package:deutschlernen/domain/models/chart_bars.dart';
import 'package:deutschlernen/ui/progress/widgets/progress_chart.dart';

/// Progress tab: title, period switch (7 / 30 / 90 days / all time), then
/// one block with the stacked chart of what was done per day, week or month,
/// and under it the totals per status, for the period and for all time (also
/// the chart's legend).
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key, required this.history});

  /// Daily snapshots, keyed by local midnight.
  final Map<DateTime, DaySnapshot> history;

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
    final isEmpty = bars.every((b) => b.layers?.every((v) => v == 0) ?? true);
    // "All time" would show the same numbers twice: one column then.
    final periodTotal = _period == ChartPeriod.all ? null : periodTotals(bars);
    final total = latestCounts(widget.history).stack;
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
        _TotalsHeader(
          period: periodTotal == null ? null : periodLabels[_period],
          total: strings.statsTotal,
        ),
        const SizedBox(height: 8),
        // Also the chart's legend: same dots, top of the stack first.
        GroupedCard(
          children: [
            for (final s in ProgressChart.stackOrder.reversed)
              _TotalRow(
                status: s,
                label: labels[s]!,
                period: periodTotal?[ProgressChart.stackOrder.indexOf(s)],
                total: total[ProgressChart.stackOrder.indexOf(s)],
              ),
          ],
        ),
      ],
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

/// Width of a number column under the chart, so the header and the rows
/// line up.
const _columnWidth = 76.0;

/// Gray column names above the totals: the period (none for all time) and
/// "total".
class _TotalsHeader extends StatelessWidget {
  const _TotalsHeader({required this.period, required this.total});

  final String? period;
  final String total;

  @override
  Widget build(BuildContext context) {
    final style = MenuRow.hintStyle(context, soft: true);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (final text in [?period, total])
            SizedBox(
              width: _columnWidth,
              child: Text(
                text,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
        ],
      ),
    );
  }
}

/// Colored dot, status name, the chosen period's count (null for all time)
/// and the count for all time.
class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.status,
    required this.label,
    required this.period,
    required this.total,
  });

  final WordStatus status;
  final String label;
  final int? period;
  final int total;

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
          for (final n in [?period, total])
            SizedBox(
              width: _columnWidth,
              child: Text(
                '$n',
                textAlign: TextAlign.end,
                style: AppListText.title(colors),
              ),
            ),
        ],
      ),
    );
  }
}
