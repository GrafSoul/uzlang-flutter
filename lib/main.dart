import 'package:flutter/material.dart';

import 'core/theme/theme.dart';
import 'features/shared/widgets/widgets.dart';

void main() {
  runApp(const UzLangApp());
}

/// Корень приложения на этапе Фазы 1.
///
/// Пока показывает витрину дизайн-системы (`DesignSystemShowcase`). На Фазе 3
/// будет заменён на `GetMaterialApp` с роутингом и биндингами.
class UzLangApp extends StatelessWidget {
  /// Создаёт корневой виджет приложения.
  const UzLangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UzLang',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const DesignSystemShowcase(),
    );
  }
}

/// Витрина дизайн-системы: палитра, типографика, компоненты.
///
/// Служит визуальной проверкой соответствия кода Figma-DS (Фаза 1 DoD).
class DesignSystemShowcase extends StatefulWidget {
  /// Создаёт экран-витрину.
  const DesignSystemShowcase({super.key});

  @override
  State<DesignSystemShowcase> createState() => _DesignSystemShowcaseState();
}

class _DesignSystemShowcaseState extends State<DesignSystemShowcase> {
  int _selectedChip = 0;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UzLang · Design System')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.spaceLg),
        children: [
          _section('Карточка слова'),
          const _WordCardDemo(),
          const SizedBox(height: AppDimens.spaceXl),

          _section('Палитра'),
          const _PaletteDemo(),
          const SizedBox(height: AppDimens.spaceXl),

          _section('Типографика'),
          Text('Display 44', style: AppTextStyles.display),
          Text('Title 28', style: AppTextStyles.title),
          Text('Heading 24', style: AppTextStyles.heading),
          Text('Subheading 22', style: AppTextStyles.subheading),
          Text('Body 16 Medium — основной текст.', style: AppTextStyles.body),
          Text('Reading 16 — чтение кириллицей', style: AppTextStyles.reading),
          Text('Label 14 Semi Bold', style: AppTextStyles.label),
          Text('Caption 11 Bold — метаданные', style: AppTextStyles.caption),
          const SizedBox(height: AppDimens.spaceXl),

          _section('Кнопки'),
          PrimaryButton(
            label: 'Продолжить',
            iconName: AppIcons.play,
            isLoading: _loading,
            onPressed: () async {
              setState(() => _loading = true);
              await Future<void>.delayed(const Duration(seconds: 1));
              if (mounted) setState(() => _loading = false);
            },
          ),
          const SizedBox(height: AppDimens.spaceMd),
          SecondaryButton(label: 'Пропустить', onPressed: () {}),
          const SizedBox(height: AppDimens.spaceMd),
          const PrimaryButton(label: 'Неактивна', onPressed: null),
          const SizedBox(height: AppDimens.spaceXl),

          _section('Чипы'),
          Wrap(
            spacing: AppDimens.spaceSm,
            runSpacing: AppDimens.spaceSm,
            children: [
              for (final (int i, String label) in const [
                (0, 'Все'),
                (1, 'A1'),
                (2, 'A2'),
                (3, 'B1'),
              ].indexed.map((e) => (e.$1, e.$2.$2)))
                AppChip(
                  label: label,
                  selected: _selectedChip == i,
                  onTap: () => setState(() => _selectedChip = i),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceXl),

          _section('Карточка-контейнер'),
          AppCard(
            onTap: () {},
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accentTint,
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  ),
                  child: const Center(
                    child: AppIcon(
                      AppIcons.cart,
                      color: AppColors.accent,
                      size: AppDimens.iconLg,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Магазин', style: AppTextStyles.label),
                      Text('12 / 20 слов', style: AppTextStyles.caption),
                    ],
                  ),
                ),
                AppIcon(AppIcons.chevronRight, color: context.colors.textMuted),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.spaceXxl),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.spaceMd),
        child: Text(title, style: AppTextStyles.caption),
      );
}

/// Демо-карточка слова: латиница + чтение-кириллица + перевод.
class _WordCardDemo extends StatelessWidget {
  const _WordCardDemo();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppDimens.radiusCard,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceXl,
        vertical: AppDimens.spaceXxl,
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.accentTint,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            ),
            child: const Center(
              child: Text('👋', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: AppDimens.spaceLg),
          Text('Salom', style: AppTextStyles.word),
          const SizedBox(height: AppDimens.spaceXs),
          Text('салом', style: AppTextStyles.reading),
          const SizedBox(height: AppDimens.spaceSm),
          Text('Здравствуйте', style: AppTextStyles.body),
          const SizedBox(height: AppDimens.spaceLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(AppIcons.volume,
                  color: context.colors.info, size: AppDimens.iconLg),
              const SizedBox(width: AppDimens.spaceSm),
              Text('Прослушать', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

/// Демо-палитра ключевых токенов.
class _PaletteDemo extends StatelessWidget {
  const _PaletteDemo();

  @override
  Widget build(BuildContext context) {
    const swatches = <(String, Color)>[
      ('accent', AppColors.accent),
      ('success', AppColors.success),
      ('error', AppColors.error),
      ('info', AppColors.info),
      ('surface', AppColors.surface),
      ('raised', AppColors.surfaceRaised),
    ];
    return Wrap(
      spacing: AppDimens.spaceSm,
      runSpacing: AppDimens.spaceSm,
      children: [
        for (final (String name, Color color) in swatches)
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  border: Border.all(color: AppColors.line),
                ),
              ),
              const SizedBox(height: AppDimens.spaceXs),
              Text(name, style: AppTextStyles.caption),
            ],
          ),
      ],
    );
  }
}
