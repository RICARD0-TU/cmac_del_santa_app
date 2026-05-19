# CMAC Del Santa

Aplicacion financiera Flutter para CMAC Del Santa, inicializada con una base
enterprise orientada a crecimiento modular.

## Arquitectura

La app sigue una arquitectura Feature-First Clean Architecture con MVVM,
Riverpod, Repository Pattern, Supabase-ready configuration y estrategia
Offline-First.

```text
lib/
├── app/        # Router, DI, config, lifecycle y widget raiz
├── core/       # Servicios transversales: red, seguridad, errores, theme
├── shared/     # Design system, widgets, modelos y estados reutilizables
└── features/   # Modulos funcionales aislados por capa
```

Cada feature se organiza asi:

```text
features/<feature>/
├── data/
├── domain/
├── presentation/
└── di/
```

## Modulos iniciales

- auth
- dashboard
- accounts
- savings
- loans
- transfers
- payments
- cards
- profile
- notifications
- support
- analytics
- security
- settings

## Configuracion

Supabase se configura por Dart Defines. Si las variables no estan presentes,
la app arranca sin inicializar Supabase, lo que facilita desarrollo local.

```bash
flutter run \
  --dart-define=APP_ENV=development \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

## Comandos utiles

```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter build web
```
