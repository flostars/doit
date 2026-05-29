# Architecture

## Principles

1. Monorepo: mobile, backend і shared-артефакти живуть в одному репозиторії.
2. Contract-first: усе, що зачіпає взаємодію клієнта і сервера, спочатку фіксується в `contracts/openapi`.
3. Small PRs: одна задача або один логічний інкремент на один pull request.

## Repository boundaries

- `apps/mobile_app`: Flutter UI, navigation, presentation logic, client-side validation.
- `services/api-server`: HTTP API, business logic, persistence, integration code.
- `contracts/openapi`: джерело правди для API payloads та endpoints.
- `docs`: домовленості, backlog, рішення по структурі.

## Mobile conventions

- Основна структура: `lib/src/features/<feature_name>/...`
- Спільний код для всього клієнта: `lib/src/core/...`
- Кожна нова feature повинна мати щонайменше один тест.

## Backend conventions

- Package root: `com.doit.api`
- Фічі групуються за доменами, а не за технічними типами.
- Новий endpoint має або покриватися тестом контролера, або бути частиною інтеграційного тесту.

## Team workflow

1. Якщо задача змінює API, спочатку онови контракт.
2. Після цього окремо розбивай реалізацію на `backend` і `mobile` задачі.
3. Для незалежних задач використовуй labels: `mobile`, `backend`, `shared`, `blocked`, `needs-api`.
