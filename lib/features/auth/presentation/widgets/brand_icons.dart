import 'package:flutter/material.dart';

/// Vrai logo officiel Google (4 couleurs vectorielles)
class GoogleBrandIcon extends StatelessWidget {
  final double size;
  const GoogleBrandIcon({super.key, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;

    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    // Arc rouge (Haut)
    final redPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -2.35,
        1.57,
        false,
      )
      ..close();
    canvas.drawPath(redPath, redPaint);

    // Arc jaune (Gauche)
    final yellowPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -3.92,
        1.57,
        false,
      )
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // Arc vert (Bas)
    final greenPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        0.78,
        1.57,
        false,
      )
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // Arc bleu et barre droite
    final bluePath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -0.78,
        1.57,
        false,
      )
      ..lineTo(center.dx + radius * 0.95, center.dy)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // Disque intérieur blanc
    final innerWhite = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.58, innerWhite);

    // Barre centrale du G
    final barRect = Rect.fromLTRB(
      center.dx - radius * 0.05,
      center.dy - radius * 0.22,
      center.dx + radius * 0.95,
      center.dy + radius * 0.22,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(2)),
      bluePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vrai logo officiel GitHub (Octocat Vectoriel)
class GithubBrandIcon extends StatelessWidget {
  final double size;
  final Color color;
  const GithubBrandIcon({
    super.key,
    this.size = 18,
    this.color = const Color(0xFF0F172A),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GithubPainter(color)),
    );
  }
}

class _GithubPainter extends CustomPainter {
  final Color color;
  _GithubPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);

    final path = Path();
    path.moveTo(12, 0.297);
    path.cubicTo(5.37, 0.297, 0, 5.67, 0, 12.297);
    path.cubicTo(0, 17.6, 3.438, 22.097, 8.205, 23.682);
    path.cubicTo(8.805, 23.795, 9.025, 23.424, 9.025, 23.105);
    path.cubicTo(9.025, 22.82, 9.015, 22.065, 9.01, 21.065);
    path.cubicTo(5.672, 21.789, 4.968, 19.455, 4.968, 19.455);
    path.cubicTo(4.422, 18.07, 3.633, 17.7, 3.633, 17.7);
    path.cubicTo(2.546, 16.956, 3.717, 16.971, 3.717, 16.971);
    path.cubicTo(4.922, 17.055, 5.555, 18.207, 5.555, 18.207);
    path.cubicTo(6.624, 20.037, 8.36, 19.51, 9.044, 19.205);
    path.cubicTo(9.153, 18.428, 9.464, 17.9, 9.81, 17.6);
    path.cubicTo(7.145, 17.3, 4.343, 16.268, 4.343, 11.67);
    path.cubicTo(4.343, 10.36, 4.809, 9.29, 5.579, 8.45);
    path.cubicTo(5.444, 8.15, 5.039, 6.93, 5.694, 5.27);
    path.cubicTo(5.694, 5.27, 6.705, 4.95, 8.995, 6.5);
    path.cubicTo(9.955, 6.23, 10.98, 6.1, 12, 6.095);
    path.cubicTo(13.02, 6.1, 14.045, 6.23, 15.01, 6.5);
    path.cubicTo(17.3, 4.95, 18.31, 5.27, 18.31, 5.27);
    path.cubicTo(18.965, 6.93, 18.56, 8.15, 18.43, 8.45);
    path.cubicTo(19.2, 9.29, 19.66, 10.36, 19.66, 11.67);
    path.cubicTo(19.66, 16.28, 16.85, 17.295, 14.18, 17.59);
    path.cubicTo(14.61, 17.96, 15, 18.69, 15, 19.81);
    path.cubicTo(15, 21.43, 14.985, 22.73, 14.985, 23.105);
    path.cubicTo(14.985, 23.428, 15.2, 23.805, 15.81, 23.682);
    path.cubicTo(20.57, 22.092, 24, 17.595, 24, 12.297);
    path.cubicTo(24, 5.67, 18.627, 0.297, 12, 0.297);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
