import 'package:budget/configs/constants.dart';
import 'package:flutter/material.dart';
import 'main.dart'; // Import the main.dart file to access the themeNotifier
import 'transactions_page.dart'; // Import the transactions page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List? budgets;
  // List? transactions;
  int? spent = 0;
  int? income = 0;
  bool? loading;
  List dummyBudget = [
    {
      'id': '1',
      'label': 'School Budget',
      'amount': 300,
      'usage': 0.5,
      'createdAt': 'Today'
    },
    {
      'id': '2',
      'label': 'Home Budget',
      'amount': 150,
      'usage': 0.43,
      'createdAt': 'Today'
    },
    {
      'id': '3',
      'label': 'December Budget',
      'amount': 500,
      'usage': 0.92,
      'createdAt': 'Today'
    },
  ];

  List? transactions;

  TextEditingController budgetName = TextEditingController();
  TextEditingController budgetAmount = TextEditingController();

  // Budget, Kind, Amount, Category, Description
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
    var allBudgets = await supabase.from('budgets').select();
    setState(() {
      loading = false;
      budgets = allBudgets;
    });
    recalculateTotals();
  }

  getTransactions() async {
    setState(() {
      loading = true;
    });
    var alltx = await supabase.from('transactions').select().order('id');
    setState(() {
      loading = false;
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
  }

  addBudget(label, amount) async {
    await supabase
        .from('budgets')
        .insert({'label': label, 'amount': amount, 'spent': 0});
    await getBudgets();
  }

  addTransaction(budgetId, kind, amount, category, desc) async {
    await supabase.from('transactions').insert({
      'budget_id': budgetId,
      'kind': kind,
      'amount': int.parse(amount), // Ensure amount is sent as an integer
      'category': category,
      'desc': desc
    });
    for (var item in budgets!) {
      print(item);
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
  }

  deleteBudget(String id) async {
    await supabase.from('transactions').delete().eq('budget_id', id);
    await supabase.from('budgets').delete().eq('id', id);
    await getBudgets();
    await getTransactions();
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
                                // Budget, Kind, Amount, Category, Description
                                DropdownButton<String>(
                                  items: <String>['Add', 'Spend']
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  hint: const Text('Select Kind'),
                                  value: kind,
                                  onChanged: (value) {
                                    setState(() {
                                      kind = value;
                                    });
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
                                    setState(() {
                                      budget_id = value.toString();
                                    });
                                  },
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: TextField(
                                    controller: amount,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        hintText: 'Amount',
                                        border: InputBorder.none),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: TextField(
                                    controller: category,
                                    decoration: const InputDecoration(
                                        hintText: 'Category',
                                        border: InputBorder.none),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  height: 60,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(10)),
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
                                      await addTransaction(
                                          budget_id,
                                          kind,
                                          amount.text,
                                          category.text,
                                          desc.text);
                                      setState(() {
                                        kind = null;
                                        budget_id = null;
                                      });
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Container(
                                    width: size.width * 0.8,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    child: Center(
                                      child: Text(
                                        'Confirm',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        : const Center(
                            child: Text('Please create a budget first'),
                          ),
                  ),
                );
              });
        },
        child: const Icon(Icons.add_circle),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: size.width * 0.47,
                  height: 70,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Total Income'),
                      Text(
                        'USD $income',
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      )
                    ],
                  ),
                ),
                Container(
                  width: size.width * 0.47,
                  height: 70,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Total Spent'),
                      Text(
                        'USD $spent',
                        style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      )
                    ],
                  ),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text(
                                  'Add New Budget',
                                  style: TextStyle(fontSize: 12),
                                ),
                                content: Container(
                                  height: size.height * 0.6,
                                  width: size.width * 0.85,
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: TextField(
                                          controller: budgetName,
                                          decoration: const InputDecoration(
                                              hintText: 'Budget Name',
                                              border: InputBorder.none),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: TextField(
                                          controller: budgetAmount,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                              hintText: 'Amount',
                                              border: InputBorder.none),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          if (budgetAmount.text.isNotEmpty &&
                                              budgetName.text.isNotEmpty) {
                                            await addBudget(budgetName.text,
                                                budgetAmount.text);
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Container(
                                          width: size.width * 0.8,
                                          height: 50,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                          child: Center(
                                            child: Text(
                                              'Confirm',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
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
                          await deleteBudget(budgets![index]['id'].toString());
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                  budgetId: budgets![index]['id'].toString(),
                                  budgetLabel: budgets![index]['label'],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircularProgressIndicator(
                                value: (budgets![index]['spent']) /
                                    budgets![index]['amount'],
                                semanticsLabel: ((budgets![index]['spent'] == 0
                                            ? 1
                                            : budgets![index]['spent']) /
                                        budgets![index]['amount'])
                                    .toString(),
                                backgroundColor: Colors.grey.shade200,
                                semanticsValue: ((budgets![index]['spent'] == 0
                                            ? 1
                                            : budgets![index]['spent']) /
                                        budgets![index]['amount'])
                                    .toString(),
                                color: Colors.blueGrey,
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    budgets![index]['label'],
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  LinearProgressIndicator(
                                    value: (budgets![index]['spent'] == 0
                                            ? 1
                                            : budgets![index]['spent']) /
                                        budgets![index]['amount'],
                                    backgroundColor: Colors.grey.shade400,
                                    color: Colors.blueGrey,
                                  )
                                ],
                              ),
                              trailing: Text(
                                '${budgets![index]['amount']} USD',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
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
