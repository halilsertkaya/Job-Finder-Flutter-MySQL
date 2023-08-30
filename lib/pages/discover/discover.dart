import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
// ignore: import_of_legacy_library_into_null_safe

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:http/http.dart' as http;

import '../inc/afooter.dart';
import '../inc/aheader.dart';

MapController mapController = MapController();

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({Key? key, required this.isLogged}) : super(key: key);

  final String isLogged;

  @override
  DiscoverPageState createState() => DiscoverPageState();
}

class DiscoverPageState extends ConsumerState<DiscoverPage> {
  LatLng _center = LatLng(36.884570, 30.701791);
  bool _locationGranted = false;
  List<dynamic> _jobs = [];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    if (kIsWeb) {
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).then((Position position) {
        setState(() {
          _locationGranted = true;
          _center = LatLng(position.latitude, position.longitude);
          _fetchJobs(position.latitude, position.longitude);
        });
      }).catchError((error) {});
    } else {
      PermissionStatus status = await Permission.location.request();
      if (status != PermissionStatus.granted) {
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Konum İzni'),
            content: const Text(
                'Uygulamanın konumunu kullanmak için konum izni gerekli.'),
            actions: [
              TextButton(
                child: const Text('İptal'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Ayarlar'),
                onPressed: () => openAppSettings(),
              ),
            ],
          ),
        );
      } else {
        await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).then((Position position) {
          setState(() {
            _locationGranted = true;
            _center = LatLng(position.latitude, position.longitude);
            _fetchJobs(position.latitude, position.longitude);
          });
        }).catchError((error) {});
      }
    }
  }

  Future<void> _fetchJobs(lat, long) async {
    final response = await http.get(Uri.parse(
        GetStorage().read('bUrl') + 'discover/list?latlong=$lat,$long'));
    if (response.statusCode == 200) {
      setState(() {
        _jobs = jsonDecode(response.body);
      });
    } else {
      throw Exception('Failed to fetch jobs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Enustkisim(),
      body: _locationGranted
          ? FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: _center,
                zoom: 12.0,
              ),
              nonRotatedChildren: [
                AttributionWidget.defaultWidget(
                  source: 'OpenStreetMap',
                  onSourceTapped: null,
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lat: ${_center.latitude}'),
                        Text('Long: ${_center.longitude}'),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 90,
                    child: Swiper(
                      loop: false,
                      itemBuilder: (BuildContext context, int index) {
                        final job = _jobs[index];
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: InkWell(
                            onTap: () {
                              // Konumu ortalama işlemi burada yapılacak.
                              // get the new center point from the job object
                              LatLng newCenter = LatLng(
                                double.parse(job['latlong'].split(',')[0]),
                                double.parse(job['latlong'].split(',')[1]),
                              );
                              // call the setCenter method of the map controller to center the map on the new point
                              mapController.move(newCenter, 12.0);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: NetworkImage(job['picture']),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          job['title'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          job['name'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              size: 12,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 3),
                                            Expanded(
                                              child: Text(
                                                job['location'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          job['distance'] + ' km yakında' ?? '',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: _jobs.length,
                      viewportFraction: 0.8,
                      scale: 0.95,
                      control: const SwiperControl(),
                    ),
                  ),
                ),
              ],
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 20.0,
                      height: 20.0,
                      point: _center,
                      builder: (ctx) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                    ..._jobs
                        .map(
                          (job) => Marker(
                            width: 40.0,
                            height: 40.0,
                            point: LatLng(
                              double.parse(job['latlong'].split(',')[0]),
                              double.parse(job['latlong'].split(',')[1]),
                            ),
                            builder: (ctx) => Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color:
                                        const Color.fromARGB(255, 255, 61, 61),
                                    width: 1),
                                image: DecorationImage(
                                  image: NetworkImage(job['picture']),
                                  fit: BoxFit.contain,
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      contentPadding: const EdgeInsets.all(10),
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Sol taraftaki resim
                                            Container(
                                              width: 90,
                                              height: 90,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      job['picture']),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            // Sağ taraftaki bilgiler
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    job['title'],
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    job['name'],
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    job['location'],
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pushNamed(
                                                            context,
                                                            '/jobs/${job['id']}');
                                                        // Butona basıldığında yapılacak işlemler
                                                      },
                                                      child: const Text(
                                                          'İlanı İncele'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      bottomNavigationBar: Enaltkisim(
        selectedPage: '/discover',
        isLogged: widget.isLogged,
      ),
    );
  }
}
