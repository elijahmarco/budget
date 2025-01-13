import 'package:flutter/material.dart';

class MonthlySummaryPage extends StatelessWidget {
  final Map<String, int> monthlyIncome;
  final Map<String, int> monthlyExpenditure;

  const MonthlySummaryPage({
    super.key,
    required this.monthlyIncome,
    required this.monthlyExpenditure,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Summary'),
      ),
      body: monthlyIncome.isNotEmpty && monthlyExpenditure.isNotEmpty
          ? ListView(
              padding: const EdgeInsets.all(16.0),
              children: monthlyIncome.keys.map((month) {
                return ListTile(
                  title: Text(month),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Income: UGX ${monthlyIncome[month]}'),
                      Text('Expenditure: UGX ${monthlyExpenditure[month]}'),
                    ],
                  ),
                );
              }).toList(),
            )
          : const Center(
              child: Text('No data available for the monthly summary'),
            ),
    );
  }
}
