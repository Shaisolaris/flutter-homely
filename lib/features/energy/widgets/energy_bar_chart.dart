import 'package:flutter/material.dart';

/// One bar's worth of data for [EnergyBarChart].
class EnergyBarEntry {
  const EnergyBarEntry({required this.label, required this.kwh, required this.color});

  final String label;
  final double kwh;
  final Color color;
}

/// A hand-drawn vertical bar chart, one bar per room, with a value label
/// above each bar and a row of room-name labels underneath.
class EnergyBarChart extends StatelessWidget {
  const EnergyBarChart({super.key, required this.entries, this.height = 180});

  final List<EnergyBarEntry> entries;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );

    if (entries.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(child: Text('No energy data yet', style: labelStyle)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _EnergyBarPainter(
              entries: entries,
              gridColor: scheme.outlineVariant.withValues(alpha: 0.5),
              valueColor: scheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final entry in entries)
              Expanded(
                child: Text(
                  entry.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _EnergyBarPainter extends CustomPainter {
  _EnergyBarPainter({required this.entries, required this.gridColor, required this.valueColor});

  final List<EnergyBarEntry> entries;
  final Color gridColor;
  final Color valueColor;

  static const int _gridLineCount = 3;
  static const double _topLabelSpace = 20;

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    var maxKwh = entries.first.kwh;
    for (final entry in entries) {
      if (entry.kwh > maxKwh) maxKwh = entry.kwh;
    }
    if (maxKwh <= 0) maxKwh = 1;
    // Headroom so the tallest bar's value label never touches the top edge.
    final scaleMax = maxKwh * 1.2;

    final chartHeight = size.height - _topLabelSpace;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= _gridLineCount; i++) {
      final y = _topLabelSpace + chartHeight * i / _gridLineCount;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final slotWidth = size.width / entries.length;
    final barWidth = (slotWidth * 0.5).clamp(16.0, 56.0).toDouble();

    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final centerX = slotWidth * i + slotWidth / 2;
      final barHeightRatio = (entry.kwh / scaleMax).clamp(0.0, 1.0).toDouble();
      final barHeight = chartHeight * barHeightRatio;
      final top = _topLabelSpace + chartHeight - barHeight;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(centerX - barWidth / 2, top, barWidth, barHeight),
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      );
      canvas.drawRRect(rect, Paint()..color = entry.color);

      final textPainter = TextPainter(
        text: TextSpan(
          text: entry.kwh.toStringAsFixed(1),
          style: TextStyle(color: valueColor, fontSize: 11, fontWeight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, top - textPainter.height - 4));
    }
  }

  @override
  bool shouldRepaint(covariant _EnergyBarPainter oldDelegate) {
    return oldDelegate.entries != entries ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.valueColor != valueColor;
  }
}
