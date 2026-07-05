import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../viewmodel/company_provider.dart';
import '../theme/app_text_styles.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);
    final primaryBlue = const Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text('Recruitment Insights', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1565C0)),
            onPressed: () => ref.refresh(analyticsProvider),
          ),
        ],
      ),
      body: analyticsAsync.when(
        data: (data) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetricOverview(data),
              const SizedBox(height: 32),
              _buildSectionTitle('Application Volume (Last 7 Days)'),
              _buildDynamicChart(data['dailyTrend'] as Map<DateTime, int>?, primaryBlue),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Hiring Conversion Funnel'),
              _buildConversionFunnel(data, primaryBlue),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Top Talent Sources (Colleges)'),
              _buildCollegeBars(data['topColleges'] as List<dynamic>?, primaryBlue),
              
              const SizedBox(height: 32),
              _buildSectionTitle('In-Demand Skills'),
              _buildSkillChips(data['topSkills'] as List<dynamic>?, primaryBlue),
              
              const SizedBox(height: 60),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Analytics Sync Error: $e')),
      ),
    );
  }

  Widget _buildMetricOverview(Map<String, dynamic> data) {
    return Row(
      children: [
        _miniStatCard('Hiring Rate', '${data['hiringRate']?.toStringAsFixed(1) ?? 0}%', Icons.check_circle_outline, Colors.teal),
        const SizedBox(width: 12),
        _miniStatCard('Shortlist Rate', '${data['conversionRate']?.toStringAsFixed(1) ?? 0}%', Icons.star_outline, Colors.orange),
      ],
    );
  }

  Widget _miniStatCard(String label, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicChart(Map<DateTime, int>? trend, Color color) {
    if (trend == null || trend.isEmpty) return const SizedBox(height: 200, child: Center(child: Text('No trend data available')));

    final sortedDates = trend.keys.toList()..sort();
    final spots = <FlSpot>[];
    for (int i = 0; i < sortedDates.length; i++) {
      spots.add(FlSpot(i.toDouble(), trend[sortedDates[i]]!.toDouble()));
    }

    return Container(
      height: 240,
      padding: const EdgeInsets.fromLTRB(10, 24, 24, 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  if (val.toInt() >= sortedDates.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(DateFormat('dd').format(sortedDates[val.toInt()]), style: const TextStyle(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.bold)),
                  );
                }
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionFunnel(Map<String, dynamic> data, Color primary) {
    final total = data['totalApplications'] ?? 0;
    final shortlisted = data['shortlistedCount'] ?? 0;
    final hired = data['hiredCount'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _funnelBar('Applied', total, total > 0 ? 1.0 : 0.1, primary),
          _funnelBar('Shortlisted', shortlisted, total > 0 ? shortlisted / total : 0.1, Colors.orange),
          _funnelBar('Hired', hired, total > 0 ? hired / total : 0.1, Colors.teal),
        ],
      ),
    );
  }

  Widget _funnelBar(String label, int count, double width, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text('$count Candidates', style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        FractionallySizedBox(
          widthFactor: width.clamp(0.05, 1.0),
          child: Container(height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5))),
        ),
      ],
    ),
  );

  Widget _buildCollegeBars(List<dynamic>? colleges, Color primary) {
    if (colleges == null || colleges.isEmpty) return const Text('Waiting for more data...');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: colleges.map((c) {
          final name = c['name'] as String;
          final count = c['count'] as int;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: count / (colleges.first['count'] as int),
                    backgroundColor: Colors.grey[100],
                    color: primary.withValues(alpha: 0.6),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSkillChips(List<dynamic>? skills, Color primary) {
    if (skills == null || skills.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: skills.map((s) => Chip(
        backgroundColor: Colors.white,
        side: BorderSide(color: primary.withValues(alpha: 0.1)),
        label: Text("${s['name']} (${s['count']})", style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 12)),
      )).toList(),
    );
  }

  Widget _buildSectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
  );
}

