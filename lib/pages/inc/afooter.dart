import 'dart:developer';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

Future<int> getNotificationCount() async {
  DateTime now = DateTime.now();
  int unixsuan = now.millisecondsSinceEpoch ~/ 1000;
  int unixbidk = unixsuan + 60;
  int suankizaman = GetStorage().read('unixbidk') != null
      ? int.parse(GetStorage().read('unixbidk'))
      : 0;

  if (suankizaman < unixsuan) {
    log('sorguzamanigeldi.');
    GetStorage().write('unixbidk', unixbidk.toString());

    final response = await http
        .get(Uri.parse(GetStorage().read('bUrl') + 'user/notification-count'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      GetStorage().write('kaccount', data['count'].toString());
      return data['count'] as int;
    } else {
      throw Exception('Error. Cannot connected to server. Please try again.');
    }
  } else {
    log('sorgugerekyok.');
    return GetStorage().read('kaccount') as int;
  }
}

class Enaltkisim extends StatefulWidget {
  final String selectedPage;
  final String isLogged;
  const Enaltkisim(
      {Key? key, required this.selectedPage, required this.isLogged})
      : super(key: key);

  @override
  State<Enaltkisim> createState() => _Enaltkisimstate();
}

class _Enaltkisimstate extends State<Enaltkisim> {
  late final String token;
  @override
  void initState() {
    super.initState();
    final box = GetStorage();
    token = box.read('token') ?? 'yk';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.0,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          BottomNavigationButton(
            icon: Icons.home,
            routeName: '/',
            selected: widget.selectedPage == '/',
          ),
          BottomNavigationButton(
            icon: Icons.track_changes,
            routeName: '/discover',
            selected: widget.selectedPage == '/discover',
          ),
          BottomNavigationButton(
            icon: Icons.search,
            routeName: '/search',
            selected: widget.selectedPage == '/search',
          ),
          if (token != 'yk') ...[
            BottomNavigationButton(
              icon: Icons.message,
              routeName: '/apply',
              selected: widget.selectedPage == '/apply',
              notification: true,
            ),
          ],
          if (token == 'yk') ...[
            BottomNavigationButton(
              icon: Icons.person,
              routeName: '/login',
              selected: widget.selectedPage == '/profile',
            )
          ],
          if (token != 'yk') ...[
            BottomNavigationButton(
              icon: Icons.person,
              routeName: '/profile',
              selected: widget.selectedPage == '/profile',
            )
          ],
        ],
      ),
    );
  }
}

class BottomNavigationButton extends StatelessWidget {
  final IconData icon;
  final String routeName;
  final bool selected;
  final bool notification;

  const BottomNavigationButton({
    Key? key,
    required this.icon,
    required this.routeName,
    required this.selected,
    this.notification = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                width: 1.0,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              FutureBuilder<int>(
                future: notification ? getNotificationCount() : Future.value(0),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data! > 0) {
                    return badges.Badge(
                      showBadge: notification,
                      badgeContent: Text(
                        snapshot.data!.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 30.0,
                        color: selected
                            ? Colors.black
                            : Colors.black.withOpacity(0.5),
                      ),
                    );
                  } else {
                    return Icon(
                      icon,
                      size: 30.0,
                      color: selected
                          ? Colors.black
                          : Colors.black.withOpacity(0.5),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
