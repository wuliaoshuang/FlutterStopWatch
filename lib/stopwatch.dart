import 'dart:math';

import 'package:flutter/material.dart';

class StopwatchWidget extends StatelessWidget {
  final double radius;
  final Duration duration;
  final Duration secondDuration;
  final Color? themeColor;
  final TextStyle? textStyle;
  final Color scaleColor;

  const StopwatchWidget(
      {super.key,
        required this.radius,
        required this.duration,
        this.secondDuration = Duration.zero,
        this.scaleColor = const Color(0xffDADADA),
        this.textStyle,
        this.themeColor});

  TextStyle get commonStyle => TextStyle(
    fontSize: radius / 3.2,
    fontWeight: FontWeight.w100,
    fontFamily: 'IBMPlexMono',
    color: const Color(0xff343434),
  );

  @override
  Widget build(BuildContext context) {
    TextStyle style = textStyle ?? commonStyle;
    Color themeColor = this.themeColor ?? Theme.of(context).primaryColor;
    return CustomPaint(
      painter: StopwatchPainter(
          radius: radius,
          duration: duration,
          secondDuration: secondDuration,
          themeColor: themeColor,
          scaleColor: scaleColor,
          textStyle: style),
      size: Size(radius * 2, radius * 2),
    );
  }
}

const double _kScaleWidthRate = 0.4 / 10;
const _kIndicatorRadiusRate = 0.2 / 10;
const _kStrokeWidthRate = 0.8 / 135.0;

class StopwatchPainter extends CustomPainter {
  final Duration duration;
  final Duration secondDuration;
  final double radius;
  final Color themeColor;
  final Color scaleColor;
  final TextStyle textStyle;

  StopwatchPainter({
    required this.duration,
    required this.themeColor,
    required this.scaleColor,
    required this.radius,
    required this.textStyle,
    required this.secondDuration,
  }) {
    indicatorPainter.color = themeColor;
    scalePainter..style = PaintingStyle.stroke..strokeWidth=_kStrokeWidthRate*radius;
  }

  final Paint scalePainter = Paint();
  final Paint indicatorPainter = Paint();

  final TextPainter textPainter = TextPainter(
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // 画布中心点平移
    canvas.translate(size.width / 2, size.height / 2);
    // 绘制刻度表盘
    drawScale(canvas, size);
    // 线条粗细
    final double scaleLineWidth = size.width * _kScaleWidthRate;
    // 指示器大小
    final double indicatorRadius = size.width * _kIndicatorRadiusRate;
    // 保存画布
    canvas.save();

    // 计算秒数
    int second = duration.inSeconds % 60;
    // 计算毫秒数
    int milliseconds = duration.inMilliseconds % 1000;
    // 通过秒数毫秒数计算弧度
    double radians = (second * 1000 + milliseconds) / (60 * 1000) * 2 * pi;
    // 旋转指示器
    canvas.rotate(radians);
    // 绘制指示器
    canvas.drawCircle(
        Offset(
          0,
          -size.width / 2 + scaleLineWidth + indicatorRadius,
        ),
        indicatorRadius / 2,
        indicatorPainter);
    canvas.restore();

    // 绘制秒表文本
    drawText(canvas);

    if(secondDuration != Duration.zero){
      drawText2(canvas);
    }
  }

  void drawText(Canvas canvas) {
    // 计算分钟数
    int minus = duration.inMinutes % 60;
    // 计算秒钟数
    int second = duration.inSeconds % 60;
    // 计算毫秒数
    int milliseconds = duration.inMilliseconds % 1000;
    // 拼接分秒字符串
    String commonStr =
        '${minus.toString().padLeft(2, "0")}:${second.toString().padLeft(2, "0")}';
    // 拼接毫秒字符串
    String highlightStr = ".${(milliseconds ~/ 10).toString().padLeft(2, "0")}";
    // 绘制TextSpan组件
    textPainter.text = TextSpan(text: commonStr, style: textStyle.copyWith(fontWeight: FontWeight.w500), children: [
      TextSpan(text: highlightStr, style: textStyle.copyWith(color: themeColor, fontWeight: FontWeight.w500))
    ]);
    textPainter.layout(); // 进行布局
    final double width = textPainter.size.width;
    final double height = textPainter.size.height;
    textPainter.paint(canvas, Offset(-width / 2, -height / 2));
  }

  void drawText2(Canvas canvas){
    int minus = secondDuration.inMinutes % 60;
    int second = secondDuration.inSeconds % 60;
    int milliseconds = secondDuration.inMilliseconds % 1000;

    String commonStr = '${minus.toString().padLeft(2, "0")}:${second.toString().padLeft(2, "0")}';
    String highlightStr = '.${(milliseconds ~/ 10).toString().padLeft(2, "0")}';

    textPainter.text = TextSpan(
      text: commonStr + highlightStr,
      style: textStyle.copyWith(
        fontSize: textStyle.fontSize !/ 3,
        color: scaleColor
      )
    );

    textPainter.layout(); // 进行布局

    final double width = textPainter.size.width;
    final double height = textPainter.size.height;

    textPainter.paint(canvas, Offset(-width / 2, -height / 2+ textStyle.fontSize!*0.9));
  }

  void drawScale(Canvas canvas, Size size) {
    final double scaleLineWidth = size.width * _kScaleWidthRate;
    for (int i = 0; i < 180; i++) {
      if (i == 90 + 45) {
        scalePainter.color = themeColor;
      } else {
        scalePainter.color = scaleColor;
      }
      canvas.drawLine(Offset(size.width / 2, 0),
          Offset(size.width / 2 - scaleLineWidth, 0), scalePainter);
      canvas.rotate(pi / 180 * 2);
    }
  }

  @override
  bool shouldRepaint(covariant StopwatchPainter oldDelegate) {
    return oldDelegate.duration != duration ||
        oldDelegate.textStyle != textStyle ||
        oldDelegate.themeColor != themeColor ||
        oldDelegate.scaleColor != scaleColor;
  }
}