import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import '../inc/afooter.dart';
import '../inc/aheader.dart';

class Apply extends ConsumerStatefulWidget {
  const Apply({Key? key, required this.isLogged}) : super(key: key);

  final String isLogged;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ApplyState();
}

class _ApplyState extends ConsumerState<Apply> {
  @override
  void initState() {
    super.initState();
    final box = GetStorage();
    var token = box.read('token') ?? widget.isLogged;

    if (token == 'yk') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Enustkisim(),
      body: const Center(child: Text('Başvurularım')),
      bottomNavigationBar:
          Enaltkisim(selectedPage: '/apply', isLogged: widget.isLogged),
    );
  }
}
