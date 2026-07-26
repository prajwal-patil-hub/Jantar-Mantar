import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'exif_stripper.dart';

/// Result of picking a photo: always a sanitised copy, never the original.
class SanitizedPhoto {
  const SanitizedPhoto({required this.path, required this.bytes});

  final String path;
  final Uint8List bytes;
}

/// Picks a photo and immediately writes a metadata-free copy to app storage.
///
/// The original file is never referenced again — recording the camera roll
/// path would leave the submit flow pointing at a file that still carries GPS,
/// which is precisely the leak the stripper exists to prevent.
class PhotoPicker {
  const PhotoPicker([this._picker = const _DefaultPicker()]);

  final PhotoSource _picker;

  /// Returns null if the user cancelled. Throws [UnsupportedImageException]
  /// when the file cannot be decoded — better a refused photo than an
  /// unexamined blob queued for upload.
  Future<SanitizedPhoto?> pick({required bool fromCamera}) async {
    final raw = await _picker.read(fromCamera: fromCamera);
    if (raw == null) return null;

    final clean = ExifStripper.strip(raw);
    if (clean == null) throw const UnsupportedImageException();

    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/photo_${DateTime.now().microsecondsSinceEpoch}.jpg';
    await File(path).writeAsBytes(clean, flush: true);
    return SanitizedPhoto(path: path, bytes: clean);
  }
}

class UnsupportedImageException implements Exception {
  const UnsupportedImageException();
  @override
  String toString() => 'Unsupported image';
}

/// Seam so the flow is testable without a platform channel.
abstract interface class PhotoSource {
  Future<Uint8List?> read({required bool fromCamera});
}

class _DefaultPicker implements PhotoSource {
  const _DefaultPicker();

  @override
  Future<Uint8List?> read({required bool fromCamera}) async {
    final file = await ImagePicker().pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      // Cheap first pass; ExifStripper still re-encodes, which is what
      // actually removes the metadata.
      maxWidth: ExifStripper.maxDimension.toDouble(),
      maxHeight: ExifStripper.maxDimension.toDouble(),
    );
    return file == null ? null : await file.readAsBytes();
  }
}
