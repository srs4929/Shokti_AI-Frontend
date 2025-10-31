import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shokti/CustomAppBar.dart';

class Tracker extends StatefulWidget {
  /// If [useScaffold] is false the widget returns only its body
  /// so it can be embedded inside another Scaffold without
  /// producing duplicate app bars.
  final bool useScaffold;

  const Tracker({super.key, this.useScaffold = true});

  @override
  State<Tracker> createState() => _TrackerState();
}

class _TrackerState extends State<Tracker> {
  final double threshold = 250;
  final List<int> years = [2023, 2024, 2025];
  int selectedYear = 2025;

  late Map<int, Map<String, double>> yearlyUsage;

  @override
  void initState() {
    super.initState();
    yearlyUsage = _generateFakeData();
  }

  /// Generate random usage data for multiple years
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
          month: 100.0 + random.nextInt(300), // 100–400 kWh
      };
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final usageData = yearlyUsage[selectedYear]!;

    Widget body = Column(
      children: [
        // Year selector
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
                selectedYear = year!;
              });
            },
          ),
        ),

        // Grid of months (scrollable)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: usageData.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 per row
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                String month = usageData.keys.elementAt(index);
                double value = usageData[month]!;
                bool crossed = value > threshold;

                return AspectRatio(
                  aspectRatio: 1, // keeps each box square
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
                          "${value.toStringAsFixed(0)} kWh",
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          crossed ? "Threshold Crossed" : "Within Limit",
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

    if (widget.useScaffold) {
      return Scaffold(
        appBar: const CustomAppBar(title: "Monthly Tracker"),
        body: body,
      );
    }

    return body;
  }
}
