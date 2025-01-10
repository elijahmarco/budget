import 'package:budget/configs/constants.dart';
import 'package:flutter/material.dart';
import 'main.dart'; // Import the main.dart file to access the themeNotifier
import 'transactions_page.dart'; // Import the transactions page
import 'package:intl/intl.dart'; // Add this import for date formatting

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List? budgets;
  int? spent = 0;
  int? income = 0;
  bool? loading;
  List? transactions;

  TextEditingController budgetName = TextEditingController();
  TextEditingController budgetAmount = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController category = TextEditingController();
  TextEditingController desc = TextEditingController();
  String? budget_id;
  String? kind;

  @override
  void initState() {
    getBudgets();
    getTransactions();
    super.initState();
  }

  getBudgets() async {
    setState(() {
      loading = true;
    });
    try {
      var allBudgets = await supabase.from('budgets').select();
      setState(() {
        budgets = allBudgets;
      });
      recalculateTotals();
    } catch (e) {
      // Handle error
      print('Error fetching budgets: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  getTransactions() async {
    setState(() {
      loading = true;
    });
    try {
      var alltx = await supabase.from('transactions').select().order('id');
      setState(() {
        transactions = alltx;
      });
      if (transactions?.length != 0) {
        num totalin = 0;
        num totalout = 0;
        for (var element in transactions!) {
          if (element['kind'] == 'Add') {
            totalin = totalin + element['amount'];
          } else {
            totalout = totalout + element['amount'];
          }
        }
        setState(() {
          income = totalin as int;
          spent = totalout as int;
        });
      }
    } catch (e) {
      // Handle error
      print('Error fetching transactions: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  addBudget(label, amount) async {
    try {
      await supabase
          .from('budgets')
          .insert({'label': label, 'amount': amount, 'spent': 0});
      await getBudgets();
    } catch (e) {
      // Handle error
      print('Error adding budget: $e');
    }
  }

  addTransaction(budgetId, kind, amount, category, desc) async {
    try {
      await supabase.from('transactions').insert({
        'budget_id': budgetId,
        'kind': kind,
        'amount': int.parse(amount), // Ensure amount is sent as an integer
        'category': category,
        'desc': desc
      });
      for (var item in budgets!) {
        if (item['id'].toString() == budgetId) {
          if (kind == 'Add') {
            var newtotal = (item['amount'] as int) + int.parse(amount);
            await supabase
                .from('budgets')
                .update({'amount': newtotal.toString()}).eq('id', budgetId);
          } else {
            var newtotal = item['spent'] + int.parse(amount);
            await supabase
                .from('budgets')
                .update({'spent': newtotal.toString()}).eq('id', budgetId);
          }
        }
      }
      await getBudgets();
      await getTransactions();
    } catch (e) {
      // Handle error
      print('Error adding transaction: $e');
    }
  }

  deleteBudget(String id) async {
    try {
      await supabase.from('transactions').delete().eq('budget_id', id);
      await supabase.from('budgets').delete().eq('id', id);
      await getBudgets();
      await getTransactions();
    } catch (e) {
      // Handle error
      print('Error deleting budget: $e');
    }
  }

  recalculateTotals() {
    if (budgets != null) {
      num totalIncome = 0;
      num totalSpent = 0;
      for (var budget in budgets!) {
        totalIncome += budget['amount'];
        totalSpent += budget['spent'];
      }
      setState(() {
        income = totalIncome as int;
        spent = totalSpent as int;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // Group transactions by month
    final Map<String, List<Map<String, dynamic>>> groupedByMonth = {};
    if (transactions != null) {
      for (var transaction in transactions!) {
        String month = DateFormat.yMMMM()
            .format(DateTime.parse(transaction['created_at']));
        if (groupedByMonth[month] == null) {
          groupedByMonth[month] = [];
        }
        groupedByMonth[month]!.add(transaction);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                // Handle About tap
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AddTransactionDialog(
                  size: size,
                  budgets: budgets,
                  budget_id: budget_id,
                  kind: kind,
                  amount: amount,
                  category: category,
                  desc: desc,
                  addTransaction: addTransaction,
                );
              });
        },
        child: const Icon(Icons.add_circle),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: loading == true
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, top: 8.0),
                    child: Text('Welcome'),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Your Budget Tracker',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InfoCard(
                        title: 'Total Income',
                        amount: 'USD $income',
                        color: Colors.green,
                      ),
                      InfoCard(
                        title: 'Total Spent',
                        amount: 'USD $spent',
                        color: Colors.red,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Budgets',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AddBudgetDialog(
                                      size: size,
                                      budgetName: budgetName,
                                      budgetAmount: budgetAmount,
                                      addBudget: addBudget,
                                    );
                                  });
                            },
                            icon: const Icon(Icons.add_circle))
                      ],
                    ),
                  ),
                  budgets != null
                      ? ListView.builder(
                          itemCount: budgets!.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Dismissible(
                              key: Key(budgets![index]['id'].toString()),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) async {
                                await deleteBudget(
                                    budgets![index]['id'].toString());
                              },
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TransactionsPage(
                                        budgetId:
                                            budgets![index]['id'].toString(),
                                        budgetLabel: budgets![index]['label'],
                                      ),
                                    ),
                                  );
                                },
                                child: BudgetTile(budget: budgets![index]),
                              ),
                            );
                          })
                      : SizedBox(
                          width: size.width,
                          height: 120,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Transactions',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  groupedByMonth.isNotEmpty
                      ? ListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: groupedByMonth.entries.map((entry) {
                            return ExpansionTile(
                              title: Text(entry.key),
                              children: entry.value.map((transaction) {
                                return ListTile(
                                  title: Text(transaction['desc']),
                                  subtitle: Text(DateFormat.yMMMd().format(
                                      DateTime.parse(
                                          transaction['created_at']))),
                                  trailing: Text('\$${transaction['amount']}'),
                                );
                              }).toList(),
                            );
                          }).toList(),
                        )
                      : const Center(
                          child: Text('No transactions available'),
                        ),
                ],
              ),
            ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;

  const InfoCard({
    Key? key,
    required this.title,
    required this.amount,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.47,
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class BudgetTile extends StatelessWidget {
  final Map<String, dynamic> budget;

  const BudgetTile({
    Key? key,
    required this.budget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircularProgressIndicator(
          value: (budget['spent']) / budget['amount'],
          semanticsLabel:
              ((budget['spent'] == 0 ? 1 : budget['spent']) / budget['amount'])
                  .toString(),
          backgroundColor: Colors.grey.shade200,
          semanticsValue:
              ((budget['spent'] == 0 ? 1 : budget['spent']) / budget['amount'])
                  .toString(),
          color: Colors.blueGrey,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              budget['label'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            LinearProgressIndicator(
              value: (budget['spent'] == 0 ? 1 : budget['spent']) /
                  budget['amount'],
              backgroundColor: Colors.grey.shade400,
              color: Colors.blueGrey,
            ),
          ],
        ),
        trailing: Text(
          '${budget['amount']} USD',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}

class AddTransactionDialog extends StatelessWidget {
  final Size size;
  final List? budgets;
  final String? budget_id;
  final String? kind;
  final TextEditingController amount;
  final TextEditingController category;
  final TextEditingController desc;
  final Function addTransaction;

  const AddTransactionDialog({
    Key? key,
    required this.size,
    required this.budgets,
    required this.budget_id,
    required this.kind,
    required this.amount,
    required this.category,
    required this.desc,
    required this.addTransaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Transactions'),
      content: SizedBox(
        width: size.width * 0.85,
        height: size.height * 0.8,
        child: budgets != null
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      items: <String>['Add', 'Spend'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      hint: const Text('Select Kind'),
                      value: kind,
                      onChanged: (value) {
                        // Update state
                      },
                    ),
                    DropdownButton(
                      items: budgets!.map((budget) {
                        return DropdownMenuItem(
                          value: budget['id'].toString(),
                          child: Text(budget['label']),
                        );
                      }).toList(),
                      value: budget_id,
                      hint: const Text('Select Budget'),
                      onChanged: (value) {
                        // Update state
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: amount,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Amount',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: category,
                        decoration: const InputDecoration(
                          hintText: 'Category',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      height: 60,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: desc,
                        decoration: const InputDecoration(
                          hintText: 'TX Description',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (amount.text.isNotEmpty &&
                            category.text.isNotEmpty &&
                            kind != null &&
                            budget_id != null) {
                          await addTransaction(budget_id, kind, amount.text,
                              category.text, desc.text);
                          // Reset state
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        width: size.width * 0.8,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        child: Center(
                          child: Text(
                            'Confirm',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const Center(
                child: Text('Please create a budget first'),
              ),
      ),
    );
  }
}

class AddBudgetDialog extends StatelessWidget {
  final Size size;
  final TextEditingController budgetName;
  final TextEditingController budgetAmount;
  final Function addBudget;

  const AddBudgetDialog({
    Key? key,
    required this.size,
    required this.budgetName,
    required this.budgetAmount,
    required this.addBudget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Budget', style: TextStyle(fontSize: 12)),
      content: Container(
        height: size.height * 0.6,
        width: size.width * 0.85,
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: budgetName,
                decoration: const InputDecoration(
                  hintText: 'Budget Name',
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: budgetAmount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Amount',
                  border: InputBorder.none,
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                if (budgetAmount.text.isNotEmpty &&
                    budgetName.text.isNotEmpty) {
                  await addBudget(budgetName.text, budgetAmount.text);
                  Navigator.pop(context);
                }
              },
              child: Container(
                width: size.width * 0.8,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Center(
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListTile(
        leading: const Icon(Icons.brightness_6),
        title: const Text('Dark Mode'),
        trailing: Switch(
          value: themeNotifier.value == ThemeMode.dark,
          onChanged: (value) {
            setState(() {
              themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
            });
          },
        ),
      ),
    );
  }
}
