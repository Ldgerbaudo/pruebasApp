// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  String codigo = '';
  String codigoPieza = '';
  late String codigoPiezaGlobal;
  TextEditingController cantidadController = TextEditingController();

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
          Text('Codigo: ${infoResult[0][0]}'),
          ElevatedButton(
            onPressed: () {
              _mostrarAlertDialog(context, infoResult[0]);
            },
            child: const Text('Ver Información Detallada'),
          ),
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
        codigo = qrText;
      });
      selectCodigo(codigo);
    });
  }

  Future<void> selectCodigo(String codigo) async {
    final connection = await DatabaseHelper.openConnection();
    try {
      final result = await DatabaseHelper.executeQuery(
        connection,
        'SELECT "Codigo", "Descripcion" FROM "Tpieza" WHERE "Codigo" = \'$codigo\'',
      );

      if (result.isNotEmpty) {
        _mostrarResultado(result);
        codigoPiezaGlobal = result[0][0];
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

  void _mostrarAlertDialog(BuildContext context, List<dynamic> info) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Información del Código'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Origen:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  )),
              Text(
                'Codigo pieza origen: ${info[0]} - Descripcion origen: ${info[1]} - Deposito origen: 01',
              ),
              const SizedBox(height: 10),
              const Text('Destino:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  )),
              Text(
                'Codigo pieza destino: ${info[0]} - Descripcion destino: ${info[1]} - Deposito destino: 04',
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Cantidad: '),
                  Expanded(
                    child: TextField(
                      controller: cantidadController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                postCodigo(info[0]);
                Navigator.of(context).pop();
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> postCodigo(String codigoPieza) async {
    final connection = await DatabaseHelper.openConnection();

    try {
      DateTime now = DateTime.now();
      String fechaActual =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      String horaActual =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      String usuario = obtenerUsuarioHora(now.hour);

      if (int.parse(cantidadController.text) > 0) {
        var result = await connection
            .query('SELECT MAX("id") FROM public."Ttransferencia"');
        var idQuery = result.first.first + 1;

        await connection.query('''
        INSERT INTO public."Ttransferencia"(id, "Corigen", "Cdestino", "Dorigen", "Ddestino", "Cantidad", "Procesado", "Fecha", "Hora", "Usuario")
        VALUES ($idQuery, '$codigoPieza', '$codigoPieza', '01', '04', '${cantidadController.text}', true, '$fechaActual', '$horaActual', '$usuario');
      ''');

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.green,
              title: Text(
                "Transferencia realizada con éxito. ID: $idQuery",
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child:
                      const Text("Ok", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      } else {
        Fluttertoast.showToast(
          msg: "La cantidad debe ser mayor que 0",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error al realizar la transferencia: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      await connection.close();
    }
  }

  String obtenerUsuarioHora(int hora) {
    return (hora >= 0 && hora < 12) ? 'TM' : 'TT';
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
