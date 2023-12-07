// Funcion para abrir y cerrar la conexion a la base de datos
import 'package:postgres/postgres.dart';

class DatabaseHelper {
  static Future<PostgreSQLConnection> openConnection() async {
    final connection = PostgreSQLConnection(
        // // Conexion a BD de escritorio remoto
        // '192.168.10.246',
        // 5432,
        // 'MacoserNc',
        // username: 'postgres',
        // password: 'gasf4273'

        // Conexion a BD de escritorio remoto Pruebas
        '192.168.10.246',
        5432,
        'pruebasLuProd',
        username: 'postgres',
        password: 'gasf4273'

        // // Conexion a BD local
        // '192.168.10.118',
        // 5432,
        // 'MacoserNc',
        // username: 'postgres',
        // password: '123456',
        );

    await connection.open();
    return connection;
  }

  static Future<List<List<dynamic>>> executeQuery(
      PostgreSQLConnection connection, String query) async {
    final result = await connection.query(query);
    return result;
  }

  static Future<void> closeConnection(PostgreSQLConnection connection) async {
    await connection.close();
  }
}
