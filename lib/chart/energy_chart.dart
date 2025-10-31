// Import required libraries
import 'dart:convert'; // For decoding JSON files
import 'dart:math'; // For performing mathematical operations like min/max
import 'package:fl_chart/fl_chart.dart'; // For creating charts
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For loading assets (like local JSON files)

// Main widget that displays the energy usage chart
class EnergyChart extends StatefulWidget {
  const EnergyChart({super.key});

  @override
  State<EnergyChart> createState() => _EnergyChartState();
}

class _EnergyChartState extends State<EnergyChart> {
  // A Future that will hold the chart data once loaded
  late final Future<List<FlSpot>> _loadChartDataFuture;

  // Variable to hold the total electricity cost
  double totalCost = 0;

  // Colors for the line chart gradient
  final List<Color> gradientColors = [
    Colors.green.shade400,
    Colors.green.shade600,
  ];

  // Called once when the widget is first created
  @override
  void initState() {
    super.initState();
    // Start loading JSON data when widget initializes
    _loadChartDataFuture = _loadJsonData();
  }

  // Function to load and parse data from a JSON file in assets
  Future<List<FlSpot>> _loadJsonData() async {
    // Read the file as a string
    final String jsonString = await rootBundle.loadString(
      'assets/data/data.json', // Location of the JSON file
    );

    // Decode the string into a List of dynamic objects
    final List<dynamic> data = json.decode(jsonString);

    double curPrice = 0; // Used to calculate total cost

    // Map the JSON data into a list of FlSpot (chart points)
    final List<FlSpot> rdata = data
        .where(
          // Keep only entries that have both Hour and Global_active_power
          (point) =>
              point['Hour'] != null && point['Global_active_power'] != null,
        )
        .map((point) {
          // X-axis value: Hour
          final x = (point['Hour'] as num).toDouble();

          // Y-axis value: Global_active_power
          final yValue = point['Global_active_power'];

          // Convert yValue safely into double
          final double y = yValue is num
              ? yValue.toDouble()
              : double.tryParse(yValue.toString()) ?? 0.0;

          // Accumulate cost using price per kWh = 3.72 Tk
          curPrice += y * 3.72;

          // Return a chart point (FlSpot) with (x, y)
          return FlSpot(x, double.parse(y.toDouble().toStringAsFixed(2)));
        })
        .toList();

    // Update total cost in the widget’s state
    setState(() {
      totalCost = double.parse(curPrice.toStringAsFixed(2));
    });

    // Return list of data points to be plotted
    return rdata;
  }

  // Function to generate bottom axis (X-axis) labels — shows hours
  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Colors.blueGrey,
    );

    // Show a label every 4 hours (0h, 4h, 8h, etc.)
    String text = value.toInt() % 4 == 0 ? '${value.toInt()}h' : '';

    return SideTitleWidget(
      meta: meta,
      space: 8.0,
      child: Text(text, style: style),
    );
  }

  // Function to generate left axis (Y-axis) labels — shows power in kW
  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Colors.blueGrey,
    );

    // Format label with one decimal (e.g., “1.5 kW”)
    String text = '${value.toDouble().toStringAsFixed(1)} kW';
    return Text(text, style: style, textAlign: TextAlign.center);
  }

  // Function to prepare chart configuration and styling
  LineChartData mainChartData(List<FlSpot> spots) {
    // Determine chart bounds using min/max
    final double minX = spots.map<double>((s) => s.x).reduce(min);
    final double maxX = spots.map<double>((s) => s.x).reduce(max);
    final double minY = 0;
    final double maxY =
        spots.map<double>((s) => s.y).reduce(max) * 1.2; // Add padding

    return LineChartData(
      // Configure grid lines
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

      // Configure axis titles and labels
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
            getTitlesWidget: bottomTitleWidgets, // Bottom labels (hours)
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxY / 5,
            getTitlesWidget: leftTitleWidgets, // Left labels (kW)
            reservedSize: 42,
          ),
        ),
      ),

      // Draw border around the chart
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xffdbe1e6)),
      ),

      // Define chart bounds
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,

      // Line chart setup
      lineBarsData: [
        LineChartBarData(
          spots: spots, // The data points to draw
          isCurved: true, // Smooth curve instead of sharp angles
          gradient: LinearGradient(
            colors: gradientColors,
          ), // Gradient color line
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true), // Show dots for data points
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((c) => c.withAlpha(40))
                  .toList(), // Light fill under line
            ),
          ),
        ),
      ],
    );
  }

  // Widget build method — defines the full UI of this component
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // Title of the chart
        Text(
          'Energy (today)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green[900],
          ),
        ),

        const SizedBox(height: 12),

        // Asynchronously load and render chart
        FutureBuilder<List<FlSpot>>(
          future: _loadChartDataFuture, // The Future from initState()
          builder: (context, snapshot) {
            // If still loading, show a spinner
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // If error occurs while loading
            else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            // If data is empty or null
            else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No data available.'));
            }
            // If data loaded successfully
            else {
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
                  // Draw the chart using mainChartData()
                  child: LineChart(mainChartData(spots)),
                ),
              );
            }
          },
        ),

        const SizedBox(height: 8),

        // Display pricing info
        Text('Unit price: 3.72  Tk/kW-h'),
        Text('Total Cost: ${totalCost.toString()} Tk'),
      ],
    );
  }
}
