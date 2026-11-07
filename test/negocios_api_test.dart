// ============================================================
// PASO 3.3 - Crear, buscar y eliminar
// (pruebas del cliente HTTP: 3.1 + 3.2 + 3.3)
// ============================================================
// En rojo: estas pruebas deben FALLAR mientras NegociosApi no
// mande ?q= y no implemente crear / actualizar / eliminar.

import 'dart:convert';
import 'dart:io';

import 'package:directorio_dolorense/datos/negocios_api.dart';
import 'package:directorio_dolorense/dominio/excepciones.dart';
import 'package:directorio_dolorense/dominio/negocio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

NegociosApi apiCon(MockClient c) => NegociosApi(c, 'http://prueba');

void main() {
  // ------------------------------------------------------------
  // 3.1 - Listar
  // ------------------------------------------------------------
  test('listar convierte el JSON en objetos Negocio', () async {
    final api = apiCon(MockClient((req) async {
      expect(req.method, 'GET');
      expect(req.url.path, '/negocios');
      return http.Response(
          jsonEncode([
            {'id': 1, 'nombre': 'A', 'categoria': 'X'},
            {'id': 2, 'nombre': 'B', 'categoria': 'Y'},
          ]),
          200);
    }));
    final lista = await api.listar();
    expect(lista.length, 2);
    expect(lista.first, isA<Negocio>());
    expect(lista.first.nombre, 'A');
  });

  // ------------------------------------------------------------
  // 3.2 - Los casos de falla
  // ------------------------------------------------------------
  test('status 500 lanza ErrorServidorException con el codigo', () async {
    final api = apiCon(MockClient((_) async => http.Response('boom', 500)));
    expect(
        api.listar(),
        throwsA(isA<ErrorServidorException>()
            .having((e) => e.codigo, 'codigo', 500)));
  });

  test('sin red lanza SinConexionException', () {
    final api =
        apiCon(MockClient((_) async => throw const SocketException('x')));
    expect(api.listar(), throwsA(isA<SinConexionException>()));
  });

  test('timeout se trata como sin conexion', () {
    final api = NegociosApi(
      MockClient((_) async {
        await Future.delayed(const Duration(milliseconds: 200));
        return http.Response('[]', 200);
      }),
      'http://prueba',
      espera: const Duration(milliseconds: 20),
    );
    expect(api.listar(), throwsA(isA<SinConexionException>()));
  });

  test('JSON roto lanza RespuestaInvalidaException', () {
    final api = apiCon(MockClient((_) async => http.Response('<html>', 200)));
    expect(api.listar(), throwsA(isA<RespuestaInvalidaException>()));
  });

  // ------------------------------------------------------------
  // 3.3 - Crear, buscar y eliminar
  // ------------------------------------------------------------
  test('listar con busqueda manda el parametro q codificado', () async {
    final api = apiCon(MockClient((req) async {
      expect(req.url.queryParameters['q'], 'nieve limon');
      return http.Response('[]', 200);
    }));
    await api.listar(busqueda: 'nieve limon');
  });

  test('crear envia JSON con Content-Type correcto', () async {
    final api = apiCon(MockClient((req) async {
      expect(req.method, 'POST');
      expect(req.headers['Content-Type'], contains('application/json'));
      final cuerpo = jsonDecode(req.body) as Map<String, dynamic>;
      expect(cuerpo['nombre'], 'Nuevo');
      return http.Response(jsonEncode({...cuerpo, 'id': 9}), 201);
    }));
    final creado =
        await api.crear(const Negocio(nombre: 'Nuevo', categoria: 'Z'));
    expect(creado.id, 9);
  });

  test('eliminar usa DELETE al id correcto', () async {
    final api = apiCon(MockClient((req) async {
      expect(req.method, 'DELETE');
      expect(req.url.path, '/negocios/4');
      return http.Response('', 204);
    }));
    await api.eliminar(4);
  });

  // RETO DEL MANUAL: actualizar usa PUT y manda el favorito.
  test('actualizar usa PUT al id y manda el favorito', () async {
    final api = apiCon(MockClient((req) async {
      expect(req.method, 'PUT');
      expect(req.url.path, '/negocios/3');
      final cuerpo = jsonDecode(req.body) as Map<String, dynamic>;
      expect(cuerpo['favorito'], true);
      return http.Response(jsonEncode({...cuerpo, 'id': 3}), 200);
    }));
    const base = Negocio(id: 3, nombre: 'A', categoria: 'X');
    final actualizado = await api.actualizar(base.copiarCon(favorito: true));
    expect(actualizado.id, 3);
    expect(actualizado.favorito, true);
  });
}
