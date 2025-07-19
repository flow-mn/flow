import "dart:io";

import "package:flutter/foundation.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:googleapis/drive/v3.dart" as drive_v3;
import "package:http/http.dart" as http;

class GoogleAccountService {
  static final List<String> scopes = [
    "https://www.googleapis.com/auth/userinfo.profile",
    "https://www.googleapis.com/auth/userinfo.email",
    drive_v3.DriveApi.driveAppdataScope,
    drive_v3.DriveApi.driveFileScope,
  ];

  static GoogleAccountService? _instance;

  final ValueNotifier<GoogleSignInAccount?> _accountValueNotifier =
      ValueNotifier<GoogleSignInAccount?>(null);
  ValueListenable<GoogleSignInAccount?> get accountValueNotifier =>
      _accountValueNotifier;
  GoogleSignInAccount? get currentAccount => _accountValueNotifier.value;

  factory GoogleAccountService() =>
      _instance ??= GoogleAccountService._internal();

  GoogleAccountService._internal() {
    // Constructor
  }

  Future<void> signIn() async {
    if (GoogleSignIn.instance.supportsAuthenticate()) {
      final GoogleSignInAccount result = await GoogleSignIn.instance
          .authenticate(scopeHint: scopes);

      _accountValueNotifier.value = result;
    } else {
      throw Exception("Google Sign-In is not supported on this platform.");
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    _accountValueNotifier.value = null;
  }

  Future<drive_v3.DriveApi> getDriveApi() async {
    if (currentAccount == null) {
      throw Exception("No Google account is signed in.");
    }

    return drive_v3.DriveApi(
      GoogleAuthenticatedClient(currentAccount!, http.Client()),
    );
  }

  Future<drive_v3.File> uploadFile(File file, {String? contentType}) async {
    final drive_v3.DriveApi driveApi = await getDriveApi();

    final drive_v3.File driveFile = drive_v3.File();
    final drive_v3.Media driveMedia = drive_v3.Media(
      file.openRead(),
      file.lengthSync(),
      contentType: contentType ?? "application/octet-stream",
    );

    return await driveApi.files.create(driveFile, uploadMedia: driveMedia);
  }
}

class GoogleAuthenticatedClient extends http.BaseClient {
  final GoogleSignInAccount account;
  final http.Client baseClient;

  GoogleAuthenticatedClient(this.account, this.baseClient);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final glugluHeaders = await account.authorizationClient
        .authorizationHeaders(GoogleAccountService.scopes);

    if (glugluHeaders != null && glugluHeaders.isNotEmpty) {
      request.headers.addAll(glugluHeaders);
    }
    return baseClient.send(request);
  }
}
