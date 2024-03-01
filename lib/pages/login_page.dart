import 'package:flutter/material.dart';
import 'package:kotak_infak/consts.dart';
import 'package:kotak_infak/pages/admin/main_page.dart';
import 'package:kotak_infak/pages/petugas/main_page.dart';
import 'package:kotak_infak/models/user_model.dart';
import 'package:kotak_infak/provider/auth_provider.dart';
import 'package:kotak_infak/provider/instansi_provider.dart';
import 'package:kotak_infak/widgets/custom_button.dart';
import 'package:kotak_infak/widgets/custom_textform_field.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();
  bool seePassword = false;
  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    InstansiProvider instansiProvider = Provider.of<InstansiProvider>(context);
    instansiProvider.getData();
    // _emailController.text = 'satomiwako@mail.com';
    // _passwordController.text = '19950223';
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          _focusEmail.unfocus();
          _focusPassword.unfocus();
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Login',
                style: TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 50),
              CustomTextFormField(
                  focusNode: _focusEmail,
                  controller: _emailController,
                  hintText: 'Masukkan Email',
                  keyboardType: TextInputType.emailAddress,
                  label: 'Email'),
              const SizedBox(height: 15),
              CustomTextFormField(
                  focusNode: _focusPassword,
                  controller: _passwordController,
                  hintText: 'Masukkan Password',
                  keyboardType: seePassword
                      ? TextInputType.text
                      : TextInputType.visiblePassword,
                  label: 'Password'),
              const SizedBox(height: 15),
              Row(
                children: [
                  Checkbox(
                    checkColor: Colors.white,
                    value: seePassword,
                    onChanged: (value) {
                      setState(() {
                        seePassword = value!;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  const Text('See Password')
                ],
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      onTap: () async {
                        _focusEmail.unfocus();
                        _focusPassword.unfocus();
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          Response response = await authProvider.login(
                              email: _emailController.text,
                              password: _passwordController.text);
                          if (response.data != null) {
                            UserModel userModel = response.data;
                            if (context.mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      userModel.level == 'Admin'
                                          ? const MainPageAdmin()
                                          : const MainPagePetugas(),
                                ),
                              );
                            }
                          } else {
                            final SnackBar snackBar = SnackBar(
                              elevation: 2,
                              content: Text(response.message!),
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          }

                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      text: 'Login')
            ],
          ),
        ),
      ),
    );
  }
}
