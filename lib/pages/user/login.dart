import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../inc/afooter.dart';
import 'dart:convert';

class Login extends ConsumerStatefulWidget {
  const Login({Key? key, required this.isLogged}) : super(key: key);

  final String isLogged;

  @override
  LoginState createState() => LoginState();
}

class LoginState extends ConsumerState<Login> {
  String token = '';
  @override
  void initState() {
    super.initState();
    final box = GetStorage();
    var token = box.read('token') ?? 'yk';
    if (token != 'yk') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        box.remove('token');
        Get.snackbar(
          'Logout',
          'Successfuly logged out.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        setState(() {
          token = 'yk';
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    bool isLoggingIn = false;
    Future<void> loginUser(BuildContext context) async {
      final String email = emailController.text.trim();
      final String password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        Get.snackbar(
          'Error',
          'Email and password cannot be empty',
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

      final Uri apiUrl = Uri.parse(GetStorage().read('bUrl') + 'user/login');
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

          Get.offAllNamed('/profile', arguments: data['token']);
          return;

          ///giriş yaptıktan sonra nereye gidecek?
        } else {
          ///başarısız giriş denemesinde ne yapılacak?
          //log('Response status: ${data['status'].toString()}');
          // Get.snackbar() yöntemini bir SnackBar Widget'ı içinde kullan
          Get.snackbar(
            'Error',
            'Login failed from Server. Please try again.',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          );
        }

        isLoggingIn = false;
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
                      hintText: 'example@gmail.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onSubmitted: (_) => isLoggingIn ? null : loginUser(context),
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
                    onSubmitted: (_) => isLoggingIn ? null : loginUser(context),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => isLoggingIn ? null : loginUser(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        isLoggingIn ? const Text('?') : const Text('Login'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text('Sign up'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgotten-password');
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Enaltkisim(
        selectedPage: '/profile',
        isLogged: token,
      ),
    );
  }
}
