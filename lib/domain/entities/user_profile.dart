import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'user_profile.freezed.dart';

/// Профиль пользователя (в V1 — локальный анонимный).
@freezed
abstract class UserProfile with _$UserProfile {
  /// Создаёт профиль.
  const factory UserProfile({
    /// Локальный анонимный идентификатор (шов под авторизацию).
    required String localUserId,

    /// Имя (спрашивается в онбординге).
    required String name,

    /// Режим письменности.
    @Default(ScriptMode.cyrillic) ScriptMode scriptMode,

    /// Дневная цель в минутах.
    @Default(10) int dailyGoalMinutes,
  }) = _UserProfile;
}
