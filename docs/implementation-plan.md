# UzLang — План реализации по фазам (чек-лист)

> Статус: **план (код не начат)**. Дата: 2026-06-03.
> Опирается на [`architecture.md`](architecture.md). Стек: Flutter + GetX + Drift + GetStorage + Freezed + FSRS, пакет `uzlang_mobile`.
> Отмечай `[x]` по мере выполнения. Принцип: фундамент (0–3) → фичи по UX-потоку (4–9) → сквозные слои и релиз (10–13).

## Прогресс по фазам

- [ ] Фаза 0 — Окружение и скаффолд
- [ ] Фаза 1 — Дизайн-система в коде (тема)
- [ ] Фаза 2 — Данные: Drift-схема + сидинг
- [ ] Фаза 3 — Домен + ядро-сервисы + DI + роутинг
- [ ] Фаза 4 — Онбординг
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

- [ ] Починить Flutter SDK в PATH (блокер — был `flutter not found`)
- [ ] `flutter create --org com.uzlang --project-name uzlang_mobile .`
- [ ] `pubspec.yaml`: get, drift, drift_flutter, sqlite3_flutter_libs, get_storage, freezed_annotation, json_annotation, flutter_svg, just_audio, fsrs, path_provider, intl
- [ ] dev_deps: build_runner, drift_dev, freezed, json_serializable, flutter_lints
- [ ] Дерево папок `lib/` (app/core/domain/data/features/l10n) — заготовки
- [ ] `analysis_options.yaml` (strict lints) + `.gitignore` (codegen, .dart_tool)
- [ ] **DoD:** `flutter run` пустой экран; `flutter analyze` + `build_runner build` зелёные

---

## ФАЗА 1 — Дизайн-система в коде (тема) 🔗0

**Цель:** токены и базовые виджеты из Figma-DS в коде.

- [ ] `core/theme/app_colors.dart` (зеркало `UzLang / Colors`; success `#5BC46B`, accent `#FF8A3D`)
- [ ] `core/theme/app_text_styles.dart` (Inter: Word/Title/Heading/Body/Reading/Label/Caption)
- [ ] `core/theme/app_dimens.dart` (радиусы 16/18/20/28, отступы, иконки 24/26)
- [ ] `core/theme/app_theme_ext.dart` (`ThemeExtension`: surfaceRaised, accentTint, successTint)
- [ ] `core/theme/app_theme.dart` (`ThemeData` dark по умолч. + light заглушка)
- [ ] `features/shared/widgets/` (AppScaffold, PrimaryButton, SecondaryButton, AppCard, AppIcon(SVG), SegmentedProgress, AppToggle, BottomNavBar, RingBadge, Chip)
- [ ] `assets/icons/*.svg` (экспорт line-иконок) + `assets/fonts/Inter`
- [ ] **DoD:** демо-страница виджетов совпадает с Figma (тёмная)

---

## ФАЗА 2 — Данные: Drift-схема + сидинг контента 🔗0

**Цель:** локальная БД со схемой и залитым контентом.

- [ ] Таблицы: `Topics`, `Words`, `Phrases`, `WordBlocks`, `Progress` (ease/interval/due/state для FSRS), `Stats`
- [ ] `app_database.dart` + DAO (`ContentDao`, `ProgressDao`)
- [ ] `data/local/seed/seed_data.dart` — перенос из старого `seedData.js` (17 тем, ~130 слов, ~255 фраз; uz/latin/reading/ru/level/topicKey)
- [ ] Сидинг при первом запуске (флаг GetStorage) + версия контента
- [ ] **DoD:** БД создаётся, сидинг 1 раз; DAO возвращает данные; тесты DAO

---

## ФАЗА 3 — Домен + ядро-сервисы + DI + роутинг 🔗1,2

**Цель:** бизнес-логика и каркас приложения.

- [ ] `domain/entities/` (Freezed): Topic, Word, Phrase, WordBlock, CardProgress, UserProfile, enum ScriptMode
- [ ] `domain/repositories/` — интерфейсы ContentRepository, ProgressRepository
- [ ] `data/repositories/` — Drift-реализации
- [ ] `domain/services/spaced_repetition.dart` — интерфейс `SrScheduler` + **FSRS**
- [ ] `domain/services/learning_service.dart` — блоки 20 (Учить→Повтор→Тест 10/10), разблок фраз, выбор due
- [ ] `core/services/` — UserService(анон localUserId), AccessService(isPremium→true), SettingsService, AudioService(заглушка)
- [ ] `app/` — initial_binding, app_routes, app_pages, app.dart (GetMaterialApp)
- [ ] **DoD:** приложение поднимается, роуты заведены; юнит-тесты FSRS и learning_service

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
