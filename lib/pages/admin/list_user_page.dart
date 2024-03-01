import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kotak_infak/consts.dart';
import 'package:kotak_infak/models/user_model.dart';
import 'package:kotak_infak/provider/user_provider.dart';
import 'package:kotak_infak/widgets/custom_button.dart';
import 'package:kotak_infak/widgets/custom_textform_field.dart';
import 'package:provider/provider.dart';

class ListUserPage extends StatefulWidget {
  const ListUserPage({super.key});

  @override
  State<ListUserPage> createState() => _ListUserPageState();
}

class _ListUserPageState extends State<ListUserPage> {
  List<UserModel> users = [];
  String? selectedLevel;
  List<String> levels = ['Admin', 'Petugas'];
  final _tanggalLahirController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime? _dateTime;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoadingSave = false;
  @override
  Widget build(BuildContext context) {
    UsersProvider usersProvider = Provider.of<UsersProvider>(context);
    usersProvider.allUser();
    List<UserModel> dataUser = usersProvider.users;
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: createOrUpdate,
          child: const Icon(Icons.add),
        ),
        body: RefreshIndicator(
          onRefresh: usersProvider.allUser,
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: dataUser.length,
            itemBuilder: (context, index) {
              UserModel data = dataUser[index];
              return Card(
                elevation: 2,
                child: ListTile(
                  title: Text(
                    data.name!,
                  ),
                  subtitle: Text(data.email!),
                  trailing: IconButton(
                      onPressed: () => createOrUpdate(user: data),
                      icon: const Icon(Icons.edit)),
                ),
              );
            },
          ),
        ));
  }

  Future createOrUpdate({UserModel? user}) async {
    String action = 'create';

    if (user != null) {
      action = 'update';
      _nameController.text = user.name!;
      _emailController.text = user.email!;
      _alamatController.text = user.alamat!;
      selectedLevel = user.level!;
      _noHpController.text = user.noHp!;
      _tanggalLahirController.text = DateFormat('EEEE, dd-MMM-yyyy', 'id_ID')
          .format(user.tanggalLahir!.toDate());
      _tempatLahirController.text = user.tempatLahir!;
      _passwordController.text = user.password!;
      _dateTime = user.tanggalLahir!.toDate();
    }
    showModalBottomSheet(
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
      constraints: BoxConstraints.tightFor(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.9),
      context: context,
      builder: (context) {
        UsersProvider userProvider = Provider.of<UsersProvider>(context);
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Form(
              key: _formKey,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.manual,
                padding: const EdgeInsets.all(10),
                children: [
                  CustomTextFormField(
                      controller: _nameController,
                      hintText: 'Masukkan Nama User',
                      keyboardType: TextInputType.name,
                      label: 'Nama'),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                      controller: _noHpController,
                      hintText: 'Masukkan No HP',
                      keyboardType: TextInputType.phone,
                      label: 'No. HP'),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                      readOnly: action == 'update' ? true : false,
                      controller: _emailController,
                      hintText: 'Masukkan Email',
                      keyboardType: TextInputType.emailAddress,
                      label: 'Email'),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                      controller: _tempatLahirController,
                      label: 'Tempat Lahir',
                      hintText: 'Masukkan Tempat Lahir',
                      keyboardType: TextInputType.name),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                      controller: _tanggalLahirController,
                      label: 'Tanggal Lahir',
                      hintText: 'Masukkan Tanggal Lahir',
                      helpText: action == 'create'
                          ? 'Akan Menjadi Default Password'
                          : null,
                      readOnly: true,
                      onTap: () {
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1980),
                          lastDate: DateTime(2099),
                        ).then((pickedDate) {
                          if (pickedDate != null) {
                            setState(() {
                              _dateTime = pickedDate;
                              String formattedDate =
                                  DateFormat('EEEE, dd-MMM-yyyy', 'id_ID')
                                      .format(pickedDate);
                              // print(formattedDate);
                              _tanggalLahirController.text = formattedDate;
                            });
                          }
                        });
                      },
                      keyboardType: TextInputType.text),
                  const SizedBox(height: 10),
                  action == 'update'
                      ? CustomTextFormField(
                          controller: _passwordController,
                          hintText: 'Masukkan Password',
                          keyboardType: TextInputType.visiblePassword,
                          label: 'Password')
                      : const SizedBox.shrink(),
                  action == 'update'
                      ? const SizedBox(height: 10)
                      : const SizedBox.shrink(),
                  CustomTextFormField(
                      controller: _alamatController,
                      label: 'Alamat',
                      hintText: 'Masukkan Alamat',
                      maxLines: 2,
                      keyboardType: TextInputType.name),
                  const SizedBox(height: 10),
                  DropdownButtonFormField(
                    isExpanded: true,
                    value: selectedLevel,
                    decoration: const InputDecoration(
                      hintText: 'Level',
                      floatingLabelAlignment: FloatingLabelAlignment.center,
                      isCollapsed: false,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(levels.length, (index) {
                      // final DocumentSnapshot categoey =
                      //     snapshot.data!.docs[index];
                      String level = levels[index];
                      return DropdownMenuItem(value: level, child: Text(level));
                    }),
                    onChanged: (value) {
                      setState(() {
                        selectedLevel = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  isLoadingSave
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              // final Timestamp now =
                              //     Timestamp.fromDate(_dateTimeId!);
                              final Timestamp now = Timestamp.now();
                              var id = DateFormat('yyMMddHHmmss')
                                  .format(now.toDate());
                              Response response;
                              setState(() {
                                isLoadingSave = true;
                              });
                              if (action == 'create') {
                                UserModel userModel = UserModel(
                                    id: id,
                                    name: _nameController.text,
                                    email: _emailController.text,
                                    password: DateFormat('yyyyMMdd')
                                        .format(_dateTime!),
                                    noHp: _noHpController.text,
                                    alamat: _alamatController.text,
                                    level: selectedLevel,
                                    tanggalLahir:
                                        Timestamp.fromDate(_dateTime!),
                                    tempatLahir: _tempatLahirController.text,
                                    createdAt: now,
                                    updatedAt: now);
                                response = await userProvider.addUser(
                                    id, userModel, _dateTime!);
                              } else {
                                UserModel userModel = UserModel(
                                    id: user!.id,
                                    name: _nameController.text,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    noHp: _noHpController.text,
                                    alamat: _alamatController.text,
                                    tanggalLahir:
                                        Timestamp.fromDate(_dateTime!),
                                    tempatLahir: _tempatLahirController.text,
                                    level: selectedLevel,
                                    createdAt: user.createdAt,
                                    updatedAt: now);
                                response = await userProvider.update(
                                    user.id!, userModel);
                              }
                              setState(() {
                                isLoadingSave = false;
                              });
                              if (context.mounted) {
                                Navigator.of(context).pop();

                                // String notification = action == 'update'
                                //     ? 'Data updated successfully!'
                                //     : 'Data saved successfully!';
                                var snackBar = SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(response.message!),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            }
                          },
                          text: action == 'update' ? 'Update' : 'Simpan',
                          iconData:
                              action == 'update' ? Icons.edit : Icons.save,
                        )
                ],
              )),
        );
      },
    ).then((value) {
      resetForm();
    });
  }

  resetForm() {
    _nameController.text = '';
    _tempatLahirController.text = '';
    _alamatController.text = '';
    _noHpController.text = '';
    _emailController.text = '';
    _tanggalLahirController.text = '';
    selectedLevel = null;
  }
}
