import "package:googleapis/drive/v3.dart";

class GoogleAccountService {
  static GoogleAccountService? _instance;

  factory GoogleAccountService() =>
      _instance ??= GoogleAccountService._internal();

  GoogleAccountService._internal() {
    // Constructor
  }

  Future<void> signIn() async {
    const List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.profile",
      "https://www.googleapis.com/auth/userinfo.email",
      DriveApi.driveAppdataScope,
      DriveApi.driveFileScope,
    ];

    // todo @sadespresso
  }
}
