import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';

import '../inc/afooter.dart';
import '../inc/aheader.dart';

class JobDetails extends ConsumerStatefulWidget {
  const JobDetails({Key? key, required this.isLogged}) : super(key: key);

  final String isLogged;

  @override
  JobDetailsState createState() => JobDetailsState();
}

class JobDetailsState extends ConsumerState<JobDetails> {
  late Future<Map<String, dynamic>> _futureJob;

  @override
  void initState() {
    super.initState();
    _futureJob = _fetchJob();
  }

  Future<Map<String, dynamic>> _fetchJob() async {
    final jobId = Get.parameters['id'];
    final response =
        await http.get(Uri.parse(GetStorage().read('bUrl') + 'job/$jobId'));
    if (response.statusCode == 200) {
      final decodedJson = jsonDecode(response.body) as Map<String, dynamic>;
      return decodedJson;
    } else {
      throw Exception('Failed to fetch job details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Enustkisim(),
      body: SingleChildScrollView(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _futureJob,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else {
              final job = snapshot.data as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['title'] as String,
                      style: const TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    Text(job['name'] as String),
                    const SizedBox(height: 8.0),
                    Image.network(job['picture'] as String),
                    const SizedBox(height: 8.0),
                    Text(
                      job['detail'] as String,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
      bottomNavigationBar:
          Enaltkisim(selectedPage: '/search', isLogged: widget.isLogged),
    );
  }
}
