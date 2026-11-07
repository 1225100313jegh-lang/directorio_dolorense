// ============================================================
// RONDA 4 - Conexion con la API local
// ESTADO: VERDE
// ============================================================
// Esta prueba NO usa MockClient: abre una conexion real.
// Es la unica forma de detectar lo que el mock no ve:
//   · que la URL corresponda al entorno donde corre la app,
//   · que el servidor este encendido,
//   · que la plataforma permita el trafico HTTP local.
//
// Requiere la API levantada:  node api/server.js
//
// En verde se usa urlBaseApi(), que devuelve:
//   · http://10.0.2.2:3000  dentro del emulador Android,
//   · http://localhost:3000 en escritorio y simulador iOS,
//   · la URL de --dart-define=API_URL cuando se define.

import 'package:directorio_dolorense/datos/config_api.dart';
import 'package:directorio_dolorense/datos/negocios_api.dart';
import 'package:directorio_dolorense/dominio/excepciones.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

NegociosApi apiReal() =>
    NegociosApi(http.Client(), urlBaseApi(), espera: const Duration(seconds: 5));

void main() {
  test('la API real responde en la URL del entorno', () async {
    final lista = await apiReal().listar();

    expect(lista, isNotEmpty);
    expect(lista.first.nombre, isNotEmpty);
  });

  test('la API real devuelve los negocios iniciales', () async {
    final lista = await apiReal().listar();
    final nombres = lista.map((n) => n.nombre).toList();

    expect(nombres, contains('Nieves de la Plaza'));
    expect(nombres, contains('Tacos Don Chema'));
  });

  test('la busqueda real filtra por nombre', () async {
    final lista = await apiReal().listar(busqueda: 'nieve');

    expect(lista, isNotEmpty);
    expect(lista.every((n) => n.nombre.toLowerCase().contains('nieve')), isTrue);
  });

  test('un id inexistente conserva el codigo 404', () async {
    expect(
      apiReal().eliminar(9999),
      throwsA(isA<ErrorServidorException>()
          .having((e) => e.codigo, 'codigo', 404)),
    );
  });
}
