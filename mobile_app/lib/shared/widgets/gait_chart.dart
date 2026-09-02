import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';

class GaitChart extends StatelessWidget {
  final List<FlSpot> thighSpots;
  final List<FlSpot> shinSpots;
  final String title;

  const GaitChart({
    Key? key,
    required this.thighSpots,
    required this.shinSpots,
    this.title = 'Real-Time IMU Angular Velocity (deg/s)',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                _LegendItem(color: AppColors.primary, label: 'Thigh'),
                const SizedBox(width: 8),
                _LegendItem(color: AppColors.secondary, label: 'Shin'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 20,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.divider,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (val, meta) => Text(
                      '${val.toInt()}°',
                      style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
                    ),
                  ),
                ),
                bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              minY: -60,
              maxY: 80,
              lineBarsData: [
                LineChartBarData(
                  spots: thighSpots.isNotEmpty ? thighSpots : [const FlSpot(0, 0)],
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withOpacity(0.08),
                  ),
                ),
                LineChartBarData(
                  spots: shinSpots.isNotEmpty ? shinSpots : [const FlSpot(0, 0)],
                  isCurved: true,
                  color: AppColors.secondary,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.secondary.withOpacity(0.08),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
