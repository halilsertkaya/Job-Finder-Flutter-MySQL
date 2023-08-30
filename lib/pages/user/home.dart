import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../inc/aheader.dart';
import '../inc/afooter.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key, required this.isLogged}) : super(key: key);

  final String isLogged;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  late Future<List<dynamic>> _futureJobList;

  @override
  void initState() {
    super.initState();
    _futureJobList = _fetchJobList();
  }

  Future<List<dynamic>> _fetchJobList() async {
    final response =
        await http.get(Uri.parse(GetStorage().read('bUrl') + 'home/list'));

    if (response.statusCode == 200) {
      final decodedJson = jsonDecode(response.body) as List<dynamic>;
      return decodedJson;
    } else {
      throw Exception('Failed to fetch job list');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Enustkisim(),
      body: FutureBuilder<List<dynamic>>(
        future: _futureJobList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error: Could not connect to server, please try again later.',
                style: TextStyle(color: Colors.red),
              ),
            );
          } else {
            final jobList = snapshot.data as List<dynamic>;
            return ListView.builder(
              itemCount: jobList.length,
              itemBuilder: (context, index) {
                final job = jobList[index] as Map<String, dynamic>;
                return ListTile(
                  title: Text(
                    job['title'] as String,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold, // Kalın yazı stilini burada belirtin
                      fontSize: 12, // Yazı boyutunu burada belirtin
                    ),
                  ),
                  subtitle: Text(
                    job['name'] as String,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold, // Kalın yazı stilini burada belirtin
                      fontSize: 10, // Yazı boyutunu burada belirtin
                    ),
                  ),
                  leading: Image.network(job['picture'] as String),
                  onTap: () {
                    final jobId = job['id'] as String;
                    Navigator.pushNamed(context, '/jobs/$jobId');
                  },
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar:
          Enaltkisim(selectedPage: '/', isLogged: widget.isLogged),
    );
  }
}
