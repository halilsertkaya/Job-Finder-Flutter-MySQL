import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'pages/user/changepassword.dart';
import 'pages/user/profile.dart';
import 'pages/discover/discover.dart';
import 'pages/jobs/details.dart';
import 'pages/user/forgottenpassword.dart';
import 'pages/user/profile/changeavatar.dart';
import 'pages/user/signup.dart';
import 'pages/user/logout.dart';
import 'pages/apply/apply.dart';
import 'pages/user/home.dart';
import 'pages/user/login.dart';
import 'pages/search.dart';

void main() async {
  usePathUrlStrategy();
  await GetStorage.init();

  final box = GetStorage();
  final token = box.read('token') ?? 'yk';
  await GetStorage().write('bUrl', 'http://192.168.1.34/jobapi/');
  runApp(
    ProviderScope(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        defaultTransition: Transition.noTransition,
        getPages: [
          GetPage(name: '/', page: () => Home(isLogged: token)),
          GetPage(name: '/discover', page: () => DiscoverPage(isLogged: token)),
          GetPage(name: '/search', page: () => Search(isLogged: token)),
          GetPage(name: '/apply', page: () => Apply(isLogged: token)),
          GetPage(name: '/profile', page: () => Profile(isLogged: token)),
          GetPage(name: '/login', page: () => Login(isLogged: token)),
          GetPage(
              name: '/user/changeprofilepicture', page: () => ChangeAvatar()),
          GetPage(name: '/logout', page: () => Logout(isLogged: token)),
          GetPage(name: '/signup', page: () => Signup(isLogged: token)),
          GetPage(name: '/jobs/:id', page: () => JobDetails(isLogged: token)),
          GetPage(
            name: '/forgotten-password/:email/:code',
            page: () => ChangePassword(isLogged: token),
          ),
          GetPage(
              name: '/forgotten-password',
              page: () => ForgottenPassword(isLogged: token)),
        ],
      ),
    ),
  );
}
