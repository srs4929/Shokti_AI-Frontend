import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shokti/CustomAppBar.dart';

// Stateful widget to track monthly electricity usage
class Tracker extends StatefulWidget {
  /// If [useScaffold] is false, only the body is returned
  /// This allows embedding inside another Scaffold without duplicate app bars.
  final bool useScaffold;

  const Tracker({super.key, this.useScaffold = true});

  @override
  State<Tracker> createState() => _TrackerState();
}

class _TrackerState extends State<Tracker> {
  final double threshold = 250; // Threshold in kWh for warning
  final List<int> years = [2023, 2024, 2025]; // Available years
  int selectedYear = 2025; // Default selected year

  late Map<int, Map<String, double>>
  yearlyUsage; // Stores monthly usage data for each year

  @override
  void initState() {
    super.initState();
    yearlyUsage = _generateFakeData(); // Generate sample usage data on init
  }

  /// Generates random usage data (100–400 kWh) for each month and year
  Map<int, Map<String, double>> _generateFakeData() {
    final random = Random();
    final months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    Map<int, Map<String, double>> data = {};
    for (var year in years) {
      data[year] = {
        for (var month in months)
          month: 100.0 + random.nextInt(300), // Random value between 100–400
      };
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final usageData =
        yearlyUsage[selectedYear]!; // Get data for the selected year

    // The main content of the tracker
    Widget body = Column(
      children: [
        // Year selector dropdown
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: DropdownButton<int>(
            value: selectedYear,
            items: years
                .map(
                  (year) => DropdownMenuItem(
                    value: year,
                    child: Text(
                      "$year",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (year) {
              setState(() {
                selectedYear = year!; // Update the selected year
              });
            },
          ),
        ),

        // Scrollable grid of months
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: usageData.length, // 12 months
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 boxes per row
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                String month = usageData.keys.elementAt(index);
                double value = usageData[month]!;
                bool crossed = value > threshold; // Check if threshold exceeded

                return AspectRatio(
                  aspectRatio: 1, // Makes each box square
                  child: Container(
                    decoration: BoxDecoration(
                      color: crossed ? Colors.red[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: crossed ? Colors.red : Colors.green,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 32,
                          color: crossed ? Colors.red : Colors.green,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          month,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: crossed
                                ? Colors.red[900]
                                : Colors.green[900],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${value.toStringAsFixed(0)} kWh", // Display usage
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          crossed
                              ? "Threshold Crossed"
                              : "Within Limit", // Warning
                          style: TextStyle(
                            fontSize: 11,
                            color: crossed
                                ? Colors.red[800]
                                : Colors.green[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );

    // Wrap with Scaffold if requested
    if (widget.useScaffold) {
      return Scaffold(
        appBar: const CustomAppBar(title: "Monthly Tracker"),
        body: body,
      );
    }

    return body; // Return only body if embedded in another Scaffold
  }
}
