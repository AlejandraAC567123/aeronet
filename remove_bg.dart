import 'dart:io';
import 'package:image/image.dart' as img;
import 'dart:math';

void main() async {
  final file = File('assets/images/imgale.jpeg');
  if (!file.existsSync()) {
    print('File not found');
    return;
  }
  
  final bytes = await file.readAsBytes();
  final image = img.decodeImage(bytes);
  if (image == null) {
    print('Could not decode image');
    return;
  }
  
  print('Processing image of size ${image.width}x${image.height}');
  
  // Convert non-turquoise pixels to transparent
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final r = pixel.r;
      final g = pixel.g;
      final b = pixel.b;
      
      // Strictly isolate turquoise: R should be low, G and B high.
      if (g < 140 || b < 140 || r > 120) {
        image.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }

  // Find bounding box
  int minX = image.width, minY = image.height, maxX = 0, maxY = 0;
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if (image.getPixel(x, y).a > 0) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }
  
  print('Bounding box: ($minX, $minY) to ($maxX, $maxY)');
  
  final cropWidth = maxX - minX + 1;
  final cropHeight = maxY - minY + 1;
  
  final cropped = img.copyCrop(image, x: minX, y: minY, width: cropWidth, height: cropHeight);
  
  final size = max(cropWidth, cropHeight);
  final paddedSize = (size * 1.15).toInt();
  
  final square = img.Image(width: paddedSize, height: paddedSize, numChannels: 4);
  
  final dx = (paddedSize - cropWidth) ~/ 2;
  final dy = (paddedSize - cropHeight) ~/ 2;
  
  img.compositeImage(square, cropped, dstX: dx, dstY: dy);
  
  await File('assets/images/app_icon_transparent.png').writeAsBytes(img.encodePng(square));
  print('Saved assets/images/app_icon_transparent.png');
}
