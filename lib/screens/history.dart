// ignore_for_file: use_build_context_synchronously

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:financebook/models/transaction.dart';
import 'package:financebook/services/data_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key, required this.dataService}) : super(key: key);
  static const String routeName = '/history';
  final DataService dataService;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late List<Transaction> transactions = [];

  @override
  void initState() {
    super.initState();
    loadTransactions().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> loadTransactions() async {
    try {
      final loadedTransactions = await widget.dataService.getTransactions();
      setState(() {
        transactions = loadedTransactions;
      });
    } catch (e) {
      // Handle error loading transactions
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Riwayat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: transactions.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Opps!',
                      style: TextStyle(fontSize: 32, color: Colors.white),
                    ),
                    Text(
                      'Tidak ada riwayat transaksi',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];

                  final amount = NumberFormat.currency(
                    locale: 'id',
                    symbol: 'Rp. ',
                    decimalDigits: 0,
                  ).format(transaction.amount);

                  return TransactionItem(
                    id: transaction.id,
                    date: DateFormat('dd MMM yyyy').format(transaction.date),
                    amount: amount,
                    description: transaction.description,
                    isIncome: transaction.type == 'Income',
                    dataService: widget.dataService,
                    transactionObj: transaction,
                  );
                },
              ),
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final int id;
  final String date;
  final String amount;
  final String description;
  final bool isIncome;
  final DataService dataService;
  final Transaction transactionObj;

  const TransactionItem({
    Key? key,
    required this.id,
    required this.date,
    required this.amount,
    required this.description,
    required this.isIncome,
    required this.dataService,
    required this.transactionObj,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String selectedType = transactionObj.type;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
          child: ListTile(
          title: Text(amount, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(description),
          trailing: Text(date),
          leading: CircleAvatar(
            backgroundColor: isIncome ? Colors.green : Colors.red,
            child: Icon(
              isIncome ? Icons.arrow_upward : Icons.arrow_downward,
              color: Colors.white,
            ),
          ),
        ),
      ),
      
    );
  }

}
