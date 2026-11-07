// ============================================================
// PASOS 3.1, 3.2 y 3.3 - Cliente HTTP completo
// ESTADO: VERDE
// ============================================================
// Activo:
//   · 3.1  GET /negocios  ->  jsonDecode  ->  List<Negocio>
//   · 3.2  fallos tecnicos -> excepciones del dominio
//          (500 / sin red / timeout / JSON roto)
//   · 3.3  GET ?q= (busqueda), POST, PUT y DELETE
//
// Los pasos posteriores (4, 5.1, 6.1, 6.2) se habilitan despues.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../dominio/excepciones.dart';
import '../dominio/negocio.dart';

/// Cliente HTTP del directorio. Recibe el [http.Client] desde afuera
/// (inyeccion de dependencias) para poder probarlo con MockClient.
class NegociosApi {
  final http.Client _cliente;
  final String baseUrl;
  final Duration espera;

  NegociosApi(this._cliente, this.baseUrl,
      {this.espera = const Duration(seconds: 5)});

  Uri _uri(String ruta) => Uri.parse('$baseUrl$ruta');
  static const _json = {'Content-Type': 'application/json'};

  /// 3.1 - Trae el directorio y convierte cada elemento en un [Negocio].
  /// 3.2 - Un JSON que no se puede leer termina en RespuestaInvalida.
  /// 3.3 - La busqueda viaja codificada en el parametro ?q=.
  Future<List<Negocio>> listar({String busqueda = ''}) async {
    final consulta =
        busqueda.isEmpty ? '' : '?q=${Uri.encodeQueryComponent(busqueda)}';
    final r =
        await _ejecutar(() => _cliente.get(_uri('/negocios$consulta')));
    try {
      final lista = jsonDecode(r.body) as List;
      return lista
          .map((e) => Negocio.desdeJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw RespuestaInvalidaException();
    }
  }

  /// 3.3 - POST /negocios con el cuerpo en JSON.
  Future<Negocio> crear(Negocio n) async {
    final r = await _ejecutar(() => _cliente.post(_uri('/negocios'),
        headers: _json, body: jsonEncode(n.aJson())));
    return _leerUno(r);
  }

  /// 3.3 - PUT /negocios/{id} con el cuerpo en JSON.
  Future<Negocio> actualizar(Negocio n) async {
    final r = await _ejecutar(() => _cliente.put(_uri('/negocios/${n.id}'),
        headers: _json, body: jsonEncode(n.aJson())));
    return _leerUno(r);
  }

  /// 3.3 - DELETE /negocios/{id}. La API responde 204 sin cuerpo.
  Future<void> eliminar(int id) async {
    await _ejecutar(() => _cliente.delete(_uri('/negocios/$id')));
  }

  Negocio _leerUno(http.Response r) {
    try {
      return Negocio.desdeJson(jsonDecode(r.body) as Map<String, dynamic>);
    } catch (_) {
      throw RespuestaInvalidaException();
    }
  }

  /// Un solo lugar donde se traducen los fallos tecnicos a errores
  /// del negocio:
  ///   - se corta la espera si el servidor no contesta (timeout);
  ///   - sin red o sin respuesta -> SinConexionException;
  ///   - cualquier codigo fuera de 2xx -> ErrorServidorException.
  Future<http.Response> _ejecutar(
      Future<http.Response> Function() peticion) async {
    http.Response r;
    try {
      r = await peticion().timeout(espera);
    } on SocketException {
      throw SinConexionException();
    } on TimeoutException {
      throw SinConexionException();
    } on http.ClientException {
      throw SinConexionException();
    }
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw ErrorServidorException(r.statusCode);
    }
    return r;
  }
}
