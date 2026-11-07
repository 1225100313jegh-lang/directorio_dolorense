# Directorio de Negocios de Dolores Hidalgo · API local

## Pruebas y evidencias

### Captura 1 · Servidor en ejecución y registro de peticiones

La terminal muestra las peticiones recibidas: `GET /negocios`, `POST /negocios` y `DELETE /negocios/6`.

![alt text](image.png)

### Captura 2 · Creación de negocio (POST)

`Invoke-RestMethod` envía un negocio válido y la API responde con el registro y su `id` asignado.

![alt text](image-1.png)

### Captura 3 · Lista de negocios en el navegador

Consulta a `http://localhost:3000/negocios`. Se muestran los 5 negocios iniciales en JSON.

![alt text](image-2.png)

### Captura 10 · Eliminación (DELETE)

`curl.exe -i -X DELETE localhost:3000/negocios/6` responde `204 No Content`, sin cuerpo.

![Captura 10](docs/capturas/captura-10.png)

## Estructura del proyecto

```
directorio_dolores/
├── api/
│   └── server.js
└── docs/
    └── capturas/
```

## TDD desde el paso 2.2

### 2.2 · Modelo `Negocio`

#### Rojo

Las pruebas especifican la lectura de los campos JSON, los valores predeterminados de `telefono` y `favorito`, la omisión de `id` al serializar un negocio nuevo y la copia que cambia solo el favorito. Fallan porque la implementación de `Negocio` está comentada: Dart no encuentra la clase ni sus métodos. Esto confirma que las pruebas detectan el comportamiento todavía ausente.
![alt text](image-3.png)

#### Verde

Al habilitar la clase, el constructor y los métodos `desdeJson`, `aJson` y `copiarCon`, el modelo cumple las expectativas. Las pruebas pasan porque cada entrada y operación produce los valores requeridos.
![alt text](image-4.png)
### 2.3 · Excepciones del dominio

#### Rojo

Las pruebas de errores fallan si no existen las excepciones esperadas o si una excepción no conserva información como el código HTTP. Así se muestra que el cliente todavía no puede comunicar los distintos tipos de fallo de forma reconocible.
![alt text](image-5.png)
#### Verde

Pasan cuando hay excepciones diferenciadas para falta de conexión, error del servidor y respuesta inválida, y cada una conserva los datos que necesita quien la maneja.
![alt text](image-6.png)

### 3.1 · Cliente HTTP y listado

#### Rojo

La prueba usa `MockClient` para revisar el método, la ruta y la conversión del JSON. Falla si el cliente no existe, construye una petición distinta de `GET /negocios` o no convierte la respuesta en objetos `Negocio`.
![alt text](image-7.png)

#### Verde

Pasa cuando el cliente envía la petición esperada y transforma cada elemento de la respuesta JSON en un modelo `Negocio`. El mock permite comprobarlo sin depender del servidor ni de la red.
![alt text](image-8.png)


### 3.2 · Manejo de errores

#### Rojo

Las pruebas fallan si una respuesta 500, una desconexión o un JSON inválido se propagan sin tratarse o se convierten en una excepción equivocada.
![alt text](image-9.png)

#### Verde

Pasan cuando cada condición produce la excepción de dominio correspondiente y el error HTTP conserva su código. Así, las capas superiores pueden distinguir qué ocurrió.
![alt text](image-10.png)

### 3.3 · Crear, buscar, actualizar y eliminar

#### Rojo

Las pruebas fallan si las operaciones usan un método o una ruta incorrectos, omiten parámetros o encabezados, envían un cuerpo JSON inesperado o no aceptan correctamente una respuesta 204 sin cuerpo.
![alt text](image-11.png)

#### Verde

Pasan cuando cada operación cumple su contrato HTTP y las respuestas exitosas se interpretan correctamente. El mock verifica solicitudes y respuestas sin llamar a una API externa.
![alt text](image-12.png)

### 4 · Conexión con la API local

#### Rojo

La integración falla si la URL no corresponde al entorno, el servidor no está accesible o la plataforma bloquea el tráfico HTTP local. Los tests con `MockClient` no detectan esos problemas porque no establecen una conexión real.
![alt text](image-13.png)

#### Verde

La conexión funciona cuando la app usa la dirección adecuada para el emulador, escritorio o celular, el servidor está disponible y la plataforma permite la solicitud local.
![alt text](image-14.png)

### 5.1 · ViewModel y estados

#### Rojo

Las pruebas fallan si el ViewModel omite estados, notifica una transición incorrecta o no representa una respuesta vacía o un error.
![alt text](image-15.png)

#### Verde

Pasan cuando el ViewModel comunica correctamente los estados inicial, cargando, listo, vacío y error según el resultado, y permite reintentar cuando corresponde.
![alt text](image-16.png)

### 6.1 · Pantalla de negocios

#### Rojo

Las pruebas de widgets fallan si la pantalla no refleja el estado recibido, muestra contenido incorrecto o no ofrece la interacción esperada, como reintentar después de un error.
![alt text](image-17.png)

#### Verde

Pasan cuando cada estado del ViewModel se representa con la vista correspondiente y las acciones de la pantalla están conectadas.
![alt text](image-18.png)

