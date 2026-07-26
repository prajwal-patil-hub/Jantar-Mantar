import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:jantar_mantar_sahayata/core/media/exif_stripper.dart';

void main() {
  /// A JPEG carrying exactly the metadata a protest photo would leak.
  Uint8List photoWithGps({int width = 400, int height = 300}) {
    final image = img.Image(width: width, height: height);
    img.fill(image, color: img.ColorRgb8(120, 90, 60));

    // Jantar Mantar, to the metre — exactly what a real photo would carry.
    image.exif.gpsIfd.setGpsLocation(latitude: 28.6270, longitude: 77.2160);
    image.exif.imageIfd['Model'] = 'Pixel 7a';
    image.exif.imageIfd['DateTime'] = '2026:07:26 15:04:05';

    return Uint8List.fromList(img.encodeJpg(image));
  }

  test('the fixture really does leak GPS, so the test means something', () {
    final decoded = img.decodeImage(photoWithGps())!;
    expect(decoded.exif.gpsIfd.isEmpty, isFalse);
  });

  test('strips GPS, camera model and timestamp', () {
    final clean = ExifStripper.strip(photoWithGps())!;

    expect(ExifStripper.isClean(clean), isTrue);
    final decoded = img.decodeImage(clean)!;
    expect(decoded.exif.gpsIfd.isEmpty, isTrue);
    expect(decoded.exif.imageIfd['Model'], isNull);
    expect(decoded.exif.imageIfd['DateTime'], isNull);
  });

  test('the coordinates are not hiding in the bytes anywhere', () {
    final clean = ExifStripper.strip(photoWithGps())!;
    // Re-encoding rebuilds the file from pixels, so no EXIF/XMP/thumbnail
    // block can survive — including ones a tag-editing approach would miss.
    expect(String.fromCharCodes(clean), isNot(contains('Pixel 7a')));
    expect(String.fromCharCodes(clean), isNot(contains('2026:07:26')));
  });

  test('downscales oversized photos but keeps the aspect ratio', () {
    final clean = ExifStripper.strip(photoWithGps(width: 4000, height: 3000))!;
    final decoded = img.decodeImage(clean)!;

    expect(decoded.width, ExifStripper.maxDimension);
    expect(decoded.height, closeTo(ExifStripper.maxDimension * 3 / 4, 2));
  });

  test('leaves small photos at their original size', () {
    final clean = ExifStripper.strip(photoWithGps(width: 400, height: 300))!;
    final decoded = img.decodeImage(clean)!;
    expect(decoded.width, 400);
    expect(decoded.height, 300);
  });

  test('fails closed on anything that is not a decodable image', () {
    // Never pass an unexamined blob through to an upload.
    expect(ExifStripper.strip(Uint8List.fromList([1, 2, 3, 4])), isNull);
    expect(ExifStripper.strip(Uint8List(0)), isNull);
    expect(ExifStripper.isClean(Uint8List.fromList([1, 2, 3])), isFalse);
  });
}
