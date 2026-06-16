class AppSettings {
  final bool onboardingCompleted;
  final bool isSharedBrain;

  const AppSettings({
    required this.onboardingCompleted,
    required this.isSharedBrain,
  });

  AppSettings copyWith({
    bool? onboardingCompleted,
    bool? isSharedBrain,
  }) {
    return AppSettings(
      onboardingCompleted:
          onboardingCompleted ??
          this.onboardingCompleted,
      isSharedBrain:
          isSharedBrain ??
          this.isSharedBrain,
    );
  }
}