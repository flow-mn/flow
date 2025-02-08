class AccountsService {
  static AccountsService? _instance;

  factory AccountsService() => _instance ??= AccountsService._internal();

  AccountsService._internal() {
    // Constructor
  }
}
