import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kotak_infak/consts.dart';
import 'package:kotak_infak/models/user_model.dart';
import 'package:kotak_infak/provider/auth_provider.dart';
import 'package:kotak_infak/provider/theme_provider.dart';
import 'package:kotak_infak/widgets/custom_button.dart';
import 'package:kotak_infak/widgets/custom_textform_field.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';

class ProfilePagePetugas extends StatefulWidget {
  final UserModel user;
  // static const String route = 'Profile Page';
  const ProfilePagePetugas({super.key, required this.user});

  @override
  State<ProfilePagePetugas> createState() => _ProfilePagePetugasState();
}

class _ProfilePagePetugasState extends State<ProfilePagePetugas> {
  final _tanggalLahirController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime? _dateTime;
  String selectedLevel = '';
  bool isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late File pictureFile = File('');
  String imageUrl = '';
  final _focusName = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();
  final _focusNoHp = FocusNode();
  final _focusAlamat = FocusNode();
  final _focusTempatLahir = FocusNode();
  final _focusTanggalLahir = FocusNode();
  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name!;
    _emailController.text = widget.user.email!;
    _noHpController.text = widget.user.noHp!;
    _alamatController.text = widget.user.alamat!;
    _tempatLahirController.text = widget.user.tempatLahir!;
    _passwordController.text = widget.user.password!;
    _dateTime = widget.user.tanggalLahir!.toDate();
    _tanggalLahirController.text =
        DateFormat('dd-MMM-yyyy', 'id_ID').format(_dateTime!);
    selectedLevel = widget.user.level!;
    imageUrl = widget.user.profileUrl!;
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel currentUser = widget.user;
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
        appBar: widget.user.level == 'Petugas'
            ? AppBar(
                title: const Text('Profile'),
              )
            : null,
        // drawer: buildDrawer(context, ProfilePagePetugas.route),
        body: GestureDetector(
          onTap: () {
            _focusName.unfocus();
            _focusEmail.unfocus();
            _focusPassword.unfocus();
            _focusAlamat.unfocus();
            _focusNoHp.unfocus();
            _focusTanggalLahir.unfocus();
            _focusTempatLahir.unfocus();
          },
          child: Form(
            key: _formKey,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      fit: StackFit.passthrough,
                      alignment: Alignment.bottomRight,
                      children: [
                        DottedBorder(
                          borderType: BorderType.Circle,
                          padding: const EdgeInsets.all(10),
                          dashPattern: const [5, 10],
                          strokeWidth: 2,
                          strokeCap: StrokeCap.round,
                          color: themeNotifier.getThemeMode() == ThemeMode.dark
                              ? Colors.white70
                              : Colors.black87,
                          child: Center(
                            child: pickedFile != null
                                ? Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: FileImage(
                                          File(pickedFile!.path!),
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : imageUrl != ''
                                    ? Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: CachedNetworkImageProvider(
                                                imageUrl),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: 100,
                                        height: 100,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: CachedNetworkImageProvider(
                                                  'https://i.imgur.com/sUFH1Aq.png'),
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                          ),
                        ),
                        Positioned(
                          // bottom: 5,
                          // right: 5,
                          child: Card(
                            elevation: 2,
                            shape: const CircleBorder(),
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: () {
                                selectFile();
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                    focusNode: _focusName,
                    controller: _nameController,
                    hintText: 'Masukkan Nama',
                    keyboardType: TextInputType.name,
                    label: 'Nama'),
                const SizedBox(height: 10),
                CustomTextFormField(
                    focusNode: _focusEmail,
                    readOnly: true,
                    controller: _emailController,
                    hintText: 'Masukkan Email',
                    keyboardType: TextInputType.emailAddress,
                    label: 'Email'),
                const SizedBox(height: 10),
                CustomTextFormField(
                    focusNode: _focusNoHp,
                    controller: _noHpController,
                    hintText: 'Masukkan No HP',
                    keyboardType: TextInputType.phone,
                    label: 'No. HP'),
                const SizedBox(height: 10),
                CustomTextFormField(
                    focusNode: _focusAlamat,
                    controller: _alamatController,
                    hintText: 'Masukkan Alamat',
                    keyboardType: TextInputType.streetAddress,
                    label: 'Alamat'),
                const SizedBox(height: 10),
                CustomTextFormField(
                    focusNode: _focusTempatLahir,
                    controller: _tempatLahirController,
                    hintText: 'Masukkan Tempat Lahir',
                    keyboardType: TextInputType.text,
                    label: 'Tempat Lahir'),
                const SizedBox(height: 10),
                CustomTextFormField(
                    focusNode: _focusTanggalLahir,
                    controller: _tanggalLahirController,
                    label: 'Tanggal Lahir',
                    hintText: 'Masukkan Tanggal Lahir',
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
                                DateFormat('dd-MMM-yyyy').format(pickedDate);
                            // print(formattedDate);
                            _tanggalLahirController.text = formattedDate;
                          });
                        }
                      });
                    },
                    keyboardType: TextInputType.text),
                const SizedBox(height: 10),
                CustomTextFormField(
                    focusNode: _focusPassword,
                    controller: _passwordController,
                    hintText: 'Masukkan Password',
                    keyboardType: TextInputType.visiblePassword,
                    label: 'Password'),
                const SizedBox(height: 15 + 5),
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : CustomButton(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            Response response;
                            String profileUrl = '';

                            pickedFile == null
                                ? profileUrl = imageUrl
                                : profileUrl =
                                    await uploadFile(currentUser.id!);
                            UserModel userModel = UserModel(
                                id: currentUser.id,
                                name: _nameController.text,
                                email: _emailController.text,
                                password: _passwordController.text,
                                noHp: _noHpController.text,
                                alamat: _alamatController.text,
                                tanggalLahir: Timestamp.fromDate(_dateTime!),
                                tempatLahir: _tempatLahirController.text,
                                level: selectedLevel,
                                createdAt: currentUser.createdAt,
                                updatedAt: Timestamp.now(),
                                profileUrl: profileUrl);
                            response = await authProvider.updateProfile(
                                newData: userModel);
                            // authProvider.user = response.data;

                            setState(() {
                              isLoading = false;
                            });
                            // String notification = 'Data updated successfully!';
                            var snackBar = SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text(response.message!),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                              if (authProvider.user.level != 'Admin') {
                                Navigator.of(context).pop();
                              }
                            }
                          }
                        },
                        iconData: Icons.save,
                        text: 'Simpan')
              ],
            ),
          ),
        ));
  }

  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future<String> uploadFile(String idUser) async {
    final path = 'images/$idUser';

    final file = File(pickedFile!.path!);

    final firebaseStorageRef = FirebaseStorage.instance.ref().child(path);
    uploadTask = firebaseStorageRef.putFile(
        file, SettableMetadata(contentType: 'image/jpeg'));
    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    setState(() {
      imageUrl = urlDownload;
      // double progress = snapshot.bytesTransferred / snapshot.totalBytes;
    });
    return urlDownload;
  }
}

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality);
