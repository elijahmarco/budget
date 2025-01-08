import 'package:budget/configs/constants.dart';
import 'package:flutter/material.dart';

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
        }
        else {
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
    await supabase.from('budgets').insert({
      'label': label,
      'amount': amount,
      'spent': 0
    });
    await getBudgets();
  }

  addTransaction(budget_id, kind, amount, category, desc) async {
    await supabase.from('transactions').insert({
      'budget_id': budget_id,
      'kind': kind,
      'amount': amount,
      'category': category,
      'desc': desc
    });
    for (var item in budgets!) {
      print(item);
      if (item['id'].toString() == budget_id) {
        if (kind == 'Add') {
          var newtotal = (item['amount'] as int) + double.parse(amount);
          await supabase.from('budgets').update({
            'amount': newtotal.toString()
          }).eq('id',budget_id);
        }
        else {
          var newtotal = item['spent'] + double.parse(amount);
          await supabase.from('budgets').update({
            'spent': newtotal.toString()
          }).eq('id',budget_id);
        }
      }
    }
    // await budgets!.map((item) async {
    //   print(item);

    // });
    await getBudgets();
    await getTransactions();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        showDialog(context: context, builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add Transactions'),
            content:  Container(
              width: size.width * 0.85,
              height: size.height * 0.8,
              child: budgets != null ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Budget, Kind, Amount, Category, Description
                    DropdownButton<String>(
                      items: <String>['Add', 'Spend'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      hint: Text('Select Kind'),
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
                      hint: Text('Select Budget'),
                      onChanged: (value) {
                        setState(() {
                          budget_id = value.toString();
                        });
                      },
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: TextField(
                        controller: amount,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: 'Amount',
                            border: InputBorder.none
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: TextField(
                        controller: category,
                        decoration: InputDecoration(
                            hintText: 'Category',
                            border: InputBorder.none
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      height: 60,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: TextField(
                        controller: desc,
                        decoration: InputDecoration(
                            hintText: 'TX Description',
                            border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (amount.text.isNotEmpty && category.text.isNotEmpty && kind != null && budget_id != null) {
                          await addTransaction(budget_id, kind, amount.text, category.text, desc.text);
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
                            color: Colors.amber
                        ),
                        child: Center(
                          child: Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold),),
                        ),
                      ),
                    )
                  ],
                ),
              ) : Center(
                child: Text('Please create a budget first'),
              ),
            ),
          );
        });
      }, child: Icon(Icons.add_circle), backgroundColor: Colors.amber,),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('Budget Tracker'),
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left:8.0, top: 8.0),
              child: Text('Welcome'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Your Budget Tracker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: size.width * 0.47,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Total Income'),
                      Text('USD $income', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 20),)
                    ],
                  ),
                ),
                Container(
                  width: size.width * 0.47,
                  height: 70,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Total Spent'),
                      Text('USD $spent', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20),)
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
                  Text('My Budgets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                  IconButton(onPressed: (){
                    showDialog(context: context, builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Add New Budget', style: TextStyle(fontSize: 12),),
                        content: Container(
                          height: size.height * 0.6,
                          width: size.width * 0.85,
                          padding: EdgeInsets.all(8),
                          child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              margin: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: TextField(
                                controller: budgetName,
                                decoration: InputDecoration(
                                  hintText: 'Budget Name',
                                  border: InputBorder.none
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8),
                              margin: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: TextField(
                                controller: budgetAmount,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    hintText: 'Amount',
                                    border: InputBorder.none
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (budgetAmount.text.isNotEmpty && budgetName.text.isNotEmpty) {
                                  await addBudget(budgetName.text, budgetAmount.text);
                                  Navigator.pop(context);
                                }
                              },
                              child: Container(
                                width: size.width * 0.8,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.amber
                                ),
                                child: Center(
                                  child: Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold),),
                                ),
                              ),
                            )
                          ],
                        ),),
                      );
                    });
                  }, icon: Icon(Icons.add_circle))
                ],
              ),
            ),
            budgets != null ? ListView.builder(
              itemCount: budgets!.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: ListTile(
                      leading: CircularProgressIndicator(
                        value: (budgets![index]['spent']) / budgets![index]['amount'],
                        semanticsLabel: ((budgets![index]['spent'] == 0 ? 1 : budgets![index]['spent']) / budgets![index]['amount']).toString(),
                        backgroundColor: Colors.grey.shade200,
                        semanticsValue: ((budgets![index]['spent'] == 0 ? 1 : budgets![index]['spent']) / budgets![index]['amount']).toString(),
                        color: Colors.amber,
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(budgets![index]['label'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                          LinearProgressIndicator(
                            value: (budgets![index]['spent'] == 0 ? 1 : budgets![index]['spent']) / budgets![index]['amount'],
                            backgroundColor: Colors.grey.shade400,
                            color: Colors.amber,
                          )
                        ],
                      ),
                      // subtitle: Text(dummyBudget[index]['createdAt'], style: TextStyle(fontSize: 12, color: Colors.grey),),
                      trailing: Text('${budgets![index]['amount']} USD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                    ),
                  );
                }
            ): SizedBox(
              width: size.width,
              height: 120,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.amber,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
            ),
            transactions != null ? ListView.builder(
                itemCount: transactions!.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: ListTile(
                      dense: true,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(transactions![index]['category']),
                        ]
                      ),
                      subtitle: Text(transactions![index]['desc'], style: TextStyle(fontSize: 12, color: Colors.grey),),
                      trailing: Text(transactions![index]['amount'].toString()+ ' USD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: transactions![index]['kind'] == 'Add' ? Colors.green : Colors.red),),
                    ),
                  );
                }
            ) : SizedBox(
              width: size.width,
              height: 120,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.amber,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
