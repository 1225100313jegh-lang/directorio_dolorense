// ETAPA ANTERIOR: ciclo 2.2 completado; conservar para regresion.
// import 'package:flutter_test/flutter_test.dart';
// import 'package:directorio_dolorense/dominio/negocio.dart';
// 
// void main() {
//   test('desdeJson lee todos los campos', () {
//     final n = Negocio.desdeJson({
//       'id': 1,
//       'nombre': 'Nieves de la Plaza',
//       'categoria': 'Nevería',
//       'telefono': '418-100-0001',
//       'favorito': true,
//     });
//     expect(n.id, 1);
//     expect(n.nombre, 'Nieves de la Plaza');
//     expect(n.favorito, true);
//   });
// 
//   /* Caso pendiente: valores predeterminados para campos opcionales.
//   test('campos opcionales ausentes usan valores por omisión', () {
//     final n = Negocio.desdeJson({'id': 2, 'nombre': 'X', 'categoria': 'Y'});
//     expect(n.telefono, '');
//     expect(n.favorito, false);
//   });
//   */
// 
//   /* Caso pendiente: omitir el id al serializar un negocio nuevo.
//   test('aJson no manda id cuando es nuevo', () {
//     const n = Negocio(nombre: 'X', categoria: 'Y');
//     expect(n.aJson().containsKey('id'), false);
//   });
//   */
// 
//   /* Caso pendiente: copiar sin modificar los demás datos.
//   test('copiarCon cambia solo el favorito', () {
//     const n = Negocio(id: 3, nombre: 'X', categoria: 'Y');
//     final f = n.copiarCon(favorito: true);
//     expect(f.favorito, true);
//     expect(f.nombre, 'X');
//     expect(f.id, 3);
//   });
//   */
// }
//

void main() {}
