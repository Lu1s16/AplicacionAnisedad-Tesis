import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import "main.dart" as app;

void main() async {
  // Inicializar sqflite para web
  databaseFactory = databaseFactoryFfiWeb;

  // Ejecutar la aplicación principal
  app.main();
}