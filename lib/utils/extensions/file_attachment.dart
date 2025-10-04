import "package:flow/entity/file_attachment.dart";
import "package:flutter/widgets.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:path/path.dart" as path;

/// Extensions for [FileAttachment]
extension FileAttachmentExtension on FileAttachment {
  String get displayName => name ?? fileName;

  IconData get icon => switch (path.extension(filePath).toLowerCase()) {
    ".pdf" => Symbols.picture_as_pdf_rounded,
    ".doc" || ".docx" => Symbols.docs_rounded,
    ".xls" || ".xlsx" => Symbols.table_rounded,
    ".ppt" || ".pptx" => Symbols.slideshow_rounded,
    ".zip" || ".rar" || ".7z" || ".tar" || ".gz" => Symbols.folder_zip_rounded,
    ".mp3" ||
    ".wav" ||
    ".flac" ||
    ".aac" ||
    ".ogg" => Symbols.audio_file_rounded,
    ".mp4" ||
    ".mkv" ||
    ".mov" ||
    ".avi" ||
    ".wmv" ||
    ".flv" => Symbols.video_file_rounded,
    ".jpg" ||
    ".jpeg" ||
    ".png" ||
    ".gif" ||
    ".bmp" ||
    ".tiff" ||
    ".webp" => Symbols.image_rounded,
    ".txt" || ".rtf" => Symbols.notes_rounded,
    ".md" => Symbols.markdown_rounded,
    ".json" => Symbols.file_json_rounded,
    ".csv" => Symbols.csv_rounded,
    ".tsv" => Symbols.tsv_rounded,
    ".html" || ".htm" => Symbols.html_rounded,
    ".css" => Symbols.css_rounded,
    ".avc" => Symbols.avc_rounded,
    ".js" => Symbols.javascript_rounded,
    ".php" => Symbols.php_rounded,
    _ => Symbols.unknown_document_rounded,
  };
}
