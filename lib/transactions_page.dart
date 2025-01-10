import 'package:budget/configs/constants.dart';
import 'package:flutter/material.dart';

class TransactionsPage extends StatefulWidget {
  final String budgetId;
  final String budgetLabel;

  const TransactionsPage(
      {required this.budgetId, required this.budgetLabel, Key? key})
      : super(key: key);

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List? transactions;
  bool? loading;

  @override
  void initState() {
    getTransactions();
    super.initState();
  }

  getTransactions() async {
    setState(() {
      loading = true;
    });
    var alltx = await supabase
        .from('transactions')
        .select()
        .eq('budget_id', widget.budgetId)
        .order('id');
    setState(() {
      loading = false;
      transactions = alltx;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budgetLabel),
      ),
      body: loading == true
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : transactions != null
              ? ListView.builder(
                  itemCount: transactions!.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        dense: true,
                        title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(transactions![index]['category']),
                            ]),
                        subtitle: Text(
                          transactions![index]['desc'],
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        trailing: Text(
                          '${transactions![index]['amount']} USD',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: transactions![index]['kind'] == 'Add'
                                  ? Colors.green
                                  : Colors.red),
                        ),
                      ),
                    );
                  })
              : Center(
                  child: Text('No transactions found'),
                ),
    );
  }
}
