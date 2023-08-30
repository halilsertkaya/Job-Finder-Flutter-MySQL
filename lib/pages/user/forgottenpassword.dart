import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../inc/afooter.dart';

class ForgottenPassword extends ConsumerStatefulWidget {
  const ForgottenPassword({Key? key, required this.isLogged}) : super(key: key);

  final String isLogged;
  @override
  ForgottenPasswordState createState() => ForgottenPasswordState();
}

class ForgottenPasswordState extends ConsumerState<ForgottenPassword> {
  bool _isSubmitted = false;
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
    return Scaffold(
      body: _isSubmitted ? _successMessage() : _loginform(),
      bottomNavigationBar:
          Enaltkisim(selectedPage: '/profile', isLogged: widget.isLogged),
    );
  }

  Widget _loginform() {
    final TextEditingController emailController = TextEditingController();
    Future<void> forgottenPasswordUser(BuildContext context) async {
      final String email = emailController.text.trim();

      if (!GetUtils.isEmail(email)) {
        Get.snackbar(
          'Error',
          'Please enter a valid email address',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // göstergeleri göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      final Uri apiUrl =
          Uri.parse(GetStorage().read('bUrl') + 'user/forgottenpassword');
      final Map<String, String> headers = {'Content-Type': 'application/json'};
      final Map<String, dynamic> body = {'email': email};
      final http.Response response = await http.post(
        apiUrl,
        headers: headers,
        body: json.encode(body),
      );

      // göstergeleri kaldır
      Navigator.pop(context);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            response.body.isNotEmpty ? jsonDecode(response.body) : {};
        if (data['status'] == true) {
          //await GetStorage().write('token', data['message']);
          setState(() {
            _isSubmitted = true;
          });

          ///giriş yaptıktan sonra nereye gidecek?
        } else {
          ///başarısız giriş denemesinde ne yapılacak?
          Get.snackbar(
            'Error',
            'Email Address Not Found. Please try again.',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          );
        }
      }
    }

    return SingleChildScrollView(
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
                  onSubmitted: (_) => forgottenPasswordUser(context),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => forgottenPasswordUser(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: const [
                      Text('Send Reset Request'),
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
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _successMessage() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          const Text(
            'Success',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Password reset link has been send to your mail address. Please check your inbox.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
