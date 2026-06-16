// ignore: dangling_library_doc_comments
/// Right now we just need shared brain vs personal brain but later there can be more.
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