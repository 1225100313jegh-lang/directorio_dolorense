// ============================================================
// PASO 5.1 - ViewModel y los cinco estados
// ESTADO: VERDE
// ============================================================
// Una pantalla honesta nunca se queda en blanco. El ViewModel
// recorre y anuncia:
//   inicial  -> aun no se pidio nada
//   cargando -> esperando respuesta (rueda de carga)
//   listo    -> llegaron datos
//   vacio    -> llego bien pero no hay nada
//   error    -> algo fallo, con mensaje claro y opcion de reintentar

import 'package:flutter/foundation.dart';

import '../datos/negocios_api.dart';
import '../dominio/negocio.dart';

enum Estado { inicial, cargando, listo, vacio, error }

class NegociosViewModel extends ChangeNotifier {
  final NegociosApi api;
  Estado estado = Estado.inicial;
  List<Negocio> negocios = [];
  String? mensajeError;

  NegociosViewModel(this.api);

  /// Anuncia cargando, resuelve y termina en listo, vacio o error.
  /// Tambien es la accion de "Reintentar" desde la pantalla.
  Future<void> cargar({String busqueda = ''}) async {
    estado = Estado.cargando;
    mensajeError = null;
    notifyListeners();
    try {
      negocios = await api.listar(busqueda: busqueda);
      estado = negocios.isEmpty ? Estado.vacio : Estado.listo;
    } catch (e) {
      mensajeError = e.toString();
      estado = Estado.error;
    }
    notifyListeners();
  }

  /// Crea en el servidor y recarga: el id lo asigna la API.
  Future<void> agregar(Negocio n) async {
    try {
      await api.crear(n);
      await cargar();
    } catch (e) {
      mensajeError = e.toString();
      estado = Estado.error;
      notifyListeners();
    }
  }

  /// Borra en el servidor y quita el renglon de la lista local,
  /// sin volver a pedirla completa.
  Future<void> eliminar(Negocio n) async {
    try {
      await api.eliminar(n.id!);
      negocios = negocios.where((x) => x.id != n.id).toList();
      estado = negocios.isEmpty ? Estado.vacio : Estado.listo;
    } catch (e) {
      mensajeError = e.toString();
      estado = Estado.error;
    }
    notifyListeners();
  }

  /// Actualiza con la respuesta del servidor: la vista refleja
  /// exactamente lo que la API confirmo.
  Future<void> alternarFavorito(Negocio n) async {
    try {
      final nuevo = await api.actualizar(n.copiarCon(favorito: !n.favorito));
      negocios = [for (final x in negocios) x.id == nuevo.id ? nuevo : x];
    } catch (e) {
      mensajeError = e.toString();
    }
    notifyListeners();
  }
}
