import "dart:io";

import "package:path/path.dart" as path;

Future<void> copyDirectory(Directory source, Directory destination) async {
  if (!source.existsSync()) {
    throw ArgumentError("Source directory does not exist: ${source.path}");
  }

  if (!destination.existsSync()) {
    await destination.create(recursive: true);
  }

  final List<FileSystemEntity> entities = source.listSync();

  await Future.wait(
    entities.whereType<File>().map((file) {
      final String newPath = path.join(
        destination.path,
        path.basename(file.path),
      );

      return file.copy(newPath);
    }),
  );

  await Future.wait(
    entities.whereType<Directory>().map((directory) {
      final String newPath = path.join(
        destination.path,
        path.basename(directory.path),
      );
      return copyDirectory(directory, Directory(newPath));
    }),
  );
}
