import 'package:flutter/material.dart';
import 'package:probando/main.dart';
import 'package:probando/pruebas/scanerqr.dart';
import 'package:probando/pruebas/ubicacion.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(),
          ),
          ListTile(
            title: const Text('Main'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyApp()),
              );
            },
          ),
          ListTile(
            title: const Text(
              'Ubicacion',
              style: TextStyle(),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Ubicacion()),
              );
            },
          ),
          ListTile(
            title: const Text(
              'Scaner',
              style: TextStyle(),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Scaner()),
              );
            },
          ),
        ],
      ),
    );
  }
}
