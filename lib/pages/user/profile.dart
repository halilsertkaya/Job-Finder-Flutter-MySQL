import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../inc/afooter.dart';
import '../inc/aheader.dart';
import 'dart:convert';

final userDataProvider =
    FutureProvider.autoDispose<Map<String, String>>((ref) async {
  final box = GetStorage();
  final token = box.read('token');

  if (token != null) {
    try {
      final response = await http
          .get(Uri.parse(GetStorage().read('bUrl') + 'user/check'), headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final bool status = jsonData['status'];
        if (status) {
          final String id = jsonData['id'];
          final String mail = jsonData['mail'];
          final String picture = jsonData['picture'];
          return {
            'id': id,
            'mail': mail,
            'picture': picture,
          };
        } else {
          throw Exception('User not found. Please try again.');
        }
      } else {
        throw Exception('Connection Error.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  } else {
    return <String, String>{};
  }
});

class Profile extends ConsumerWidget {
  const Profile({Key? key, required this.isLogged}) : super(key: key);

  final String isLogged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataProvider);

    return userData.when(data: (data) {
      // Token var, profil sayfasını göster
      if (data.isNotEmpty) {
        return Scaffold(
          appBar: const Enustkisim(),
          body: userData.when(
            data: (data) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(
                            data['picture'] ?? 'assets/images/avatar.png'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data['id']} İsim Soyisim',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${data['mail']}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // diğer satırların tasarımı burada olacak
                ListTile(
                  leading: const Icon(Icons.video_camera_back),
                  title: const Text('Change Profile Picture'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Eğitim Bilgileri butonuna basıldığında yapılacak işlemler
                    Navigator.pushReplacementNamed(
                        context, '/user/changeprofilepicture');
                  },
                ),
                // diğer satırların tasarımı burada olacak
                ListTile(
                  leading: const Icon(Icons.password_outlined),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Eğitim Bilgileri butonuna basıldığında yapılacak işlemler
                  },
                ),
                // diğer satırların tasarımı burada olacak
                ListTile(
                  leading: const Icon(Icons.broadcast_on_personal),
                  title: const Text('Personal Information'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Eğitim Bilgileri butonuna basıldığında yapılacak işlemler
                  },
                ),
                // diğer satırların tasarımı burada olacak
                ListTile(
                  leading: const Icon(Icons.cast_for_education),
                  title: const Text('Education Information'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Eğitim Bilgileri butonuna basıldığında yapılacak işlemler
                  },
                ),
                // diğer satırların tasarımı burada olacak
                ListTile(
                  leading: const Icon(Icons.work_outline),
                  title: const Text('My Career History'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Eğitim Bilgileri butonuna basıldığında yapılacak işlemler
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.wifi_find),
                  title: const Text('My Preferences'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    //Navigator.pushReplacementNamed(context, '/');
                    // Tercihlerim butonuna basıldığında yapılacak işlemler
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Tercihlerim butonuna basıldığında yapılacak işlemler
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Text(
                'Bir hata oluştu: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
          bottomNavigationBar:
              Enaltkisim(selectedPage: '/profile', isLogged: isLogged),
        );
      } else {
        // Token yok, login sayfasına yönlendir
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed('/login');
        });
        return const SizedBox.shrink();
      }
    }, loading: () {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }, error: (error, stackTrace) {
      // Hata var, hatayı göster
      return Scaffold(
        body: Center(
          child: Text(error.toString()),
        ),
      );
    });
  }
}
