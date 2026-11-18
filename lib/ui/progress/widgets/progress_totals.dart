import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';
import 'package:deutschlernen/ui/core/widgets/menu_row.dart';
import 'package:deutschlernen/ui/progress/widgets/progress_chart.dart';

/// The totals under the progress chart: a gray header naming the number
/// columns, then a row per status, top of the stack first. Also the chart's
/// legend: same dots.
class ProgressTotals extends StatelessWidget {
  const ProgressTotals({
    super.key,
    required this.labels,
    required this.periodLabel,
    required this.period,
    required this.total,
  });

  final Map<WordStatus, String> labels;

  /// Name of the period column ("7 дней"); null hides the column.
  final String? periodLabel;

  /// Per chart layer ([ProgressChart.stackOrder]); null with [periodLabel].
  final List<int>? period;
  final List<int> total;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TotalsHeader(period: periodLabel, total: strings.statsTotal),
        const SizedBox(height: 8),
        GroupedCard(
          children: [
            for (final s in ProgressChart.stackOrder.reversed)
              _TotalRow(
                status: s,
                label: labels[s]!,
                period: period?[ProgressChart.stackOrder.indexOf(s)],
                total: total[ProgressChart.stackOrder.indexOf(s)],
              ),
          ],
        ),
      ],
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
