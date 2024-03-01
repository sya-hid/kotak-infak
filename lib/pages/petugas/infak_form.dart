import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kotak_infak/pages/print_infak_page.dart';
import 'package:kotak_infak/models/category_model.dart';
import 'package:kotak_infak/models/donatur_model.dart';
import 'package:kotak_infak/models/transaksi_model.dart';
import 'package:kotak_infak/models/user_model.dart';
import 'package:kotak_infak/provider/auth_provider.dart';
import 'package:kotak_infak/provider/category_provider.dart';
import 'package:kotak_infak/provider/transaction_provider.dart';
import 'package:kotak_infak/widgets/custom_button.dart';
import 'package:kotak_infak/widgets/custom_textform_field.dart';
import 'package:provider/provider.dart';

class InfakForm extends StatefulWidget {
  // final String? idDonatur;
  final DonaturModel donaturModel;
  const InfakForm({
    super.key,
    required this.donaturModel,
    // this.idDonatur
  });

  @override
  State<InfakForm> createState() => _InfakFormState();
}

class _InfakFormState extends State<InfakForm> {
  String? currentCategory;
  String? currentDonatur;
  // String currentCategory = categories[0];
  final TextEditingController _olehController = TextEditingController();
  final TextEditingController _nominalController = TextEditingController();

  // final CollectionReference _infak =
  //     FirebaseFirestore.instance.collection('transaksi');
  final TextEditingController _namaDonaturController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  bool isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool cetakQrcode = true;

  // DateTime? _dateTimeId;
  // final _idController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // UserProvider userProvider = Provider.of<UserProvider>(context);
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    CategoryProvider categoryProvider = Provider.of<CategoryProvider>(context);
    UserModel user = authProvider.user;
    _namaDonaturController.text = widget.donaturModel.name!;
    _alamatController.text = widget.donaturModel.alamat!;
    _positionController.text =
        '${widget.donaturModel.geopoint!.latitude}, ${widget.donaturModel.geopoint!.longitude}';
    currentCategory = widget.donaturModel.category;
    resetForm() {
      _namaDonaturController.clear();
      _olehController.clear();
      _alamatController.clear();
      _alamatController.clear();
      currentCategory = null;
    }

    categoryProvider.allData();
    List<Map<String, dynamic>> categories = categoryProvider.categories;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Infak'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              // CustomTextFormField(
              //     controller: _idController,
              //     label: 'Tanggal Lahir',
              //     hintText: 'Masukkan Tanggal Lahir',
              //     readOnly: true,
              //     onTap: () {
              //       showDatePicker(
              //         context: context,
              //         initialDate: DateTime.now(),
              //         firstDate: DateTime(1980),
              //         lastDate: DateTime(2099),
              //       ).then((pickedDate) {
              //         if (pickedDate != null) {
              //           setState(() {
              //             _dateTimeId = pickedDate;
              //             String formattedDate =
              //                 DateFormat('EEEE, dd-MMM-yyyy', 'id_ID')
              //                     .format(pickedDate);
              //             // print(formattedDate);
              //             _idController.text = formattedDate;
              //           });
              //         }
              //       });
              //     },
              //     keyboardType: TextInputType.text),
//
              //
              CustomTextFormField(
                controller: _namaDonaturController,
                hintText: 'Masukkan Nama Donatur',
                label: 'Nama Donatur',
                keyboardType: TextInputType.name,
                prefixIcon: Icons.person,
                readOnly: true,
              ),
              const SizedBox(height: 10),
              CustomTextFormField(
                controller: _positionController,
                hintText: 'Masukkan Koordinat',
                label: 'Location',
                keyboardType: TextInputType.text,
                prefixIcon: Icons.location_on,
                readOnly: true,
              ),
              const SizedBox(height: 10),
              CustomTextFormField(
                controller: _alamatController,
                hintText: 'Masukkan Alamat',
                label: 'Alamat',
                maxLines: 3,
                readOnly: true,
                keyboardType: TextInputType.text,
                prefixIcon: Icons.location_city_rounded,
              ),
              const SizedBox(height: 10),
              categories.isNotEmpty
                  ? DropdownButtonFormField(
                      isExpanded: true,
                      value: currentCategory,
                      decoration: const InputDecoration(
                        hintText: 'Category',
                        floatingLabelAlignment: FloatingLabelAlignment.center,
                        isCollapsed: false,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        prefixIcon: Icon(Icons.menu_rounded),
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(categories.length, (index) {
                        final CategoryModel category =
                            categories[index]['data'];
                        return DropdownMenuItem(
                            value: category.category,
                            child: Text(category.category!));
                      }),
                      onChanged: null)
                  : const SizedBox.shrink(),
              const SizedBox(height: 10),
              CustomTextFormField(
                  controller: _nominalController,
                  label: 'Nominal',
                  hintText: 'Masukkan Total Uang ',
                  prefixIcon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              CustomTextFormField(
                controller: _olehController,
                label: 'Diserahkan Oleh',
                keyboardType: TextInputType.name,
                hintText: 'Masukkan Nama Yang Menyerahkan',
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    checkColor: Colors.white,
                    value: cetakQrcode,
                    onChanged: (value) {
                      setState(() {
                        cetakQrcode = value!;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  const Text('Cetak Qr Code')
                ],
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : CustomButton(
                      onTap: () async {
                        final Timestamp createdAt = Timestamp.now();

                        // final Timestamp now = Timestamp.now();
                        // final Timestamp createdAt = Timestamp.fromDate(DateTime(
                        //     _dateTimeId!.year,
                        //     _dateTimeId!.month,
                        //     _dateTimeId!.day,
                        //     now.toDate().hour,
                        //     now.toDate().minute,
                        //     now.toDate().second));

                        // final Timestamp createdAt = Timestamp.now();
                        var id = DateFormat('yyMMddHHmmss')
                            .format(createdAt.toDate());
                        // var id =
                        //     '${DateFormat('yyMMdd').format(createdAt.toDate())}${DateFormat('HHmmss').format(now.toDate())}';

                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          TransaksiModel transaksi = TransaksiModel(
                              idDonatur: widget.donaturModel.id,
                              createdAt: createdAt,
                              nominal: int.parse(_nominalController.text),
                              oleh: _olehController.text,
                              idPetugas: user.id,
                              id: id,
                              petugas: user,
                              donatur: widget.donaturModel);
                          await TransactionProvider().createData(id, transaksi);

                          if (cetakQrcode) {
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DetailInfak(transaksi: transaksi)));
                            }
                          } else {
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          }
                          resetForm();

                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      text: 'Simpan',
                      iconData: Icons.save,
                    )
            ],
          ),
        ),
      ),
    );
  }
}
