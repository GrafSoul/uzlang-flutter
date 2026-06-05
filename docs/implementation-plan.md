# UzLang — План реализации по фазам (чек-лист)

> Статус: **план (код не начат)**. Дата: 2026-06-03.
> Опирается на [`architecture.md`](architecture.md). Стек: Flutter + GetX + Drift + GetStorage + Freezed + FSRS, пакет `uzlang_mobile`.
> Отмечай `[x]` по мере выполнения. Принцип: фундамент (0–3) → фичи по UX-потоку (4–9) → сквозные слои и релиз (10–13).

## Прогресс по фазам

- [x] Фаза 0 — Окружение и скаффолд ✅
- [x] Фаза 1 — Дизайн-система в коде (тема + виджеты + ассеты Inter/SVG) ✅
- [x] Фаза 2 — Данные: Drift-схема + сидинг ✅
- [x] Фаза 3 — Домен + ядро-сервисы + DI + роутинг ✅
- [x] Фаза 4 — Онбординг ✅
- [ ] Фаза 5 — Главная + Выбор темы + Тема-обзор
- [ ] Фаза 6 — Слова: Учить / Повтор / Тест + Результат
- [ ] Фаза 7 — Фразы: Заперты / Учить / Тест
- [ ] Фаза 8 — Геймификация (сквозная)
- [ ] Фаза 9 — Прогресс/Статистика + Профиль/Настройки
- [ ] Фаза 10 — Аудио
- [ ] Фаза 11 — Состояния, полировка, QA
- [ ] Фаза 12 — Релиз V1

---

## ФАЗА 0 — Окружение и скаффолд

**Цель:** пустой, но запускаемый проект с правильной структурой и зависимостями.

- [x] Flutter SDK найден: `~/Development/flutter/bin` (Flutter 3.32.2 / Dart 3.8.1)
- [x] `flutter create --org com.uzlang --project-name uzlang_mobile .` (коммит `204bee6`)
- [x] `pubspec.yaml`: get, drift, drift_flutter, get_storage, freezed_annotation, json_annotation, flutter_svg, just_audio, fsrs, path_provider, intl
- [x] dev_deps: build_runner, drift_dev, freezed, json_serializable, flutter_lints
- [x] `flutter pub get` (есть `pubspec.lock`)
- [x] Дерево папок `lib/` (app/core/domain/data/features/l10n) + `assets/{icons,fonts,audio}` — заготовки (`.gitkeep`)
- [x] `analysis_options.yaml` (strict lints) + `.gitignore` (codegen, .dart_tool)
- [x] **DoD:** `flutter analyze` → No issues found; `build_runner build` → зелёный (freezed/json/drift тулчейн ок); `pub get` ок
- ℹ️ `sqlite3_flutter_libs` подтянут транзитивно через `drift_flutter` (есть в lock); если позже понадобится явная версия — добавить прямой зависимостью к Фазе 2
- ℹ️ `lib/main.dart` пока дефолтный counter — заменяется в Фазе 1; on-device `flutter run` владелец глянет глазами при первом запуске

---

## ФАЗА 1 — Дизайн-система в коде (тема) 🔗0

**Цель:** токены и базовые виджеты из Figma-DS в коде.

- [x] `core/theme/app_colors.dart` (зеркало `UzLang / Colors`; success `#5BC46B`, accent `#FF8A3D`)
- [x] `core/theme/app_text_styles.dart` (Inter: Display/Word/Title/Heading/Body/Reading/Label/Caption)
- [x] `core/theme/app_dimens.dart` (радиусы 12/16/20/28, отступы 4-pt, иконки 20/24/26)
- [x] `core/theme/app_theme_ext.dart` (`ThemeExtension`: surfaceRaised/line/тинты/статусы + copyWith/lerp)
- [x] `core/theme/app_theme.dart` (`ThemeData` dark по умолч. + light-заглушка + `context.colors`)
- [x] баррелы `core/theme/theme.dart`, `features/shared/widgets/widgets.dart`
- [~] `features/shared/widgets/` — готово: **PrimaryButton, SecondaryButton, AppCard, AppChip, AppIcon(SVG)**. Остальные (AppScaffold, SegmentedProgress, AppToggle, BottomNavBar, RingBadge) — по мере надобности экранов (Фаза 5+)
- [x] `assets/icons/*.svg` — **21 иконка экспортирована из Figma-DS** (`ic-*` → SVG, перекраска через ColorFilter) + `assets/fonts/Inter.ttf` (вариативный, OFL) объявлены в pubspec
- [x] **DoD:** витрина DS (`main.dart` → DesignSystemShowcase) собрана, проходит тест, запущена на эмуляторе Android — совпадает с Figma (тёмная) ✅

---

## ФАЗА 2 — Данные: Drift-схема + сидинг контента 🔗0

**Цель:** локальная БД со схемой и залитым контентом.

- [x] Таблицы (`tables.dart`): `Topics`, `Words`, `Phrases`, `CardProgress` (FSRS: stability/difficulty/due/state/reps/lapses…, полиморфно по cardKind), `UserStats`, `BlockProgress`. FK + `PRAGMA foreign_keys=ON`
- [x] `app_database.dart` (schemaVersion 1, миграции) + DAO (`ContentDao`, `ProgressDao`) + codegen
- [x] **Контент перенесён из `seedData.js` ЦЕЛИКОМ** → `assets/seed/content.json` (Node-экстракция): **17 тем, 2922 слова, 255 фраз** (решение владельца — всё из React-версии)
- [x] Сидинг: `ContentSeeder` + `SeedVersionStore` (интерфейс) + `GetStorageSeedVersionStore` (impl). Идемпотентно, атомарно (транзакция), пере-сидинг по версии
- [x] **DoD:** ✅ in-memory тесты — сеет 17/2922/255, идемпотентность, пере-сидинг, связи FK; 6 тестов зелёные
- ℹ️ codegen (`*.g.dart`) не в VCS (gitignore) — регенерится `build_runner`. На UI/старт ещё не подключено — это Фаза 3 (InitialBinding)

---

## ФАЗА 3 — Домен + ядро-сервисы + DI + роутинг 🔗1,2

**Цель:** бизнес-логика и каркас приложения.

- [x] `domain/entities/` (Freezed): Topic, Word, Phrase, CardProgress, UserProfile + WordBlock (plain) + enums (CardKind/SrState/Rating/ScriptMode/BlockStatus)
- [x] `domain/repositories/` — интерфейсы ContentRepository, ProgressRepository
- [x] `data/repositories/` — Drift-реализации (DriftContentRepository/DriftProgressRepository) + мапперы Row→domain (Drift-строки переименованы в `*Row` через `@DataClassName`)
- [x] `domain/services/sr_scheduler.dart` — интерфейс `SrScheduler` + `fsrs_scheduler.dart` (**FSRS** 2.0.1, маппинг state/rating)
- [x] `domain/services/learning_service.dart` — блоки по 20 (статусы locked/available/completed), разблок фраз
- [x] `core/services/` — UserService(анон localUserId), AccessService(isPremium→true), SettingsService(GetStorage), AudioService(NoopAudioService заглушка)
- [x] `app/` — initial_binding (DI permanent), app_routes, app_pages, app.dart (GetMaterialApp) + main bootstrap (GetStorage.init → БД → ensureSeeded → DI)
- [x] `features/home/` — HomeController/Binding/Page (реальные темы из БД)
- [x] **DoD:** ✅ приложение поднимается на эмуляторе, сеет БД, показывает 17 тем; роуты заведены; FSRS (4) + learning_service (6) тесты зелёные; весь сьют 17/17

---

## ФАЗА 4 — Онбординг 🔗3

**Цель:** первый запуск спрашивает имя/письменность/цель.

- [ ] `features/onboarding/` controller + binding
- [ ] 5 страниц: Приветствие → Имя → Письменность(3 варианта) → Цель дня → Готово
- [ ] Сохранение имени/настроек, флаг «онбординг пройден»
- [ ] **DoD:** проходится 1 раз; повторный запуск → Главная

---

## ФАЗА 5 — Главная + Выбор темы + Тема-обзор 🔗3,4

**Цель:** навигация по контенту.

- [ ] `features/home/` (streak/XP/цель, «Продолжить», список тем, нижняя навигация)
- [ ] `features/topics/` (Продолжаю/Доступные/Закрытые, прогресс/замки)
- [ ] `features/topic_detail/` (табы Слова|Фразы, блоки 20, CTA)
- [ ] **DoD:** Главная → Выбор темы → Тема-обзор; данные реальные; замки/прогресс верны

---

## ФАЗА 6 — Слова: Учить / Повтор / Тест + Результат 🔗5

**Цель:** ядро обучения словам.

- [ ] `features/learn/` свайп-карточка (Учить)
- [ ] Повтор (FSRS due; оценки Снова/Трудно/Хорошо/Лёгко)
- [ ] Тест (выбор перевода, 10/10, сердца-жизни)
- [ ] `features/result/` (Блок пройден: +XP, точность, streak, разблок след. блока)
- [ ] Настройки урока (шит, шестерёнка): письменность/время на лету
- [ ] **DoD:** цикл блока работает; FSRS пишет интервалы; ошибки тратят жизни

---

## ФАЗА 7 — Фразы: Заперты / Учить / Тест 🔗6

**Цель:** фразы как закрепление.

- [ ] Состояние «заперты» (прогресс слов темы)
- [ ] «Учить» (фраза + пример + аудио)
- [ ] «Тест» (собери фразу из слов-чипов)
- [ ] Разблок по `learnedWords >= totalWords`
- [ ] **DoD:** фразы открываются после всех слов; цикл Учить→Тест→Результат

---

## ФАЗА 8 — Геймификация (сквозная) 🔗5,6,7

**Цель:** крючки удержания.

- [ ] XP-начисление
- [ ] Streak (серия дней, лучшая серия)
- [ ] Дневная цель (минуты/XP)
- [ ] Достижения
- [ ] **DoD:** streak/XP/цель/достижения растут и отражаются на Главной и в Прогрессе

---

## ФАЗА 9 — Прогресс/Статистика + Профиль/Настройки 🔗8

**Цель:** табы «Прогресс» и «Профиль».

- [ ] `features/progress/` (streak-герой, сетка статов, недельный график, достижения)
- [ ] Пустое состояние Прогресса (новый юзер)
- [ ] `features/profile/` (смена имени, мини-статы, настройки с шитами выбора)
- [ ] Смена темы (`Get.changeThemeMode`) и письменности применяется
- [ ] **DoD:** оба таба на реальных данных; настройки применяются; пустое состояние ок

---

## ФАЗА 10 — Аудио 🔗6,7

**Цель:** озвучка слов и фраз.

- [ ] Батч-генерация TTS заранее (Mohir.ai приоритет / Azure / Google) → opus/mp3
- [ ] `AudioService` (just_audio): воспроизведение из ассетов/кеша
- [ ] Докачка по темам (задел под облако)
- [ ] **DoD:** аудио играет офлайн на словах/фразах; flutter_tts только fallback

---

## ФАЗА 11 — Состояния, полировка, QA 🔗9,10

**Цель:** все состояния и шлифовка.

- [ ] Состояния: Загрузка / Ошибка-офлайн / Пусто / Нет жизней
- [ ] Обработка ошибок на всех async
- [ ] Анимации переходов
- [ ] Сверка с Figma
- [ ] Quality gates (build/lint/dartdoc/code-review/тесты)
- [ ] **DoD:** нет «голых» состояний; критичные пути покрыты тестами

---

## ФАЗА 12 — Релиз V1 🔗11

**Цель:** сборка в сторы.

- [ ] App icon + splash (flutter_native_splash)
- [ ] Bundle id, версии, подпись (Android keystore, iOS profiles)
- [ ] `flutter build appbundle` / `ipa`
- [ ] Метаданные сторов + политика приватности
- [ ] Аккаунты: Apple Dev ($99/год) + Google Play ($25)
- [ ] **DoD:** релизные сборки собираются и проходят проверки

---

## ФАЗА 2-ПРОДУКТ (после V1 — швы заложены)

Активируются подменой реализаций интерфейсов, без переписывания фич.

- [ ] Авторизация — `AuthService` + Supabase Auth; `UserService` → аккаунт
- [ ] Облачный синхрон — удалённый `ProgressRepository`, фоновый синк (offline-first)
- [ ] Платежи — RevenueCat (Apple IAP + Google Play); `AccessService.isPremium()` реально; `Topic.isPremium` вкл.
- [ ] Контент из облака — версионирование/докачка (Supabase Storage)
- [ ] FSRS-тюнинг на реальных данных
- [ ] Светлая тема + локаль `uz`
- [ ] (Опц.) Лидерборды/лиги; веб-канал оплаты (Paddle/Lemon Squeezy → Payoneer)

---

## Сводная последовательность

```text
0 Скаффолд → 1 Тема/DS → 2 Drift+сидинг → 3 Домен+DI+роутинг
   → 4 Онбординг → 5 Главная/Темы → 6 Слова(Учить/Повтор/Тест)+Результат
   → 7 Фразы → 8 Геймификация → 9 Прогресс/Профиль → 10 Аудио
   → 11 Состояния/QA → 12 Релиз V1
   → [Фаза 2-продукт: auth / синхрон / оплата / облако-контент]
```

**Первый шаг при команде «погнали»:** Фаза 0 — починка Flutter в PATH и `flutter create`.
