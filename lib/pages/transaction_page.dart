// ignore_for_file: unused_import, unused_local_variable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:dompetku/models/database.dart';
import 'package:dompetku/models/transaction.dart';
import 'package:dompetku/models/transaction_with_category.dart';

class TransactionPage extends StatefulWidget {
  final TransactionWithCategory? transactionWithCategory;
  const TransactionPage({Key? key, required this.transactionWithCategory})
      : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final AppDatabase database = AppDatabase();
  late int type;
  bool isExpense = true;
  List<String> list = ['Makan', 'Transportasi', 'Nonton '];
  late String dropDownValue = list.first;
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController descController = TextEditingController();
  Category? selectedCategory;

  Future insert(
      String description, int categoryId, int amount, DateTime date) async {
    DateTime now = DateTime.now();
    final row = await database.into(database.transactions).insertReturning(
        TransactionsCompanion.insert(
            description: description,
            category_id: categoryId,
            amount: amount,
            transaction_date: date,
            created_at: now,
            updated_at: now));
  }

  Future update(int transactionId, int amount, int categoryId,
      DateTime transactionDate, String descdetail) async {
    return await database.updateTransactionRepo(
        transactionId, amount, categoryId, transactionDate, descdetail);
  }

  @override
  void initState() {
    if (widget.transactionWithCategory != null) {
      updateTransactionView(widget.transactionWithCategory!);
    } else {
      type = 2;
    }
    super.initState();
  }

  void updateTransactionView(TransactionWithCategory transactionWithCategory) {
    amountController.text =
        transactionWithCategory.transaction.amount.toString();
    descController.text = transactionWithCategory.transaction.description;
    dateController.text = DateFormat('yyyy-MM-dd')
        .format(transactionWithCategory.transaction.transaction_date);
    type = transactionWithCategory.category.type;
    (type == 2) ? isExpense = true : isExpense = false;
    selectedCategory = transactionWithCategory.category;
  }

  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Tambah Transaksi",
        style: GoogleFonts.montserrat(
            textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      )),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Switch(
                      value: isExpense,
                      onChanged: (bool value) {
                        setState(() {
                          isExpense = value;
                          type = (isExpense) ? 2 : 1;
                          selectedCategory = null;
                        });
                      },
                      inactiveTrackColor: Colors.green[200],
                      inactiveThumbColor: Colors.green,
                      activeColor: Colors.red,
                    ),

                    //Switch Pemasukan dan Pengeluaran
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        isExpense ? "Pengeluaran" : "Pemasukan",
                        style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),

              //Inputan Jumlah
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      label: Text("Jumlah", style: GoogleFonts.montserrat())),
                ),
              ),
              SizedBox(height: 30),

              //Kategori
              ///Judul Kategori
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Kategori",
                  style: GoogleFonts.montserrat(
                      textStyle:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(height: 10),

              ///Pilihan Kategori
              FutureBuilder<List<Category>>(
                  future: getAllCategory(type),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      if (snapshot.hasData) {
                        if (snapshot.data!.length > 0) {
                          selectedCategory = (selectedCategory == null)
                              ? snapshot.data!.first
                              : selectedCategory;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: DropdownButton<Category>(
                                value: (selectedCategory == null)
                                    ? snapshot.data!.first
                                    : selectedCategory,
                                isExpanded: true,
                                items: snapshot.data!.map((Category item) {
                                  return DropdownMenuItem<Category>(
                                    value: item,
                                    child: Text(item.name),
                                  );
                                }).toList(),
                                onChanged: (Category? value) {
                                  setState(() {
                                    selectedCategory = value;
                                  });
                                }),
                          );
                        } else {
                          return Center(
                            child: Text("Data Kosong"),
                          );
                        }
                      } else {
                        return Center(
                          child: Text("Tidak ada Data"),
                        );
                      }
                    }
                  }),
              SizedBox(height: 10),

              //Pilih Tanggal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextFormField(
                  readOnly: true,
                  controller: dateController,
                  decoration: InputDecoration(
                    label:
                        Text("Pilih Tanggal", style: GoogleFonts.montserrat()),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2021),
                        lastDate: DateTime(2099));

                    if (pickedDate != null) {
                      print(pickedDate);
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                      print(formattedDate);

                      setState(() {
                        dateController.text = formattedDate;
                      });
                    } else {
                      print("Date is not selected");
                    }
                  },
                ),
              ),
              SizedBox(height: 30),

              //Detail
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextFormField(
                  controller: descController,
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      label: Text("Detail", style: GoogleFonts.montserrat())),
                ),
              ),
              SizedBox(height: 30),

              //Tombol Simpan
              // plus fungsi Create (Insert)
              Center(
                  child: ElevatedButton(
                      onPressed: () async {
                        if (widget.transactionWithCategory == null)
                          await insert(
                            descController.text, // description (String)
                            selectedCategory!.id, // categoryId (int)
                            int.parse(amountController.text), // amount (int)
                            DateTime.parse(dateController.text),
                          );
                        else {
                          await update(
                              widget.transactionWithCategory!.transaction.id,
                              int.parse(amountController.text),
                              selectedCategory!.id,
                              DateTime.parse(dateController.text),
                              descController.text);
                        }
                        setState(() {});
                        Navigator.pop(context, true);
                      },
                      child: Text("SIMPAN"))),
            ],
          ),
        ),
      ),
    );
  }
}
