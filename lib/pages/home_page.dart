import 'package:dompetku/models/database.dart';
import 'package:dompetku/models/transaction_with_category.dart';
import 'package:dompetku/pages/transaction_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDatabase database = AppDatabase();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///Dashboard Transaksi Total
            Padding(
              padding: const EdgeInsets.all(18),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ///Pemasukan
                    ///Ini Box untuk konten Pemasukan
                    Row(
                      children: [
                        Container(
                          child: Icon(
                            CupertinoIcons.arrow_down_right_circle_fill,
                            color: Colors.green,
                            size: 35,
                          ),
                          decoration: BoxDecoration(),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pemasukan",
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Rp. 3.000.000",
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),

                    ///Pengeluaran
                    ///Ini Box untuk konten pengeluaran
                    Row(
                      children: [
                        Container(
                          child: Icon(
                            CupertinoIcons.arrow_up_right_circle_fill,
                            color: Colors.red,
                            size: 35,
                          ),
                          decoration: BoxDecoration(),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pengeluaran",
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Rp. 1.600.000",
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),

            ///Judul Riwayat Tranksaksi
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                "Riwayat Tranksaksi",
                style: GoogleFonts.montserrat(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),

            //Logic untuk menampilkan Riwayat Transaksi dengan mempass data dari database
            StreamBuilder<List<TransactionWithCategory>>(
                stream: database.getTransactionByDateRepo(widget.selectedDate),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapshot.hasData) {
                      if (snapshot.data!.length > 0) {
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                child: Card(
                                  elevation: 10,
                                  child: ListTile(
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () async {
                                            await database
                                                .deleteTransactionRepo(snapshot
                                                    .data![index]
                                                    .transaction
                                                    .id);
                                            setState(() {});
                                          },
                                        ),
                                        SizedBox(width: 12),
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        TransactionPage(
                                                          transactionWithCategory:
                                                              snapshot
                                                                  .data![index],
                                                        )));
                                          },
                                        ),
                                      ],
                                    ),
                                    title: Text(
                                      "Rp. " +
                                          snapshot
                                              .data![index].transaction.amount
                                              .toString(),
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    subtitle: Text(
                                      snapshot.data![index].category.name +
                                          " - " +
                                          snapshot.data![index].transaction
                                              .description,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    leading: Container(
                                      child: (snapshot
                                                  .data![index].category.type ==
                                              2)
                                          ? Icon(
                                              CupertinoIcons
                                                  .arrow_up_right_circle_fill,
                                              color: Colors.red,
                                              size: 35,
                                            )
                                          : Icon(
                                              CupertinoIcons
                                                  .arrow_down_right_circle_fill,
                                              color: Colors.green,
                                              size: 35,
                                            ),
                                      decoration: BoxDecoration(),
                                    ),
                                  ),
                                ),
                              );
                            });
                      } else {
                        return Center(
                            child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text("Tidak ada Transaksi"),
                        ));
                      }
                    } else {
                      return Center(child: Text("Tidak ada Data"));
                    }
                  }
                }),
          ],
        ),
      ),
    );
  }
}
