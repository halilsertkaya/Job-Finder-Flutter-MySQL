import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'inc/afooter.dart';
import 'inc/aheader.dart';

class Search extends ConsumerStatefulWidget {
  const Search({Key? key, required this.isLogged}) : super(key: key);

  final String isLogged;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchState();
}

class _SearchState extends ConsumerState<Search> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Enustkisim(),
      body: const Center(child: Text('Arama')),
      bottomNavigationBar:
          Enaltkisim(selectedPage: '/search', isLogged: widget.isLogged),
    );
  }
}
