import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kotak_infak/consts.dart';
import 'package:kotak_infak/models/instansi_model.dart';
import 'package:kotak_infak/provider/instansi_provider.dart';
import 'package:kotak_infak/provider/theme_provider.dart';
import 'package:kotak_infak/widgets/custom_button.dart';
import 'package:kotak_infak/widgets/custom_textform_field.dart';
import 'package:provider/provider.dart';

class InstansiPage extends StatefulWidget {
  final InstansiModel instansi;

  const InstansiPage({super.key, required this.instansi});

  @override
  State<InstansiPage> createState() => _InstansiPageState();
}

class _InstansiPageState extends State<InstansiPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final alamatController = TextEditingController();
  final emailController = TextEditingController();
  final noHpController = TextEditingController();
  bool isLoading = false;

  late File pictureFile = File('');
  String imageUrl = '';
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  final _focusName = FocusNode();
  final _focusEmail = FocusNode();
  final _focusNoHp = FocusNode();
  final _focusAlamat = FocusNode();
  @override
  void initState() {
    super.initState();
    nameController.text = widget.instansi.name!;
    alamatController.text = widget.instansi.alamat!;
    emailController.text = widget.instansi.email!;
    noHpController.text = widget.instansi.noHp!;
    imageUrl = widget.instansi.profileUrl!;
  }

  @override
  Widget build(BuildContext context) {
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);
    InstansiProvider instansiProvider = Provider.of<InstansiProvider>(context);
    InstansiModel instansi = instansiProvider.instansi;

    // nameController.text = instansi.name!;
    // alamatController.text = instansi.alamat!;
    // emailController.text = instansi.email!;
    // noHpController.text = instansi.noHp!;
    // imageUrl = instansi.profileUrl!;

    return Scaffold(
        body: GestureDetector(
      onTap: () {
        _focusAlamat.unfocus();
        _focusNoHp.unfocus();
        _focusEmail.unfocus();
        _focusName.unfocus();
      },
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(10),
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
                                        image: NetworkImage(imageUrl),
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
                                          image: AssetImage(
                                              'assets/IMG-20190830-WA0022.jpg'),
                                          fit: BoxFit.contain),
                                    ),
                                  ),
                      ),
                    ),
                    Positioned(
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
                controller: nameController,
                hintText: 'Masukkan Name',
                keyboardType: TextInputType.name,
                label: 'Name'),
            const SizedBox(height: 15),
            CustomTextFormField(
                maxLines: 2,
                focusNode: _focusAlamat,
                controller: alamatController,
                hintText: 'Masukkan Alamat',
                keyboardType: TextInputType.streetAddress,
                label: 'Alamat'),
            const SizedBox(height: 15),
            CustomTextFormField(
                focusNode: _focusEmail,
                controller: emailController,
                hintText: 'Masukkan Email',
                keyboardType: TextInputType.emailAddress,
                label: 'Email'),
            const SizedBox(height: 15),
            CustomTextFormField(
                focusNode: _focusNoHp,
                controller: noHpController,
                hintText: 'Masukkan No HP',
                keyboardType: TextInputType.number,
                label: 'No. Hp'),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
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
                            : profileUrl = await uploadFile();
                        InstansiModel newInstansi = InstansiModel(
                            id: instansi.id,
                            name: nameController.text,
                            alamat: alamatController.text,
                            email: emailController.text,
                            noHp: noHpController.text,
                            profileUrl: profileUrl,
                            createdAt: instansi.createdAt,
                            updatedAt: Timestamp.now());
                        response = await instansiProvider.updateIntansi(
                            instansi.id!, newInstansi);

                        setState(() {
                          isLoading = false;
                        });
                        var snackBar = SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(response.message!),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      }
                    },
                    text: 'Simpan')
          ],
        ),
      ),
    ));
  }

  selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future<String> uploadFile() async {
    final path = 'images/instansi/${pickedFile!.name}';

    final file = File(pickedFile!.path!);

    final firebaseStorageRef = FirebaseStorage.instance.ref().child(path);
    uploadTask = firebaseStorageRef.putFile(file);
    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    setState(() {
      imageUrl = urlDownload;
      // double progress = snapshot.bytesTransferred / snapshot.totalBytes;
    });
    return urlDownload;
  }
}
