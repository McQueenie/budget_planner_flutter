import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:budget_planner_flutter/models/budget.dart';
import 'package:budget_planner_flutter/models/monthly_stats.dart';

class SpendingChart extends StatelessWidget {
  final List<DailyExpense> dailyExpenses;
  final Budget? budget;
  final int currentMonth;
  final int currentYear;

  const SpendingChart({
    super.key,
    required this.dailyExpenses,
    required this.budget,
    required this.currentMonth,
    required this.currentYear,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cumulative Expenses',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            if (dailyExpenses.isEmpty)
              const SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.show_chart,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No expense data available',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 350,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: _getYAxisInterval(),
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.white.withOpacity(0.1),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: _getXAxisInterval(),
                          getTitlesWidget: (double value, TitleMeta meta) {
                            if (value.toInt() <= 0 || value.toInt() > _getMaxDay()) {
                              return Container();
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: _getYAxisInterval(),
                          reservedSize: 60,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return Text(
                              '${value.toInt()}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    minX: 1,
                    maxX: _getMaxDay().toDouble(),
                    minY: 0,
                    maxY: _getMaxExpense(),
                    lineBarsData: [
                      // Cumulative expenses line
                      LineChartBarData(
                        spots: _generateCumulativeSpots(),
                        isCurved: true,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF56565), Color(0xFFED8936)],
                        ),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: const Color(0xFFF56565),
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFF56565).withOpacity(0.3),
                              const Color(0xFFF56565).withOpacity(0.1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Budget line (if budget is set)
                      if (budget != null)
                        LineChartBarData(
                          spots: _generateBudgetLine(),
                          isCurved: false,
                          color: const Color(0xFF10B981),
                          barWidth: 2,
                          isStrokeCapRound: false,
                          dotData: const FlDotData(show: false),
                          dashArray: [5, 5], // Dashed line
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateCumulativeSpots() {
    final Map<int, double> expensesByDay = {};
    final now = DateTime.now();
    final isCurrentMonth = currentYear == now.year && currentMonth == now.month;
    final currentDay = isCurrentMonth ? now.day : _getDaysInMonth();
    
    // Initialize all days with 0 up to current day (or all days if not current month)
    for (int i = 1; i <= currentDay; i++) {
      expensesByDay[i] = 0;
    }
    
    // Fill with actual expense data
    for (final expense in dailyExpenses) {
      final day = DateTime.parse(expense.date).day;
      if (day <= currentDay) {
        expensesByDay[day] = expense.totalExpenses;
      }
    }
    
    // Calculate cumulative expenses
    double cumulative = 0;
    final List<FlSpot> spots = [];
    
    for (int day = 1; day <= currentDay; day++) {
      cumulative += expensesByDay[day] ?? 0;
      spots.add(FlSpot(day.toDouble(), cumulative));
    }
    
    return spots;
  }

  List<FlSpot> _generateBudgetLine() {
    if (budget == null) return [];
    
    final now = DateTime.now();
    final isCurrentMonth = currentYear == now.year && currentMonth == now.month;
    final maxDay = isCurrentMonth ? now.day : _getDaysInMonth();
    
    return [
      FlSpot(1, budget!.amount),
      FlSpot(maxDay.toDouble(), budget!.amount),
    ];
  }

  int _getDaysInMonth() {
    return DateTime(currentYear, currentMonth + 1, 0).day;
  }

  int _getMaxDay() {
    final now = DateTime.now();
    final isCurrentMonth = currentYear == now.year && currentMonth == now.month;
    return isCurrentMonth ? now.day : _getDaysInMonth();
  }

  double _getMaxExpense() {
    if (dailyExpenses.isEmpty && budget == null) return 100;
    
    double maxValue = 0;
    
    // Calculate cumulative max expense
    if (dailyExpenses.isNotEmpty) {
      final cumulativeSpots = _generateCumulativeSpots();
      if (cumulativeSpots.isNotEmpty) {
        maxValue = cumulativeSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
      }
    }
    
    // Consider budget value
    if (budget != null) {
      maxValue = maxValue > budget!.amount ? maxValue : budget!.amount;
    }
    
    // Add 20% padding to the top
    return maxValue > 0 ? maxValue * 1.2 : 100;
  }

  double _getXAxisInterval() {
    final maxDay = _getMaxDay();
    if (maxDay <= 7) return 1;
    if (maxDay <= 14) return 2;
    if (maxDay <= 28) return 5;
    return 10;
  }

  double _getYAxisInterval() {
    final maxExpense = _getMaxExpense();
    if (maxExpense <= 20) return 5;
    if (maxExpense <= 50) return 10;
    if (maxExpense <= 100) return 20;
    if (maxExpense <= 200) return 25;
    if (maxExpense <= 500) return 50;
    if (maxExpense <= 1000) return 100;
    if (maxExpense <= 2000) return 200;
    if (maxExpense <= 5000) return 500;
    return 1000;
  }
}