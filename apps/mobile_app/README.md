# mobile_app

Flutter-частина репозиторію.

## Що вже є

- базовий `pubspec.yaml`
- стартовий `MaterialApp`
- feature-first структура в `lib/src/features`
- widget smoke test

## Що треба зробити після встановлення Flutter SDK

```bash
flutter create .
flutter pub get
flutter test
```

`flutter create .` додасть native-папки (`android`, `ios`, `web`, `macos`, `linux`, `windows`) без перезапису вашого Dart-коду.
