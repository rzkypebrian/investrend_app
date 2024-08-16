
import 'package:flutter/material.dart';

class RowOrderbookPainter extends CustomPainter{
  static const double middle_gap = 20.0;
  final List texts = ['Que', 'BLot', 'Bid', 'Ask', 'ALot', 'Que'];
  @override
  void paint(Canvas canvas, Size size) {

    double widthHalf = size.width / 2;
    double widthSection = (size.width - middle_gap) / 2;
    print('RowOrderbookPainter paint widthHalf : $widthHalf  widthSection : $widthSection  Size : '+size.width.toString()+" x "+size.height.toString());
    
    final paint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.blue
    ;
    //canvas.drawPaint(paint);
    canvas.drawRect(Rect.fromPoints(Offset.zero, Offset(widthHalf, size.height)), paint);
    paint.color = Colors.purple;
    canvas.drawRect(Rect.fromPoints(Offset(widthHalf, 0), Offset(size.width, size.height)), paint);
    
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}