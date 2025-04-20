import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChartDetailPage extends StatelessWidget {
  final int chartType;

  const ChartDetailPage({super.key, required this.chartType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          _getChartTitle(chartType),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed View',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 400,
              child: _getDetailedChart(chartType),
            ),
          ],
        ),
      ),
    );
  }

  String _getChartTitle(int chartType) {
    switch (chartType) {
      case 0: return 'User Distribution';
      case 1: return 'Revenue Trend';
      case 2: return 'Car Utilization';
      case 3: return 'Booking Trends';
      case 4: return 'Customer Growth';
      case 5: return 'Profit Margin';
      case 6: return 'Car Availability';
      case 7: return 'Rental Duration';
      case 8: return 'User Activity';
      case 9: return 'Sales by Region';
      default: return 'Chart';
    }
  }

  Widget _getDetailedChart(int chartType) {
    switch (chartType) {
      case 0: // User Distribution (Bar)
        return BarChart(
          BarChartData(
            barGroups: [
              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 5, color: Colors.yellow, width: 20)]),
              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 8, color: Colors.yellow, width: 20)]),
              BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 3, color: Colors.yellow, width: 20)]),
            ],
            maxY: 10,
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text('Loc ${value.toInt()}', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                ),
              ),
            ),
          ),
        );
      case 1: // Revenue Trend (Line)
        return LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 100),
                  FlSpot(1, 150),
                  FlSpot(2, 200),
                  FlSpot(3, 130),
                ],
                color: Colors.green,
                dotData: FlDotData(show: true),
                barWidth: 2,
              ),
            ],
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text('Day ${value.toInt()}', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text('\$${value.toInt()}K', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                ),
              ),
            ),
            gridData: FlGridData(show: true),
          ),
        );
      case 2: // Car Utilization (Pie)
        return PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(value: 60, color: Colors.blue, title: '60%', titleStyle: GoogleFonts.poppins(color: Colors.white)),
              PieChartSectionData(value: 40, color: Colors.red, title: '40%', titleStyle: GoogleFonts.poppins(color: Colors.white)),
            ],
            sectionsSpace: 2,
          ),
        );
      case 3: // Booking Trends (Bar)
        return BarChart(
          BarChartData(
            barGroups: [
              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 50, color: Colors.purple, width: 20)]),
              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 70, color: Colors.purple, width: 20)]),
              BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 30, color: Colors.purple, width: 20)]),
            ],
            maxY: 100,
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text('Week ${value.toInt()}', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                ),
              ),
            ),
          ),
        );
      case 4: // Customer Growth (Line)
        return LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 50),
                  FlSpot(1, 80),
                  FlSpot(2, 120),
                  FlSpot(3, 150),
                ],
                color: Colors.orange,
                dotData: FlDotData(show: true),
                barWidth: 2,
              ),
            ],
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text('Month ${value.toInt()}', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                ),
              ),
            ),
            gridData: FlGridData(show: true),
          ),
        );
      case 5: // Profit Margin (Pie)
        return PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(value: 70, color: Colors.teal, title: '70%', titleStyle: GoogleFonts.poppins(color: Colors.white)),
              PieChartSectionData(value: 30, color: Colors.pink, title: '30%', titleStyle: GoogleFonts.poppins(color: Colors.white)),
            ],
            sectionsSpace: 2,
          ),
        );
      case 6: // Car Availability (Bar)
        return BarChart(
          BarChartData(
            barGroups: [
              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 80, color: Colors.cyan, width: 20)]),
              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 60, color: Colors.cyan, width: 20)]),
              BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 90, color: Colors.cyan, width: 20)]),
            ],
            maxY: 100,
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text('Day ${value.toInt()}', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                ),
              ),
            ),
          ),
        );
      case 7: // Rental Duration (Line)
        return LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 10),
                  FlSpot(1, 15),
                  FlSpot(2, 20),
                  FlSpot(3, 25),
                ],
                color: Colors.lime,
                dotData: FlDotData(show: true),
                barWidth: 2,
              ),
            ],
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text('Week ${value.toInt()}', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                ),
              ),
            ),
            gridData: FlGridData(show: true),
          ),
        );
      case 8: // User Activity (Pie)
        return PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(value: 50, color: Colors.indigo, title: '50%', titleStyle: GoogleFonts.poppins(color: Colors.white)),
              PieChartSectionData(value: 50, color: Colors.amber, title: '50%', titleStyle: GoogleFonts.poppins(color: Colors.white)),
            ],
            sectionsSpace: 2,
          ),
        );
      case 9: // Sales by Region (Bar)
        return BarChart(
          BarChartData(
            barGroups: [
              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 90, color: Colors.deepPurple, width: 20)]),
              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 110, color: Colors.deepPurple, width: 20)]),
              BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 80, color: Colors.deepPurple, width: 20)]),
            ],
            maxY: 150,
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text('Reg ${value.toInt()}', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text('\$${value.toInt()}K', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                ),
              ),
            ),
          ),
        );
      default:
        return Container();
    }
  }
}