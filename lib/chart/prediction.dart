// Import necessary Dart and Flutter libraries
import 'dart:convert';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// A StatefulWidget that visualizes predicted energy consumption data
class PredictionChart extends StatefulWidget {
  const PredictionChart({super.key});

  @override
  State<PredictionChart> createState() => _PredictionChartState();
}

class _PredictionChartState extends State<PredictionChart> {
  // A Future that loads data asynchronously from a local JSON file
  late final Future<List<FlSpot>> _loadChartDataFuture;

  // Variable to store the total predicted electricity cost
  double totalCost = 0;

  // Gradient colors for the prediction line (orange theme)
  final List<Color> gradientColors = [
    Colors.orange.shade400,
    Colors.orange.shade600,
  ];

  // Called only once when the widget is first inserted into the widget tree
  @override
  void initState() {
    super.initState();
    // Load JSON data as soon as the widget starts
    _loadChartDataFuture = _loadJsonData();
  }

  // Function to read, decode, and process JSON data for the chart
  Future<List<FlSpot>> _loadJsonData() async {
    // Load JSON data from assets folder
    final String jsonString = await rootBundle.loadString(
      'assets/data/predict.json',
    );

    // Decode the JSON string into a list of map objects
    final List<dynamic> data = json.decode(jsonString);

    double curPrice = 0; // Variable to accumulate total cost

    // Convert each JSON entry into a FlSpot (used by fl_chart)
    final List<FlSpot> rdata = data
        .where(
          // Filter out data points missing 'Hour' or 'Global_active_power'
          (point) =>
              point['Hour'] != null && point['Global_active_power'] != null,
        )
        .map((point) {
          // X-axis value: Hour of the day
          final x = (point['Hour'] as num).toDouble();

          // Y-axis value: Power usage (Global_active_power)
          final yValue = point['Global_active_power'];

          // Ensure yValue is safely converted into a double
          final double y = yValue is num
              ? yValue.toDouble()
              : double.tryParse(yValue.toString()) ?? 0.0;

          // Add to total cost (using 3 Tk/kWh for prediction)
          curPrice += y * 3;

          // Create a FlSpot (chart point) with 2-decimal precision
          return FlSpot(x, double.parse(y.toDouble().toStringAsFixed(2)));
        })
        .toList();

    // Update the state with total predicted cost
    setState(() {
      totalCost = double.parse(curPrice.toStringAsFixed(2));
    });

    // Return the processed list of FlSpot points
    return rdata;
  }

  // Creates bottom X-axis labels (hour markers)
  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Colors.blueGrey,
    );

    // Show hour labels only every 4 hours (e.g., 0h, 4h, 8h, ...)
    String text = value.toInt() % 4 == 0 ? '${value.toInt()}h' : '';

    return SideTitleWidget(
      meta: meta,
      space: 8.0,
      child: Text(text, style: style),
    );
  }

  // Creates left Y-axis labels (power in kW)
  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Colors.blueGrey,
    );

    // Format to show one decimal (e.g., “1.5 kW”)
    String text = '${value.toDouble().toStringAsFixed(1)} kW';
    return Text(text, style: style, textAlign: TextAlign.center);
  }

  // Configures the chart’s data, axis, and visual design
  LineChartData mainChartData(List<FlSpot> spots) {
    // Determine axis boundaries dynamically from data
    final double minX = spots.map<double>((s) => s.x).reduce(min);
    final double maxX = spots.map<double>((s) => s.x).reduce(max);
    final double minY = 0;
    final double maxY =
        spots.map<double>((s) => s.y).reduce(max) * 1.2; // Add padding

    return LineChartData(
      // Grid configuration
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

      // Axis title configurations
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
            getTitlesWidget: bottomTitleWidgets, // Hour labels
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxY / 5,
            getTitlesWidget: leftTitleWidgets, // Power labels
            reservedSize: 42,
          ),
        ),
      ),

      // Border styling around the chart
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xffdbe1e6)),
      ),

      // Set chart bounds
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,

      // Define how the line chart should look
      lineBarsData: [
        LineChartBarData(
          spots: spots, // Data points
          isCurved: true, // Smooth curve
          gradient: LinearGradient(colors: gradientColors), // Line gradient
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true), // Show data point dots
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((c) => c.withAlpha(40))
                  .toList(), // Light fill area
            ),
          ),
        ),
      ],
    );
  }

  // Build method to render the widget UI
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // Title for the chart
        Text(
          'Prediction (next day)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green[900],
          ),
        ),

        const SizedBox(height: 12),

        // Display chart using FutureBuilder (waits for data to load)
        FutureBuilder<List<FlSpot>>(
          future: _loadChartDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show loading spinner while waiting
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Show error message if loading fails
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // Handle case when no data is available
              return const Center(child: Text('No data available.'));
            } else {
              // Data loaded successfully → render chart
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
                  // Draw line chart with processed data
                  child: LineChart(mainChartData(spots)),
                ),
              );
            }
          },
        ),

        const SizedBox(height: 8),

        // Show pricing info and total cost
        Text('Unit price: 3.72 Tk/kW-h'),
        Text('Total Cost: ${totalCost.toString()} Tk'),
      ],
    );
  }
}

// Compatibility wrapper — older widgets/pages can use `Prediction()` instead
class Prediction extends StatelessWidget {
  const Prediction({super.key});

  @override
  Widget build(BuildContext context) {
    return const PredictionChart(); // Returns the main chart widget
  }
}
