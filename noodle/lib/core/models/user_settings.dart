class UserSettings {
  final String? geminiApiKey;

  const UserSettings({
    this.geminiApiKey,
  });

  UserSettings copyWith({
    String? geminiApiKey,
  }) {
    return UserSettings(
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
    );
  }
}