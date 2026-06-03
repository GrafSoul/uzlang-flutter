# UzLang — Архитектура и стек

> Статус: **согласовано (черновик к скаффолду)**. Дата: 2026-06-03.
> Код ещё НЕ написан. Этот документ — план перед `flutter create`.

## Подтверждённые решения

- **Имя пакета:** `uzlang_mobile` (bundle id вида `com.uzlang.mobile`, домен подтвердить позже).
- **SR-алгоритм:** **FSRS** сразу (за интерфейсом `SrScheduler`, пакет `fsrs`).
- **Модели:** **Freezed** + json_serializable (иммутабельность, copyWith, sealed-состояния).
- **State/DI/Nav:** **GetX** (выбор владельца).
- **Локальная БД:** **Drift** (SQLite). **Key-value:** **GetStorage**.

---

## 1. Полный стек

| Слой | Технология | Зачем |
|---|---|---|
| Язык | Dart 3.x (null safety, records, sealed) | — |
| State / DI / Nav | **GetX** | `GetMaterialApp`, `GetxController`, `Bindings`, named routes |
| Локальная БД | **Drift** (SQLite) | реляц. данные: слова↔темы↔фразы, прогресс, due-даты SR |
| Key-value | **GetStorage** | настройки, streak, флаги, `localUserId`, флаг онбординга |
| Модели | **Freezed + json_serializable** | иммутабельные сущности, copyWith, безопасный разбор |
| Иконки | **flutter_svg** | DS — SVG line-набор (как в Figma) |
| Аудио | **just_audio** | проигрывание заранее сгенерённых TTS-файлов, кеш |
| SR | **fsrs** | интервальный повтор за интерфейсом `SrScheduler` |
| Codegen | **build_runner** | drift + freezed |
| i18n | **GetX translations** (`ru`, позже `uz`) | без лишних зависимостей |

Доп.: `path_provider`, `sqlite3_flutter_libs`, `intl` (форматирование чисел/дат в статистике).

---

## 2. Архитектура — clean-ish, feature-first, на GetX

Три слоя + ядро. **Контроллер тонкий**, бизнес-логика в `domain/services`.
Презентация НИКОГДА не ходит в Drift/Supabase напрямую — только через интерфейсы репозиториев.

```
lib/
├── app/
│   ├── app.dart                  # GetMaterialApp (theme, initialBinding, routes)
│   ├── routes/
│   │   ├── app_routes.dart        # const имена роутов
│   │   └── app_pages.dart         # GetPage[] + binding на каждый
│   └── bindings/
│       └── initial_binding.dart   # глобальные сервисы (Get.put)
│
├── core/
│   ├── theme/
│   │   ├── app_colors.dart         # токены (= переменные из Figma)
│   │   ├── app_text_styles.dart    # типошкала (= text-styles из Figma)
│   │   ├── app_dimens.dart         # отступы/радиусы
│   │   ├── app_theme_ext.dart      # ThemeExtension: surfaceRaised, accentTint, successTint…
│   │   └── app_theme.dart          # ThemeData dark (по умолч.) + light (задел)
│   ├── services/
│   │   ├── user_service.dart        # ШОВ: анонимный localUserId
│   │   ├── access_service.dart      # ШОВ: isPremium() → true
│   │   ├── audio_service.dart
│   │   └── settings_service.dart    # обёртка GetStorage (письменность, цель, звук, тема)
│   └── utils/  constants/
│
├── domain/
│   ├── entities/                   # Word, Phrase, Topic, WordBlock, Progress, UserProfile, ScriptMode
│   ├── repositories/               # АБСТРАКТНЫЕ интерфейсы (ContentRepository, ProgressRepository)
│   └── services/
│       ├── spaced_repetition.dart   # интерфейс SrScheduler + FSRS-реализация
│       └── learning_service.dart    # логика блоков (Учить→Повтор→Тест 10/10, разблок фраз)
│
├── data/
│   ├── local/
│   │   ├── database/               # Drift: tables/, daos/, app_database.dart
│   │   └── seed/seed_data.dart     # контент из старого seedData.js
│   └── repositories/               # РЕАЛИЗАЦИИ интерфейсов (Drift-backed)
│
├── features/                       # по фиче: controller + binding + page + widgets
│   ├── onboarding/  home/  topics/  topic_detail/
│   ├── learn/   (words: learn / review / test)
│   ├── phrases/ (locked / learn / test)
│   ├── result/  progress/  profile/
│   └── shared/  (AppCard, PrimaryButton, AppIcon, ProgressBar, Toggle…)
│
└── l10n/  (ru.dart, uz.dart)
```

---

## 3. Обвязка GetX (контроллеры + bindings)

- **Binding на каждый роут** → `Get.lazyPut(() => SomeController())`. Контроллер живёт пока открыт экран, чисто уничтожается.
- **Контроллер тонкий**: держит реактивное состояние (`.obs` / `Rx`), дёргает domain-сервисы; без SQL и алгоритмов.
- **Глобальные сервисы** (`UserService`, `AccessService`, `SettingsService`, `AudioService`, репозитории, `AppDatabase`) → в `InitialBinding` через `Get.put(permanent: true)`.
- Навигация — `Get.toNamed(Routes.x)`; задел под **middleware** (гард авторизации в фазе 2).

Поток данных (пример): `LearnController` ← `LearningService` (что показать дальше, SR) ←
`ProgressRepository` / `ContentRepository` (интерфейсы) ← Drift-реализация.
Поменяем источник данных — презентация не трогается.

---

## 4. Тема «как положено в GetX»

- `GetMaterialApp(theme: AppTheme.light, darkTheme: AppTheme.dark, themeMode: …)`.
- Токены из Figma-DS → `AppColors` + `AppTextStyles`; собираем `ThemeData`
  (ColorScheme + кастомный **ThemeExtension** для не-материаловских цветов:
  `surfaceRaised`, `accentTint`, `successTint`).
- Тёмная — по умолчанию; светлая — заглушка-задел (в профиле выбор Тёмная/Светлая/Системная уже нарисован).
- Смена темы через `Get.changeThemeMode()`, хранение выбора в `SettingsService`.
- Виджеты берут цвета только из `Theme.of(context)` / расширения — никаких хардкод-хексов.

---

## 5. Швы под будущее (заложено сразу)

| Будущее | Сейчас (V1) | Как достроим |
|---|---|---|
| Авторизация | `UserService` → анонимный `localUserId` | + `AuthService` (Supabase), `UserService` привязывается к аккаунту; репо принимают `userId` |
| Оплата | `AccessService.isPremium()` → `true` | RevenueCat реально проверяет подписку |
| Облако / синхрон | `ProgressRepository` только Drift | + удалённый источник + фоновый синк (offline-first, Drift = истина локально) |
| Рост контента | `ContentRepository` → встроенный seed | версионирование/докачка из Supabase; у `Topic` поле `isPremium` (пока игнор) |
| SR-алгоритм | интерфейс `SrScheduler` + **FSRS** | параметры/замена без правок выше |

**Принцип:** всё «наружу» через интерфейсы в `domain`, реализации в `data`.
Достройка = новая реализация + перепривязка в `InitialBinding`; презентация и логика не меняются.

---

## 6. Связь с дизайном (Figma)

- Файл «UzLang — Flutter» (key `hQxp3dh03nozogXrofWi0s`): ~21 экран + состояния, премиум-тёмный.
- DS в файле: переменные `UzLang / Colors`, color/text-styles `UzLang/*`, DS-борд.
- `core/theme/app_colors.dart` и `app_text_styles.dart` = зеркало этих токенов 1:1.
- Иконки — единый SVG line-набор (24×24, stroke 2); эмодзи только как иллюстрации.

---

## 7. Блокеры перед скаффолдом

1. **Flutter SDK в PATH** — в окружении был только `dart` (`flutter not found`). Починить до `flutter create`.
2. Подтвердить bundle-домен (`com.uzlang.mobile` или иной).

## 8. Открытые вопросы на потом (не блокируют старт)

- Точные параметры FSRS (дефолтные веса на старт, тюнинг позже на реальных данных).
- Формат/именование аудиофайлов и стратегия кеша (по темам).
- Светлая тема — палитра (сейчас только тёмная).
