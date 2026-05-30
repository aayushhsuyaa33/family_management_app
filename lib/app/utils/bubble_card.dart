import 'package:flutter/material.dart';

class ProfileCardBubble extends StatelessWidget {
  final String title;
  final String description;
  final Color color;

  const ProfileCardBubble({
    super.key,
    required this.title,
    required this.description,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.black26),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class BubbleWithPointer extends StatelessWidget {
  final Widget child;
  final double arrowHeight;
  final Color arrowColor;

  const BubbleWithPointer({
    super.key,
    required this.child,
    this.arrowHeight = 10,
    this.arrowColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bubble box
        child,
        // Pointer (triangle)
        CustomPaint(
          size: Size(20, arrowHeight),
          painter: TrianglePainter(arrowColor: arrowColor),
        ),
      ],
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color arrowColor;
  TrianglePainter({required this.arrowColor});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = arrowColor
      ..style = PaintingStyle.fill;

    final border = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
