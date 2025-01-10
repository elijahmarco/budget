import 'package:flutter/material.dart';

class MonthlySummaryPage extends StatelessWidget {
  final Map<String, int> monthlyIncome;
  final Map<String, int> monthlyExpenditure;

  const MonthlySummaryPage({
    Key? key,
    required this.monthlyIncome,
    required this.monthlyExpenditure,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Summary'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: monthlyIncome.keys.map((month) {
          return ListTile(
            title: Text(month),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Income: USD ${monthlyIncome[month]}'),
                Text('Expenditure: USD ${monthlyExpenditure[month]}'),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
