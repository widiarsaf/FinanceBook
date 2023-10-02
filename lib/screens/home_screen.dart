

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:financebook/models/transaction.dart';
import 'package:financebook/screens/login_screen.dart';
import 'package:financebook/services/authentication_service.dart';
import 'package:financebook/services/data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
    required this.authService,
    required this.dataService,
  }) : super(key: key);

  static const String routeName = '/home';
  final AuthenticationService authService;
  final DataService dataService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Transaction>> transactions = Future.value([]);

  @override
  void initState() {
    super.initState();
    transactions = widget.dataService.getTransactions().whenComplete(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Book'),
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: EdgeInsets.only(
                right: 16.0), // Atur margin kanan sesuai kebutuhan
            child: TextButton(
              onPressed: () async {
                await widget.authService.logout();
                Navigator.pushReplacementNamed(context, LoginScreen.routeName);
              },
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              FutureBuilder<List<Transaction>>(
                future: transactions,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error,
                              size: 100,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Kesalahan memuat transaksi',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20),
                            Text(
                              'Opss!',
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Kamu tidak punya riwayat transaksi',
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    final transactionData = snapshot.data!;
                    return Column(
                      children: [
                        _summaryContainer(transactionData),
                      ],
                    );
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 35, 35, 35),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/chart.png',
                    width: 500,
                    height: 300,
                  ),
                ),
              ),

              _gridMenuContainer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryContainer(List<Transaction> transactions) {
    double totalIncome = 0.0;
    double totalExpense = 0.0;
    double totalBalance = 0.0;

    for (final transaction in transactions) {
      if (transaction.type == 'Income') {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }

    totalBalance = totalIncome - totalExpense;

    String totalIncomeString = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp. ',
      decimalDigits: 0,
    ).format(totalIncome);
    String totalExpenseString = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp. ',
      decimalDigits: 0,
    ).format(totalExpense);
    String totalBalanceString = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp. ',
      decimalDigits: 0,
    ).format(totalBalance);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 35, 35, 35),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Riwayat Transaksi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Column(children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Total Uang Saat Ini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      totalBalanceString,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange
                      ),
                    ),
                  ],
                ),
              ]),
              Divider(
                height: 40, // Tinggi garis horizontal
                color:
                    Color.fromARGB(255, 75, 75, 75), // Warna garis horizontal
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Total Pemasukan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                                
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            totalIncomeString,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Total Pengeluaran',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            totalExpenseString,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gridMenuContainer() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 35, 35, 35),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _gridMenuItem(
                    icon: Icons.add,
                    label: 'Pemasukan',
                    color: Colors.green,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/add_transaction',
                      arguments: 'Income',
                    ),
                  ),
                  SizedBox(width: 5),
                  _gridMenuItem(
                    icon: Icons.remove,
                    label: 'Pengeluaran',
                    color: Colors.pink,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/add_transaction',
                      arguments: 'Expense',
                    ),
                  ),
                ],
              ),
              Divider(
                height: 40, // Tinggi garis horizontal
                color:
                    Color.fromARGB(255, 75, 75, 75), // Warna garis horizontal
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _gridMenuItem(
                    icon: Icons.history,
                    label: 'Riwayat',
                    color: Colors.blue,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/history',
                    ),
                  ),
                  SizedBox(width: 5),
                  _gridMenuItem(
                    icon: Icons.settings,
                    label: 'Pengaturan',
                    color: Colors.orange,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/settings',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gridMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 148, // Lebar kotak ikon
            height: 64, // Tinggi kotak ikon
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.rectangle, // Bentuk kotak
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
