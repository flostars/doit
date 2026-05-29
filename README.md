# doit

Monorepo-скафолд для `Flutter` мобільного клієнта і `Java` backend, який можна одразу пушити в репозиторій і використовувати для паралельної роботи над задачами.

## Структура

```text
.
├── apps/
│   └── mobile_app/        # Flutter UI, state, feature modules, widget tests
├── contracts/
│   └── openapi/           # Спільні API-контракти між mobile і backend
├── docs/
│   ├── architecture.md    # Домовленості по структурі і межах відповідальності
│   └── backlog.md         # Початковий backlog для розподілу задач
├── services/
│   └── api-server/        # Spring Boot backend на Maven
└── .github/               # Issue templates, PR template, CI
```

## Швидкий старт

### Backend

```bash
cd services/api-server
mvn spring-boot:run
```

Health endpoint:

```text
GET http://localhost:8080/api/v1/health
```

### Mobile

Поточний `Flutter` скафолд містить `lib/`, `test/`, `pubspec.yaml` і базову структуру фіч, але не містить generated native-папок, бо в середовищі не був встановлений `Flutter SDK`.

Після встановлення Flutter:

```bash
cd apps/mobile_app
flutter create .
flutter pub get
flutter run
```

`flutter create .` створить `android/`, `ios/`, `web/` та інші platform folders поверх уже підготовленого Dart-коду.

## Як розділяти задачі

1. `shared` зміни починай із `contracts/openapi` або `docs/architecture.md`.
2. `backend` задачі роби всередині `services/api-server`.
3. `mobile` задачі роби всередині `apps/mobile_app/lib/src/features`.
4. Для кожної окремої одиниці роботи створюй issue за шаблоном `Task`, `Feature` або `Bug report`.

Початковий список задач уже доданий у [docs/backlog.md](docs/backlog.md).
