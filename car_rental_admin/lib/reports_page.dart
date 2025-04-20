import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chart_detail_page.dart'; // New page for chart details

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  bool _isLoading = true; // Track initial loading state

  @override
  void initState() {
    super.initState();
    // Simulate initial data loading (e.g., 2 seconds delay)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
          strokeWidth: 4.0,
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(
              'Reports',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                _buildChartCard(context, 'User Distribution', Icons.bar_chart, 0),
                _buildChartCard(context, 'Revenue Trend', Icons.show_chart, 1),
                _buildChartCard(context, 'Car Utilization', Icons.directions_car, 2),
                _buildChartCard(context, 'Booking Trends', Icons.calendar_today, 3),
                _buildChartCard(context, 'Customer Growth', Icons.person_add, 4),
                _buildChartCard(context, 'Profit Margin', Icons.attach_money, 5),
                _buildChartCard(context, 'Car Availability', Icons.local_parking, 6),
                _buildChartCard(context, 'Rental Duration', Icons.access_time, 7),
                _buildChartCard(context, 'User Activity', Icons.timeline, 8),
                _buildChartCard(context, 'Sales by Region', Icons.map, 9),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(BuildContext context, String title, IconData icon, int chartType) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChartDetailPage(chartType: chartType),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Square graph on the left
            Container(
              width: 100,
              height: 100,
              child: _getSquareChartPreview(chartType),
            ),
            const SizedBox(width: 10),
            // Column with icon and title on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: Colors.yellow, size: 30),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getSquareChartPreview(int chartType) {
    switch (chartType) {
      case 0: // User Distribution (Bar)
        return BarChart(
          BarChartData(
            barGroups: [
              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 5, color: Colors.yellow, width: 10)]),
              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 8, color: Colors.yellow, width: 10)]),
            ],
            maxY: 10,
            titlesData: FlTitlesData(show: false),
            gridData: FlGridData(show: false),
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
                dotData: FlDotData(show: false),
                barWidth: 2,
              ),
            ],
            titlesData: FlTitlesData(show: false),
            gridData: FlGridData(show: false),
          ),
        );
      case 2: // Car Utilization (Pie)
        return PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(value: 60, color: Colors.blue, title: ''),
              PieChartSectionData(value: 40, color: Colors.red, title: ''),
            ],
            sectionsSpace: 0,
          ),
        );
      case 3: // Booking Trends (Bar)
        return BarChart(
          BarChartData(
            barGroups: [
              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 50, color: Colors.purple, width: 10)]),
              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 70, color: Colors.purple, width: 10)]),
            ],
            maxY: 100,
            titlesData: FlTitlesData(show: false),
            gridData: FlGridData(show: false),
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
                dotData: FlDotData(show: false),
                barWidth: 2,
              ),
            ],
            titlesData: FlTitlesData(show: false),
            gridData: FlGridData(show: false),
          ),
        );
      case 5: // Profit Margin (Pie)
        return PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(value: 70, color: Colors.teal, title: ''),
              PieChartSectionData(value: 30, color: Colors.pink, title: ''),
            ],
            sectionsSpace: 0,
          ),
        );
      case 6: // Car Availability (Bar)
        return BarChart(
          BarChartData(
            barGroups: [
              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 80, color: Colors.cyan, width: 10)]),
              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 60, color: Colors.cyan, width: 10)]),
            ],
            maxY: 100,
            titlesData: FlTitlesData(show: false),
            gridData: FlGridData(show: false),
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
                dotData: FlDotData(show: false),
                barWidth: 2,
              ),
            ],
            titlesData: FlTitlesData(show: false),
            gridData: FlGridData(show: false),
          ),
        );
      case 8: // User Activity (Pie)
        return PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(value: 50, color: Colors.indigo, title: ''),
              PieChartSectionData(value: 50, color: Colors.amber, title: ''),
            ],
            sectionsSpace: 0,
          ),
        );
      case 9: // Sales by Region (Bar)
        return BarChart(
          BarChartData(
            barGroups: [
              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 90, color: Colors.deepPurple, width: 10)]),
              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 110, color: Colors.deepPurple, width: 10)]),
            ],
            maxY: 150,
            titlesData: FlTitlesData(show: false),
            gridData: FlGridData(show: false),
          ),
        );
      default:
        return Container();
    }
  }
}