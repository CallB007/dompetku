import 'package:dompetku/models/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool isExpense = true;
  int type = 2;
  final AppDatabase database = AppDatabase();
  TextEditingController categoryNameController = TextEditingController();

  //Logic CRUD Database
  Future insert(String name, int type) async {
    DateTime now = DateTime.now();
    final row = await database.into(database.categories).insertReturning(
        CategoriesCompanion.insert(
            name: name, type: type, createdAt: now, updatedAt: now));
    print('Masuk :' + row.toString());
  }

  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
  }

  Future update(int categoryId, String newName) async {
    return await database.updateCategoryRepo(categoryId, newName);
  }

  // Fungsi Penambahan Data Transaksi
  void openDialog(Category? category) {
    if (category != null) {
      categoryNameController.text = category.name;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    (isExpense) ? "Pengeluaran" : "Pemasukan",
                    style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: (isExpense) ? Colors.red : Colors.green)),
                  ),
                  SizedBox(height: 18),
                  TextFormField(
                    controller: categoryNameController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Jenis Pemasukan"),
                  ),
                  SizedBox(height: 16),

                  //Tombol Simpan atau Save
                  ElevatedButton(
                    onPressed: () {
                      if (category == null) {
                        insert(categoryNameController.text, isExpense ? 2 : 1);
                      } else {
                        update(
                            category.id,
                            categoryNameController
                                .text); // Update existing data
                      }
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      setState(() {});
                      categoryNameController.clear();
                    },
                    child: Text("SIMPAN"),
                  )
                ],
              ),
            ),
          );
        });
  }

  //Switch mengubah dari Pengeluaran ke Pemasukan
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Switch(
                value: isExpense,
                onChanged: (bool value) {
                  setState(() {
                    isExpense = value;
                    type = value ? 2 : 1;
                  });
                },
                inactiveTrackColor: Colors.green[200],
                inactiveThumbColor: Colors.green,
                activeColor: Colors.red,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  isExpense ? "Pengeluaran" : "Pemasukan",
                  style: GoogleFonts.montserrat(
                      textStyle:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              IconButton(
                  onPressed: () {
                    openDialog(null);
                  },
                  icon: Icon(CupertinoIcons.add_circled_solid, size: 32))
            ],
          ),
        ),

        //Logic Penambahan Data
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
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Card(
                              elevation: 10,
                              child: ListTile(
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,

                                  //Icon Delete dan Edit
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        database.deleteCategoryRepo(
                                            snapshot.data![index].id);
                                        setState(() {});
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        openDialog(snapshot.data![index]);
                                      },
                                    ),
                                  ],
                                ),
                                title: Text(
                                  snapshot.data![index].name,
                                  style: GoogleFonts.montserrat(
                                    textStyle:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                leading: Container(
                                  child: (isExpense)
                                      ? Icon(
                                          CupertinoIcons
                                              .arrow_up_right_circle_fill,
                                          color: Colors.red,
                                          size: 35)
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
                      child: Text("Tidak ada Data"),
                    );
                  }
                } else {
                  return Center(
                    child: Text("Tidak ada Data"),
                  );
                }
              }
            }),
      ],
    ));
  }
}
