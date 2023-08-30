import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import '../inc/afooter.dart';

final box = GetStorage(); // GetStorage kutucuğunu oluşturuyoruz

class Logout extends ConsumerStatefulWidget {
  const Logout({Key? key, required this.isLogged}) : super(key: key);

  final String isLogged;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LogoutState();
}

class _LogoutState extends ConsumerState<Logout> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Token'i sil
    box.remove('token');
    // Login sayfasına yönlendir
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text('Çıkış yaptınız.')),
      bottomNavigationBar:
          Enaltkisim(selectedPage: '/profile', isLogged: widget.isLogged),
    );
  }
}
