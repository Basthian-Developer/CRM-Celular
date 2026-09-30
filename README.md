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

La URL local `http://localhost:8000/api/` queda comentada en
`lib/services/api_service.dart` para usarla durante el desarrollo local.
