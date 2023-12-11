// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:probando/database.dart';
import 'package:probando/pruebas/menu.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

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
  List<List<dynamic>> infoResult = [];

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
    } else {}
  }

  void _inicializarEscaneo() {}

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
            child: QRView(
              key: qrKey,
              onQRViewCreated: _qrEscaneado,
            ),
          ),
          Expanded(
            flex: 1,
            child: _infoCodigo(),
          ),
        ],
      ),
    );
  }

  Widget _infoCodigo() {
    if (infoResult.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Corigen: ${infoResult[0][0]} - Cdestino: ${infoResult[0][1]}'),
          Text('Dorigen: ${infoResult[0][2]} - Ddestino: ${infoResult[0][3]}'),
          Text('Cantidad: ${infoResult[0][4]}'),
          const Text(
            'Escanee otro QR para ver info',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      if (qrText == 'Escanea un código QR') {
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Escanea un código QR',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      } else {
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No se encontró el código'),
            Text(
              'Escanee otro QR para ver info',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }
    }
  }

  void _qrEscaneado(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData.code ?? 'N/A';
      });
      selectCodigo(qrText);
    });
  }

  Future<void> selectCodigo(String codigo) async {
    final connection = await DatabaseHelper.openConnection();
    try {
      final result = await DatabaseHelper.executeQuery(
        connection,
        'SELECT "Corigen", "Cdestino", "Dorigen", "Ddestino", "Cantidad" FROM "Ttransferencia" WHERE "Corigen" = \'$codigo\'',
      );
      if (result.isNotEmpty) {
        _mostrarResultado(result);
      } else {
        setState(() {
          infoResult = [];
        });
      }
    } catch (e) {
      setState(() {
        qrText = 'Error al realizar la consulta';
      });
    } finally {
      await DatabaseHelper.closeConnection(connection);
    }
  }

  void _mostrarResultado(List<List<dynamic>> result) {
    setState(() {
      infoResult = List.from(result);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
