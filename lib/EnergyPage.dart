import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class EnergyPage extends StatefulWidget {
  const EnergyPage({super.key});

  @override
  State<EnergyPage> createState() => _EnergyPageState();
}

class _EnergyPageState extends State<EnergyPage> {
  late final Future<List<Map<String, dynamic>>> _dataFuture;
  int _selectedRoom = 0; // 0 -> Room1 (Sub_metering_1), 1 -> Room2, 2 -> Room3
  final double unitPrice = 3.72; // Price per kWh
  final List<double> thresholds = [
    30.0,
    100.0,
    150.0,
  ]; // Thresholds for Room 1, 2, and 3

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadJson();
  }

  Future<List<Map<String, dynamic>>> _loadJson() async {
    final s = await rootBundle.loadString('assets/data/data.json');
    final parsed = json.decode(s) as List<dynamic>;
    return parsed.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // (old aggregation helper removed; we now render room-wise line charts)

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Energy by Room',
              style:
                  (Theme.of(context).textTheme.titleLarge ??
                          const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ))
                      .copyWith(color: Colors.green[900]),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(3, (i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text('Room ${i + 1}'),
                    selected: _selectedRoom == i,
                    onSelected: (sel) {
                      if (sel) setState(() => _selectedRoom = i);
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _dataFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text('Error loading data: ${snap.error}'),
                    );
                  }
                  final data = snap.data ?? [];
                  if (data.isEmpty)
                    return const Center(
                      child: Text('No energy data available'),
                    );

                  // For a line-style chart (room-wise), build FlSpots for the selected Sub_metering
                  final key = 'Sub_metering_${_selectedRoom + 1}';
                  final spots = <FlSpot>[];
                  for (final point in data) {
                    final hour = (point['Hour'] is num)
                        ? (point['Hour'] as num).toDouble()
                        : double.tryParse('${point['Hour']}') ?? 0.0;
                    final raw = point[key];
                    final y = (raw is num)
                        ? raw.toDouble()
                        : double.tryParse('$raw') ?? 0.0;
                    spots.add(FlSpot(hour, double.parse(y.toStringAsFixed(2))));
                  }

                  final double minX = spots.isNotEmpty
                      ? spots.map((s) => s.x).reduce((a, b) => a < b ? a : b)
                      : 0.0;
                  final double maxX = spots.isNotEmpty
                      ? spots.map((s) => s.x).reduce((a, b) => a > b ? a : b)
                      : 23.0;
                  final double rawMaxY = spots.isNotEmpty
                      ? spots.map((s) => s.y).reduce((a, b) => a > b ? a : b)
                      : 0.0;
                  // Ensure Y axis never goes negative and has a sensible top bound.
                  final double maxY = (rawMaxY * 1.2).clamp(
                    1.0,
                    double.infinity,
                  );

                  LineChartData lineData() {
                    final gradientColors = [
                      Colors.green.shade300,
                      Colors.green.shade700,
                    ];
                    return LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        getDrawingHorizontalLine: (v) =>
                            const FlLine(color: Color(0xffe7e8ec)),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 2,
                            getTitlesWidget: (value, meta) {
                              final v = value.toInt();
                              return SideTitleWidget(
                                meta: meta,
                                space: 6.0,
                                child: Text(
                                  '${v}h',
                                  style: const TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: (maxY / 5).clamp(0.1, maxY),
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  value.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 11,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              );
                            },
                            reservedSize: 50,
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: const Color(0xffdbe1e6)),
                      ),
                      minX: minX,
                      maxX: maxX,
                      // enforce non-negative Y axis
                      minY: 0,
                      maxY: maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          gradient: LinearGradient(colors: gradientColors),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: gradientColors
                                  .map((c) => c.withAlpha(60))
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  final total = spots.fold(0.0, (p, s) => p + s.y);
                  final totalKWh = total / 1000;
                  final totalCost = totalKWh * unitPrice;
                  final threshold = thresholds[_selectedRoom];

                  return ListView(
                    children: [
                      if (total > threshold)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_rounded,
                                color: Colors.red.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Warning: Room ${_selectedRoom + 1} consumption exceeds threshold!\n'
                                  'Current: ${total.toStringAsFixed(1)} Wh\n'
                                  'Threshold: $threshold Wh\n'
                                  'You are wasting ${(((total - threshold)/1000) * unitPrice).toStringAsFixed(2)} Tk by exceeding the threshold!',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Room ${_selectedRoom + 1}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 16),
                                  AspectRatio(
                                    aspectRatio: 1.7,
                                    child: LineChart(lineData()),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Total Consumption',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${total.toStringAsFixed(1)} Wh',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: total > threshold
                                                  ? Colors.red.shade700
                                                  : Colors.green[900],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Total Cost',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${totalCost.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} Tk',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green[900],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // legend helper removed - not used in the line-chart room view
}
