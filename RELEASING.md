# Building and shipping flow for production

## Double check before shipping

* Ensure `flutter test` command exits with code 0
* Sync model version (`latestSyncModelVersion`) in [`lib/sync/sync.dart`](./lib/sync/sync.dart).
* Bump version in [`pubspec.yaml`](./pubspec.yaml)
