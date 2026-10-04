# CRM Celular

CRM mini personal desarrollado con Flutter para administrar contactos y relaciones desde el celular.
La interfaz utiliza un estilo oscuro premium, con negro, gris y dorado como colores principales.

## Estructura

El proyecto Flutter vive directamente en la raíz del repositorio. La aplicación sigue una separación MVC:

- `lib/models`: modelos y estados de datos.
- `lib/views`: pantallas de la aplicación.
- `lib/controllers`: lógica que coordina la vista y los servicios.
- `lib/services`: comunicación con APIs y fuentes externas.
- `lib/widgets`: componentes visuales reutilizables.

## Ejecutar

```bash
flutter pub get
flutter run
```

La aplicación está configurada para utilizar la API de producción desplegada en Vercel:

`https://portafolio-basthianf.vercel.app/api/`

Las URLs de desarrollo local quedan comentadas en `lib/services/api_service.dart`.

La sección **Solicitudes** obtiene únicamente consultas activas (`estado = true`):

`https://portafolio-basthianf.vercel.app/api/consultas/getall`

Para crear una solicitud utiliza:

`https://portafolio-basthianf.vercel.app/api/consultas/crear`

Para editar una solicitud existente:

`PATCH https://portafolio-basthianf.vercel.app/api/consultas/editar/{id}`

Para desactivar una solicitud:

`PATCH https://portafolio-basthianf.vercel.app/api/consultas/desactivar/{id}`

Para consultar una solicitud individual:

`GET https://portafolio-basthianf.vercel.app/api/consultas/getbyid/{id}`

Los valores de `plan` son numéricos: `1` Básico, `2` Pro y `3` Avanzado.

## Proyectos

La sección **Proyectos** utiliza estos endpoints de producción:

- `POST https://portafolio-basthianf.vercel.app/api/proyectos/crear`
- `GET https://portafolio-basthianf.vercel.app/api/proyectos/getall`
- `GET https://portafolio-basthianf.vercel.app/api/proyectos/getbyid/{id}`
- `PUT https://portafolio-basthianf.vercel.app/api/proyectos/editar/{id}`

La desactivación se realiza con `PUT https://portafolio-basthianf.vercel.app/api/proyectos/editar/{id}` y el cuerpo `{"estado": false}`.

También incluye un panel para enviar solicitudes HTTP manuales y consultar la respuesta.
