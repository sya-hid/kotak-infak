import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kotak_infak/models/category_model.dart';
import 'package:kotak_infak/provider/category_provider.dart';
import 'package:kotak_infak/widgets/custom_button.dart';
import 'package:kotak_infak/widgets/custom_textform_field.dart';
import 'package:provider/provider.dart';

class ListKategoriPage extends StatefulWidget {
  const ListKategoriPage({super.key});

  @override
  State<ListKategoriPage> createState() => _ListKategoriPageState();
}

class _ListKategoriPageState extends State<ListKategoriPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();

  Future<void> createData() async {
    showModalBottomSheet(
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                CustomTextFormField(
                    controller: _categoryController,
                    hintText: 'Masukkan Nama Category',
                    keyboardType: TextInputType.name,
                    label: 'Category'),
                const SizedBox(height: 20),
                CustomButton(
                    iconData: Icons.save,
                    onTap: () {
                      final Timestamp createdAt = Timestamp.now();

                      var id =
                          DateFormat('yyMMddHHmmss').format(createdAt.toDate());
                      if (_formKey.currentState!.validate()) {
                        CategoryProvider().createData(
                            id,
                            CategoryModel(
                                createdAt: createdAt,
                                category: _categoryController.text));
                      }
                      Navigator.pop(context);
                      String notification = 'Data saved successfully!';
                      var snackBar = SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text(notification),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    text: 'Simpan')
              ],
            ),
          ),
        );
      },
    ).then((value) => _categoryController.text = '');
  }

  @override
  Widget build(BuildContext context) {
    CategoryProvider categoryProvider = Provider.of<CategoryProvider>(context);

    categoryProvider.allCategory();
    // List<Map<String, dynamic>> categories = categoryProvider.categories
    //     .sorted((a, b) => b['total_donasi'].compareTo(a['total_donasi']))
    //     .toList();
    List<CategoryModel> categories = categoryProvider.kategori
        .sorted((a, b) => b.createdAt!.compareTo(a.createdAt!));
    return Scaffold(
      body: RefreshIndicator(
          onRefresh: categoryProvider.allCategory,
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              CategoryModel data = categories[index];
              // CategoryModel data = categories[index]['data'];
              return Card(
                elevation: 2,
                child: ListTile(
                  title: Text(
                    data.category!,
                    maxLines: 1,
                  ),
                  // subtitle: Text(
                  //     "${currencyFormatter.format(categories[index]['total_donasi'])} (${categories[index]['total_donatur']} donatur)"),
                ),
              );
            },
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: createData,
        child: const Icon(Icons.add),
      ),
    );
  }
}
