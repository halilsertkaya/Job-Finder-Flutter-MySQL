import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../inc/afooter.dart';

class Signup extends ConsumerStatefulWidget {
  const Signup({Key? key, required this.isLogged}) : super(key: key);

  final String isLogged;

  @override
  SignupState createState() => SignupState();
}

class SignupState extends ConsumerState<Signup> {
  @override
  void initState() {
    super.initState();
    if (GetStorage().read('token') != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/profile');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController password2Controller = TextEditingController();
    bool isLoggingIn = false;

    Future<void> signupuser(BuildContext context) async {
      final String email = emailController.text.trim();
      final String password = passwordController.text.trim();
      final String password2 = password2Controller.text.trim();

      if (email.isEmpty || password2.isEmpty || password.isEmpty) {
        Get.snackbar(
          'Error',
          'Please fill all fields.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      if (password2 != password) {
        Get.snackbar(
          'Error',
          'Password repeat is not equal.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      if (!GetUtils.isEmail(email)) {
        Get.snackbar(
          'Error',
          'Please enter a valid email address',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        return;
      }
      isLoggingIn = true;
      final Uri apiUrl = Uri.parse(GetStorage().read('bUrl') + 'user/signup');
      final Map<String, String> headers = {'Content-Type': 'application/json'};
      final Map<String, dynamic> body = {
        'email': email,
        'password': md5.convert(utf8.encode(password)).toString(),
      };
      final http.Response response = await http.post(
        apiUrl,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            response.body.isNotEmpty ? jsonDecode(response.body) : {};
        if (data.containsKey('token')) {
          await GetStorage().write('token', data['token']);
          //log(data['status'] as String);
          Get.offAllNamed('/profile');
          return;

          ///
          ///giriş yaptıktan sonra nereye gidecek?
        } else {
          ///başarısız giriş denemesinde ne yapılacak?
          ///
          Get.snackbar(
            'Error',
            'Signup failed from Server. Please try again.',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          );
          //log('Register status: ${data['status'].toString()}');
          // Get.snackbar() yöntemini bir SnackBar Widget'ı içinde kullan
        }
      }

      isLoggingIn = false;
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 3,
              color: Colors.white10,
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                  height: 100,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      labelText: 'Email',
                      hintText: 'example@example.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onSubmitted: (_) =>
                        isLoggingIn ? null : signupuser(context),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      labelText: 'Password',
                    ),
                    onSubmitted: (_) =>
                        isLoggingIn ? null : signupuser(context),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: password2Controller,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      labelText: 'Password',
                    ),
                    onSubmitted: (_) =>
                        isLoggingIn ? null : signupuser(context),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => isLoggingIn ? null : signupuser(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        isLoggingIn ? const Text('?') : const Text('Signup'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text('<- Login'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          Enaltkisim(selectedPage: '/profile', isLogged: widget.isLogged),
    );
  }
}
