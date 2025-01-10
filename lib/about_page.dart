import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Budget Tracker',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Introduction',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Wally is a Flutter application designed to help users manage their budgets and track their transactions. It allows users to add, view, and delete budgets and transactions, providing a clear overview of their financial status.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Features',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              '- Add Budgets: Users can create new budgets with a specified amount.\n'
              '- View Budgets: Users can view a list of all their budgets, including the total amount and the amount spent.\n'
              '- Add Transactions: Users can add transactions to a specific budget, specifying the amount, category, and description.\n'
              '- View Transactions: Users can view a list of all transactions, grouped by month.\n'
              '- Delete Budgets and Transactions: Users can delete budgets and transactions, with the application automatically updating the totals.\n'
              '- Dark Mode: Users can switch between light and dark modes.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Setup Instructions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              '1. Clone the repository:\n'
              '```sh\n'
              'git clone https://github.com/yourusername/budget-tracker.git\n'
              'cd budget-tracker\n'
              '```\n'
              '2. Install dependencies:\n'
              '```sh\n'
              'flutter pub get\n'
              '```\n'
              '3. Run the application:\n'
              '```sh\n'
              'flutter run\n'
              '```',
            ),
            const SizedBox(height: 16),
            const Text(
              'Usage',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              '- Home Page: Displays the total income and total spent, along with a list of budgets and transactions.\n'
              '- Add Budget: Click the add button on the "My Budgets" section to create a new budget.\n'
              '- Add Transaction: Click the floating action button to add a new transaction.\n'
              '- Delete Budget/Transaction: Swipe left on a budget or transaction to delete it.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Code Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              '- `homepage.dart`: Contains the main interface for viewing and managing budgets and transactions.\n'
              '- `transactions_page.dart`: Contains the interface for viewing and managing transactions for a specific budget.\n'
              '- `settings_page.dart`: Contains the settings interface, including the dark mode toggle.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Acknowledgments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              '- Supabase: Used for backend database management.\n'
              '- Flutter: Used for building the cross-platform mobile application.\n'
              '- Intl: Used for date formatting.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Conclusion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'This project demonstrates the use of Flutter for building a budget tracking application with features such as adding, viewing, and deleting budgets and transactions. It also includes a dark mode feature for better user experience. and it was deeveloped by makur elijah',
            ),
          ],
        ),
      ),
    );
  }
}
