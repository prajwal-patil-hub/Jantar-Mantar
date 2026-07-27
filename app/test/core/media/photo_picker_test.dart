import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:jantar_mantar_sahayata/core/media/exif_stripper.dart';
import 'package:jantar_mantar_sahayata/core/media/photo_picker.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('photo_picker_test');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
  });
  tearDown(() => tempDir.deleteSync(recursive: true));

  Uint8List photoWithGps() {
    final image = img.Image(width: 200, height: 150);
    img.fill(image, color: img.ColorRgb8(10, 20, 30));
    image.exif.gpsIfd.setGpsLocation(latitude: 28.627, longitude: 77.216);
    image.exif.imageIfd['Model'] = 'Pixel 7a';
    return Uint8List.fromList(img.encodeJpg(image));
  }

  test(
    'the file written to disk is the sanitised copy, not the original',
    () async {
      final picker = PhotoPicker(_FakeSource(photoWithGps()));

      final photo = (await picker.pick(fromCamera: true))!;

      // What the submit flow will reference must itself be clean — pointing at
      // the camera-roll original is the leak this whole path exists to avoid.
      final onDisk = await File(photo.path).readAsBytes();
      expect(ExifStripper.isClean(onDisk), isTrue);
      expect(String.fromCharCodes(onDisk), isNot(contains('Pixel 7a')));
      expect(photo.path, startsWith(tempDir.path));
    },
  );

  test('cancelling returns null and writes nothing', () async {
    final picker = PhotoPicker(_FakeSource(null));
    expect(await picker.pick(fromCamera: false), isNull);
    expect(tempDir.listSync(), isEmpty);
  });

  test('an undecodable file is refused, not attached', () async {
    final picker = PhotoPicker(_FakeSource(Uint8List.fromList([9, 9, 9])));
    await expectLater(
      picker.pick(fromCamera: false),
      throwsA(isA<UnsupportedImageException>()),
    );
    expect(tempDir.listSync(), isEmpty);
  });
}

class _FakeSource implements PhotoSource {
  _FakeSource(this._bytes);
  final Uint8List? _bytes;

  @override
  Future<Uint8List?> read({required bool fromCamera}) async => _bytes;
}

class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProvider(this.path);
  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}
