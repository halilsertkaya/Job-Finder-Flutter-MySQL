import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ChangePassword extends ConsumerStatefulWidget {
  const ChangePassword({Key? key, required this.isLogged}) : super(key: key);
  final String isLogged;

  @override
  ChangeState createState() => ChangeState();
}

class ChangeState extends ConsumerState<ChangePassword> {
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
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController password2Controller = TextEditingController();

    Future<void> checkuser(BuildContext context) async {
      final String password = passwordController.text.trim();
      final String password2 = password2Controller.text.trim();
      final String email = Get.parameters['email']!;
      final String code = Get.parameters['code']!;

      if (password2.isEmpty || password.isEmpty) {
        Get.snackbar(
          'Error',
          'Please type your new password.',
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

      final Uri apiUrl =
          Uri.parse(GetStorage().read('bUrl') + 'user/resetconfirm');
      final Map<String, String> headers = {'Content-Type': 'application/json'};
      final Map<String, dynamic> body = {
        'password': md5.convert(utf8.encode(password)).toString(),
        'code': code,
        'email': email,
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
            'Something went wrong. Please try again.',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          );
          //log('Register status: ${data['status'].toString()}');
          // Get.snackbar() yöntemini bir SnackBar Widget'ı içinde kullan
        }
      }
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
                  Text(
                    'Current Mail Address: ${Get.parameters['email']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Please type your new password:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
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
                      labelText: 'New Password',
                    ),
                    onSubmitted: (_) => checkuser(context),
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
                      labelText: 'New Password Again',
                    ),
                    onSubmitted: (_) => checkuser(context),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => checkuser(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: const [
                        Text('Set New Password'),
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
    );
  }
}
