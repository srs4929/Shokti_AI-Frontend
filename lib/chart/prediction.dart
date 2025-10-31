import 'dart:convert';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PredictionChart extends StatefulWidget {
  const PredictionChart({super.key});

  @override
  State<PredictionChart> createState() => _PredictionChartState();
}

class _PredictionChartState extends State<PredictionChart> {
  late final Future<List<FlSpot>> _loadChartDataFuture;
  double totalCost = 0;

  // Gradient colors for prediction
  final List<Color> gradientColors = [
    Colors.orange.shade400,
    Colors.orange.shade600,
  ];

  @override
  void initState() {
    super.initState();
    _loadChartDataFuture = _loadJsonData();
  }

  Future<List<FlSpot>> _loadJsonData() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/predict.json',
    );
    final List<dynamic> data = json.decode(jsonString);
    double curPrice = 0;
    final List<FlSpot> rdata = data
        .where(
          (point) =>
              point['Hour'] != null && point['Global_active_power'] != null,
        )
        .map((point) {
          final x = (point['Hour'] as num).toDouble();
          final yValue = point['Global_active_power'];
          final double y = yValue is num
              ? yValue.toDouble()
              : double.tryParse(yValue.toString()) ?? 0.0;
          curPrice += y * 3;
          return FlSpot(x, double.parse(y.toDouble().toStringAsFixed(2)));
        })
        .toList();

    setState(() {
      totalCost = double.parse(curPrice.toStringAsFixed(2));
    });
    return rdata;
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Colors.blueGrey,
    );
    String text = value.toInt() % 4 == 0 ? '${value.toInt()}h' : '';
    return SideTitleWidget(
      meta: meta,
      space: 8.0,
      child: Text(text, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Colors.blueGrey,
    );
    String text = '${value.toDouble().toStringAsFixed(1)} kW';
    return Text(text, style: style, textAlign: TextAlign.center);
  }

  LineChartData mainChartData(List<FlSpot> spots) {
    final double minX = spots.map<double>((s) => s.x).reduce(min);
    final double maxX = spots.map<double>((s) => s.x).reduce(max);
    final double minY = 0;
    final double maxY = spots.map<double>((s) => s.y).reduce(max) * 1.2;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: maxY / 5,
        verticalInterval: maxX / 6,
        getDrawingHorizontalLine: (value) =>
            const FlLine(color: Color(0xffe7e8ec), strokeWidth: 1),
        getDrawingVerticalLine: (value) =>
            const FlLine(color: Color(0xffe7e8ec), strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxY / 5,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xffdbe1e6)),
      ),
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors.map((c) => c.withAlpha(40)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Prediction (next day)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green[900],
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<FlSpot>>(
          future: _loadChartDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No data available.'));
            } else {
              final spots = snapshot.data!;
              return AspectRatio(
                aspectRatio: 1.7,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 18,
                    left: 12,
                    top: 6,
                    bottom: 12,
                  ),
                  child: LineChart(mainChartData(spots)),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 8),
        Text('Unit price: 3.72 Tk/kW-h'),
        Text('Total Cost: ${totalCost.toString()} Tk'),
      ],
    );
  }
}

// Backwards-compatible wrapper used by older test pages that expect `Prediction()`
class Prediction extends StatelessWidget {
  const Prediction({super.key});

  @override
  Widget build(BuildContext context) {
    return const PredictionChart();
  }
}
