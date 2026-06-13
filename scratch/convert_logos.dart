import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final srcDir = Directory('e:/Depometrik/akaryakıt logolar');
  final destDir = Directory('e:/Depometrik/assets/images');
  
  if (!destDir.existsSync()) {
    destDir.createSync(recursive: true);
  }

  // Clear existing png assets that we don't need anymore or will override
  if (destDir.existsSync()) {
    for (var file in destDir.listSync()) {
      if (file is File) {
        file.deleteSync();
      }
    }
  }

  final files = srcDir.listSync();
  for (var file in files) {
    if (file is File) {
      final name = file.uri.pathSegments.last.toLowerCase();
      print('Processing $name...');
      final bytes = file.readAsBytesSync();
      final image = img.decodeImage(bytes);
      if (image == null) {
        print('Failed to decode $name');
        continue;
      }
      
      // Convert and encode as PNG (standard format)
      final pngBytes = img.encodePng(image);
      final cleanName = name.replaceAll('.png', '').replaceAll('.jpg', '').replaceAll('.jpeg', '');
      
      // Map PO to petrol_ofisi
      final targetName = cleanName == 'po' ? 'petrol_ofisi' : cleanName;
      final outFile = File('${destDir.path}/$targetName.png');
      outFile.writeAsBytesSync(pngBytes);
      print('Successfully saved $targetName.png (${pngBytes.length} bytes)');
    }
  }
}
