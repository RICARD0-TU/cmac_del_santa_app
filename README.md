# CMAC Del Santa

Aplicacion financiera Flutter para CMAC Del Santa, inicializada con una base
enterprise orientada a crecimiento modular.

## Arquitectura

La app sigue una arquitectura Feature-First Clean Architecture con MVVM,
Riverpod, Repository Pattern, Supabase Auth, secure storage y estrategia
Offline-First.

```text
lib/
|-- app/        # Router, DI, config, lifecycle y widget raiz
|-- core/       # Servicios transversales: red, seguridad, errores, theme
|-- shared/     # Design system, widgets, modelos y estados reutilizables
`-- features/   # Modulos funcionales aislados por capa
```

Cada feature se organiza asi:

```text
features/<feature>/
|-- data/
|-- domain/
|-- presentation/
`-- di/
```

## Auth Fase 2

El modulo `features/auth` incluye:

- Login con Supabase Auth.
- Registro con metadata de usuario: `full_name`, `dni`, `phone`.
- Recuperacion de clave digital por correo.
- Sesion JWT persistida en `flutter_secure_storage`.
- Biometria con `local_auth`.
- Guards de navegacion con `GoRouter`.
- Splash inteligente con restauracion de sesion.
- DTO con Freezed y mapper hacia entidad de dominio.
- UseCases, Repository Pattern y datasource Supabase.

## Configuracion Supabase

Supabase se configura por Dart Defines. Si las variables no estan presentes,
la app abre el login y muestra un error controlado al intentar autenticar.

```bash
flutter run \
  --dart-define=APP_ENV=development \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Para pruebas, crea usuarios desde Supabase Authentication o desde la pantalla
de registro de la app. El registro guarda los datos adicionales en
`user_metadata`.

## Comandos utiles

```bash
flutter pub get
dart run build_runner build
flutter analyze
flutter test
flutter build apk --debug
flutter run
flutter build web
```
