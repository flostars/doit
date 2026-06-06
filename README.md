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
GET https://localhost:8443/api/v1/health
```

Auth endpoints:

```text
POST https://localhost:8443/api/v1/auth/login
POST https://localhost:8443/api/v1/auth/register
POST https://localhost:8443/api/v1/auth/logout
GET  https://localhost:8443/api/v1/users/me
```

Локальний сервер піднімається з self-signed TLS-сертифікатом, тому transport між клієнтом і сервером шифрується через `HTTPS`. Паролі на сервері не зберігаються відкритим текстом: вони хешуються через `BCrypt`.

Користувачі зберігаються в локальній файловій `H2` базі:

```bash
./.data/api-server/doit-auth
```

Приклад реєстрації:

```bash
curl -k https://localhost:8443/api/v1/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"username":"new.user@doit.local","password":"SecurePass123!","displayName":"New User"}'
```

Приклад логіну:

```bash
curl -k https://localhost:8443/api/v1/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"new.user@doit.local","password":"SecurePass123!"}'
```

Приклад доступу до захищеного endpoint:

```bash
curl -k https://localhost:8443/api/v1/users/me \
  -H 'Authorization: Bearer <access-token>'
```

Приклад logout з ревокацією токена:

```bash
curl -k -X POST https://localhost:8443/api/v1/auth/logout \
  -H 'Authorization: Bearer <access-token>'
```

Dev bootstrap-користувача можна перевизначити через змінні оточення:

```bash
DOIT_AUTH_USERNAME=demo@doit.local
DOIT_AUTH_PASSWORD=ChangeMe123!
DOIT_AUTH_DISPLAY_NAME="Demo User"
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

Клієнт має режими `вхід` і `реєстрація`, ходить у backend по `HTTPS`, а після авторизації викликає захищений `GET /api/v1/users/me` з bearer token. Кнопка `Вийти` викликає `POST /api/v1/auth/logout` і ревокує поточний токен на сервері. За замовчуванням використовується `https://127.0.0.1:8443`, але для Android емулятора потрібно передати адресу хоста явно:

```bash
flutter run --dart-define=DOIT_API_BASE_URL=https://10.0.2.2:8443
```

Для Flutter Web потрібно відкрити й довірити локальний сертифікат у браузері, інакше браузер сам заблокує self-signed `HTTPS`.

## Як розділяти задачі

1. `shared` зміни починай із `contracts/openapi` або `docs/architecture.md`.
2. `backend` задачі роби всередині `services/api-server`.
3. `mobile` задачі роби всередині `apps/mobile_app/lib/src/features`.
4. Для кожної окремої одиниці роботи створюй issue за шаблоном `Task`, `Feature` або `Bug report`.

Початковий список задач уже доданий у [docs/backlog.md](docs/backlog.md).
