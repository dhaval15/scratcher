import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:scratcher/utils.dart';

typedef _DrawFunction(Size size);

/// Custom painter object which handles revealing of color/image
class ScratchPainter extends CustomPainter {
  ScratchPainter({
    this.points,
    this.color,
    this.image,
    this.imageFit,
    this.onDraw,
  });

  /// List of revealed points from scratcher
  final List<ScratchPoint> points;

  /// Background color of the scratch area
  final Color color;

  /// Path to local image which can be used as scratch area
  final ui.Image image;

  /// Determine how the image should fit the scratch area
  final BoxFit imageFit;

  /// Callback called each time the painter is redraw
  final _DrawFunction onDraw;

  Paint _getMainPaint(double strokeWidth) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = Colors.transparent
      ..strokeWidth = strokeWidth
      ..blendMode = BlendMode.src
      ..style = PaintingStyle.stroke;

    return paint;
  }

  @override
  void paint(Canvas canvas, Size size) {
    onDraw(size);

    canvas.saveLayer(null, Paint());

    final areaRect = Rect.fromLTRB(0, 0, size.width, size.height);
    canvas.drawRect(areaRect, Paint()..color = color);
    if (image != null) {
      final imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final sizes = applyBoxFit(imageFit, imageSize, size);
      final inputSubrect =
          Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
      final outputSubrect =
          Alignment.center.inscribe(sizes.destination, areaRect);
      canvas.drawImageRect(image, inputSubrect, outputSubrect, Paint());
    }
    LinesPainter().paint(canvas, size);

    var path = Path();
    var isStarted = false;
    ScratchPoint previousPoint;

    for (final point in points) {
      if (point == null) {
        canvas.drawPath(path, _getMainPaint(previousPoint.size));
        path = Path();
        isStarted = false;
      } else {
        final position = point.position;
        if (!isStarted) {
          isStarted = true;
          path.moveTo(position.dx, position.dy);
        } else {
          path.lineTo(position.dx, position.dy);
        }
      }

      previousPoint = point;
    }

    if (previousPoint != null) {
      canvas.drawPath(path, _getMainPaint(previousPoint.size));
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(ScratchPainter oldDelegate) => true;
}

// class ScratchContainer extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: LinesPainter(),
//       child: Padding(
//         padding: EdgeInsets.symmetric(vertical: 64, horizontal: 32),
//         child: Column(
//           mainAxisSize: MainAxisSize.max,
//           children: <Widget>[
//             CircleAvatar(
//               maxRadius: 80,
//               backgroundColor: Kolors.giftIconBackGround,
//               child: WebsafeSvg.asset('icons/gift2.svg', height: 96, width: 96),
//             ),
//             SizedBox(height: 32),
//             Text(
//               'You won a Scratch Card',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Kolors.whiteLabel,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class LinesPainter extends CustomPainter {
  final double radius = 24;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    Path back = Path();
    back.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    canvas.drawShadow(back, Colors.black.withOpacity(0.7), 4, false);
    canvas.drawPath(back, Paint()..shader = gradient.createShader(rect));
    for (double y = 5; y < size.height - 5; y = y + 30) {
      Path path = Path();
      path.moveTo(5, y + 5 * math.sin(5 / 8));
      for (double x = 5; x < size.width - 5; x++) {
        path.lineTo(x, y + 5 * math.sin(x / 8));
      }
      canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white.withOpacity(0.3)
            ..style = PaintingStyle.stroke);
      canvas.clipRect(rect);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
