import 'dart:math';

import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/fullscreen/image_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Minimap extends StatelessWidget {
  final ImageEntry entry;
  final ValueNotifier<ViewState> viewStateNotifier;
  final Size size;

  static const defaultSize = Size(96, 96);

  const Minimap({
    @required this.entry,
    @required this.viewStateNotifier,
    this.size = defaultSize,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<MediaQueryData, Size>(
        selector: (context, mq) => mq.size,
        builder: (context, mqSize, child) {
          return AnimatedBuilder(
              animation: viewStateNotifier,
              builder: (context, child) {
                final viewState = viewStateNotifier.value;
                return CustomPaint(
                  painter: MinimapPainter(
                    viewportSize: mqSize,
                    entrySize: viewState.size ?? entry.displaySize,
                    viewCenterOffset: viewState.position,
                    viewScale: viewState.scale,
                    minimapBorderColor: Colors.white30,
                  ),
                  size: size,
                );
              });
        });
  }
}

class MinimapPainter extends CustomPainter {
  final Size entrySize, viewportSize;
  final Offset viewCenterOffset;
  final double viewScale;
  final Color minimapBorderColor, viewportBorderColor;

  const MinimapPainter({
    @required this.viewportSize,
    @required this.entrySize,
    @required this.viewCenterOffset,
    @required this.viewScale,
    this.minimapBorderColor = Colors.white,
    this.viewportBorderColor = Colors.white,
  })  : assert(viewportSize != null),
        assert(entrySize != null),
        assert(viewCenterOffset != null),
        assert(viewScale != null);

  @override
  void paint(Canvas canvas, Size size) {
    final viewSize = entrySize * viewScale;
    if (viewSize.isEmpty) return;

    // hide minimap when image is in full view
    if (viewportSize + Offset(precisionErrorTolerance, precisionErrorTolerance) >= viewSize) return;

    final canvasScale = size.longestSide / viewSize.longestSide;
    final scaledEntrySize = viewSize * canvasScale;
    final scaledViewportSize = viewportSize * canvasScale;

    final entryRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: scaledEntrySize.width,
      height: scaledEntrySize.height,
    );
    final viewportRect = Rect.fromCenter(
      center: size.center(Offset.zero) - viewCenterOffset * canvasScale,
      width: min(scaledEntrySize.width, scaledViewportSize.width),
      height: min(scaledEntrySize.height, scaledViewportSize.height),
    );

    canvas.translate((entryRect.width - size.width) / 2, (entryRect.height - size.height) / 2);

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Color(0x33000000);
    final minimapStroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = minimapBorderColor;
    final viewportStroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = viewportBorderColor;

    canvas.drawRect(viewportRect, fill);
    canvas.drawRect(entryRect, fill);
    canvas.drawRect(entryRect, minimapStroke);
    canvas.drawRect(viewportRect, viewportStroke);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
