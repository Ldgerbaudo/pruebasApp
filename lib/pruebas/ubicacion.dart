import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:probando/pruebas/menu.dart';

class Ubicacion extends StatelessWidget {
  const Ubicacion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ubicacion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const UbicacionMaps(title: 'Ubicacion'),
    );
  }
}

class UbicacionMaps extends StatefulWidget {
  const UbicacionMaps({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<UbicacionMaps> createState() => _UbicacionMaps();
}

class _UbicacionMaps extends State<UbicacionMaps> {
  bool compartiendoUbicacion = false;
  Position? posicionActual;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuPage(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        children: <Widget>[
          Positioned(
            bottom: 20.0,
            left: 30.0,
            right: 30.0,
            child: ElevatedButton(
              onPressed: () {
                if (compartiendoUbicacion) {
                  noCompartir();
                } else {
                  compartirUbicacion();
                }
              },
              child: Text(compartiendoUbicacion
                  ? 'Dejar de Compartir Ubicación'
                  : 'Compartir Ubicación'),
            ),
          ),
          if (compartiendoUbicacion && posicionActual != null)
            // ACA, CHAT GPT, ACÁ VA
            Positioned(
              top: 20.0,
              left: 30.0,
              child: Text(
                'Ubicación actual: ${posicionActual!.latitude}, ${posicionActual!.longitude}',
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
        ],
      ),
    );
  }

  void compartirUbicacion() async {
    var status = await Permission.location.request();

    if (status.isGranted) {
      Position posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        compartiendoUbicacion = true;
        posicionActual = posicion;
      });
    } else {
      // Permiso denegado, manejar según tus necesidades
    }
  }

  void noCompartir() {
    setState(() {
      compartiendoUbicacion = false;
    });
  }
}
