import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleSignInButton({super.key, required this.onPressed, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          foregroundColor: isDark ? Colors.white : const Color(0xFF3C4043),
          side: BorderSide(color: isDark ? const Color(0xFF3C4043) : const Color(0xFFDADCE0)),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: isDark ? Colors.white70 : const Color(0xFF5F6368),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GoogleLogo(size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Se connecter avec Google',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF3C4043),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  final double size;
  const _GoogleLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final cx = s / 2;
    final cy = s / 2;
    final r = s * 0.48;
    final ringW = s * 0.26;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringW
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    // Blue arc (top-left)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), -1.3, 1.6, false, paint);

    // Red arc (bottom-right)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), 0.3, 1.6, false, paint);

    // Yellow arc (bottom-left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), 1.9, 1.6, false, paint);

    // Green arc (top-right)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), -2.9, 1.6, false, paint);

    // White fill center
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r - ringW / 2, fillPaint);

    // Blue letter G
    final tp = TextPainter(
      text: TextSpan(
        text: 'G',
        style: TextStyle(
          fontSize: s * 0.75,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF4285F4),
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
