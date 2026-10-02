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

La aplicación utiliza actualmente la API desplegada en Vercel:

`https://portafolio-basthianf.vercel.app/api/`

La sección **Solicitudes** obtiene los registros de consultas desde Vercel:

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

Las URLs locales quedan comentadas en `lib/services/api_service.dart` para desarrollo local.
