/// Доступ к платным возможностям (шов под подписку).
///
/// В V1 всё открыто ([isPremium] всегда `true`). Позже реализация заменяется
/// на проверку подписки через RevenueCat — без изменений в вызывающем коде.
class AccessService {
  /// Создаёт сервис.
  const AccessService();

  /// Активна ли премиум-подписка. В V1 — всегда `true`.
  bool isPremium() => true;

  /// Доступна ли тема с учётом её платности.
  bool canAccessTopic({required bool isPremiumTopic}) =>
      !isPremiumTopic || isPremium();
}
