import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Removes every scrap of metadata from a photo before it can be uploaded
/// (SECURITY.md: "strip EXIF/GPS client-side AND server-side").
///
/// A protest photo's EXIF routinely carries GPS coordinates, a timestamp, and
/// the camera's serial number — enough to place a specific person at a
/// specific protest with a specific handset. Editing tags out is not enough:
/// thumbnails, maker notes and XMP blocks survive that. So we **decode and
/// re-encode**, which reconstructs the file from pixels alone and cannot carry
/// anything else forward.
///
/// Fails closed: an image we cannot decode is rejected rather than passed
/// through unexamined.
abstract final class ExifStripper {
  /// Long edge of the output. Also drops resolution an attacker could use for
  /// sensor-noise fingerprinting, and keeps uploads small on a bad connection.
  static const maxDimension = 1600;
  static const jpegQuality = 82;

  /// Returns clean JPEG bytes, or null if [input] is not a decodable image.
  static Uint8List? strip(Uint8List input) {
    final decoded = _decode(input);
    if (decoded == null) return null;

    // Apply EXIF orientation to the PIXELS first. Dropping the tag without
    // baking it in is how "sanitised" photos come out sideways.
    var image = img.bakeOrientation(decoded);

    if (image.width > maxDimension || image.height > maxDimension) {
      final landscape = image.width >= image.height;
      image = img.copyResize(
        image,
        width: landscape ? maxDimension : null,
        height: landscape ? null : maxDimension,
        interpolation: img.Interpolation.average,
      );
    }

    // Belt and braces: the encoder writes no EXIF, and we clear the container
    // so nothing can be inherited if that ever changes.
    image.exif = img.ExifData();
    return img.encodeJpg(image, quality: jpegQuality);
  }

  /// True when [bytes] carry no EXIF/GPS. Used by tests and the release check;
  /// cheap enough to assert before an upload too.
  static bool isClean(Uint8List bytes) {
    final decoded = _decode(bytes);
    if (decoded == null) return false;
    final exif = decoded.exif;
    return exif.isEmpty && exif.gpsIfd.isEmpty;
  }

  /// `decodeImage` does not merely return null on junk — the format sniffers
  /// read ahead and throw `RangeError` on a truncated or hostile file. Callers
  /// hand us bytes straight from the picker, so swallowing that here is what
  /// actually makes this fail closed.
  static img.Image? _decode(Uint8List bytes) {
    try {
      return img.decodeImage(bytes);
    } on Object {
      return null;
    }
  }
}
