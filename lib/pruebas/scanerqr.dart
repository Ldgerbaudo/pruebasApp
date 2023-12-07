
// ignore_for_file: deprecated_member_use

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:probando/pruebas/menu.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class Scaner extends StatelessWidget {
  const Scaner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scaner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ScanerQr(title: 'Scaner'),
    );
  }
}

class ScanerQr extends StatefulWidget {
  const ScanerQr({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<ScanerQr> createState() => _ScanerQr();
}

class _ScanerQr extends State<ScanerQr> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;
  late String qrText;

  @override
  void initState() {
    super.initState();
    qrText = 'Escanea un código QR';
    _solicitarPermisoDeCamara();
  }

  void _solicitarPermisoDeCamara() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      _inicializarEscaneo();
    } else {
      // Si se niegan los permisos, manejar según tus necesidades
    }
  }

  void _inicializarEscaneo() {
    // Inicializar el escáner aquí
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuPage(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 5,
            child: GestureDetector(
              onTap: () {
                _abrirURL(qrText);
              },
              child: QRView(
                key: qrKey,
                onQRViewCreated: _qrEscaneado,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Escaneo: ',
                  style: TextStyle(fontSize: 16.0),
                ),
                RichText(
                  text: TextSpan(
                    text: qrText,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _abrirURL(qrText);
                      },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _qrEscaneado(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData.code ?? 'N/A';
      });
    });
  }

  void _abrirURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Manejar si no se puede abrir el enlace
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
